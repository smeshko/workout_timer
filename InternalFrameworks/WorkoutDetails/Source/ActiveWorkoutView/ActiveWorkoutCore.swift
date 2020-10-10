import Foundation
import WorkoutCore
import ComposableArchitecture

public enum ActiveWorkoutAction: Equatable {
    case workoutBegin
    case timerTicked
    case pause
    case resume
    case moveToNextExercise
    case stopWorkout
    case workoutFinished
}

public struct ActiveWorkoutState: Equatable {
    var workout: Workout
    var currentSet: ExerciseSet?
    var nextSet: ExerciseSet?
    var currentSetSecondsLeft: TimeInterval = 0

    var totalTimeExpired: TimeInterval = 0
    var isRunning = false
    var isFinished = false

    var finishedWorkoutSets: Int = 0
    var totalWorkoutSets: Int {
        workout.sets.filter { $0.type != .rest }.count
    }

    public init(workout: Workout) {
        self.workout = workout
        self.currentSet = workout.sets.first
        self.nextSet = workout.sets.object(after: currentSet)
        self.currentSetSecondsLeft = currentSet?.duration ?? 0
    }
}

public struct ActiveWorkoutEnvironment {

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let soundClient: SoundClient

    public init(mainQueue: AnySchedulerOf<DispatchQueue>, soundClient: SoundClient) {
        self.mainQueue = mainQueue
        self.soundClient = soundClient
    }
}

public let activeWorkoutReducer = Reducer<ActiveWorkoutState, ActiveWorkoutAction, ActiveWorkoutEnvironment> { state, action, environment in
    struct TimerId: Hashable {}

    switch action {

    case .pause:
        state.isRunning = false
        return Effect<ActiveWorkoutAction, Never>.cancel(id: TimerId())

    case .resume:
        state.isRunning = true
        return Effect(value: ActiveWorkoutAction.workoutBegin)

    case .stopWorkout:
        state.reset()
        return Effect<ActiveWorkoutAction, Never>.cancel(id: TimerId())

    case .workoutBegin:
        state.isRunning = true
        return Effect
            .timer(id: TimerId(), every: 1, tolerance: .zero, on: environment.mainQueue)
            .map { _ in ActiveWorkoutAction.timerTicked }

    case .timerTicked:
        state.totalTimeExpired += 1
        state.currentSetSecondsLeft -= 1

        if state.currentSetSecondsLeft <= 0 {
            return Effect(value: ActiveWorkoutAction.moveToNextExercise)
        }

    case .moveToNextExercise:
        return state.moveToNextExercise(soundClient: environment.soundClient)

    case .workoutFinished:
        state.isRunning = false
        state.isFinished = true
        return Effect<ActiveWorkoutAction, Never>.cancel(id: TimerId())

    }
    return .none
}

private extension ActiveWorkoutState {
    mutating func moveToNextExercise(soundClient: SoundClient) -> Effect<ActiveWorkoutAction, Never> {
        guard let next = workout.sets.object(after: currentSet) else {
            return Effect(value: ActiveWorkoutAction.workoutFinished)
        }

        if currentSet?.type != .rest {
            finishedWorkoutSets += 1
        }
        currentSet = next
        currentSetSecondsLeft = next.duration
        nextSet = workout.sets.object(after: next)

        return soundClient.play(.segment).fireAndForget()
    }

    mutating func reset() {
        currentSet = workout.sets.first
        nextSet = workout.sets.object(after: currentSet)
        currentSetSecondsLeft = 0
        totalTimeExpired = 0
        isFinished = false
        isRunning = false
    }
}

private extension Array where Element: Equatable {
    func object(after element: Element?) -> Element? {
        guard let element = element else { return nil }
        guard let index = firstIndex(of: element) else { return nil }
        return self[safe: index + 1]
    }
}
