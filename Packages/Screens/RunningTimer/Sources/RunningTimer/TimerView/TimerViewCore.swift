import Foundation
import UIKit
import CoreInterface
import ComposableArchitecture
import CoreLogic
import DomainEntities

public enum TimerViewAction: Equatable {
    case timerBegin
    case timerTick
    case timerFinish
    case sectionEnded
    
    case countdownAction(CountdownAction)
    case finishedAction(FinishedWorkoutAction)

    case closeButtonTapped
    case alertCancelTapped
    case alertConfirmTapped
    case alertDismissed

    case pause
    case resume
    case stop
    case close
}

public struct TimerViewState: Equatable {
    
    enum WorkoutState: Equatable {
        case workout, rest, pause
    }
    
    let workout: QuickWorkout
    var totalTimeLeft: TimeInterval = 0
    var timerSections: IdentifiedArrayOf<TimerSection>
    var isRunning: Bool = false
    var countdownState: CountdownState? = CountdownState()
    var finishedState: FinishedWorkoutState?
    var alert: AlertState<TimerViewAction>?
    var startDate = Date()

    public init(workout: QuickWorkout) {
        self.workout = workout
        self.timerSections = IdentifiedArray(uniqueElements: workout.segments.map(TimerSection.create(from:)).flatMap { $0 }.dropLast())
        self.totalTimeLeft = timerSections.totalDuration
    }
}

public struct TimerViewEnvironment {
    var soundClient: SoundClient
    var notificationClient: LocalNotificationClient
    var timerStep: DispatchQueue.SchedulerTimeType.Stride

    public init(
        soundClient: SoundClient,
        notificationClient: LocalNotificationClient,
        timerStep: DispatchQueue.SchedulerTimeType.Stride = .seconds(0.05)
    ) {
        self.soundClient = soundClient
        self.notificationClient = notificationClient
        self.timerStep = timerStep
    }
}

public extension SystemEnvironment where Environment == TimerViewEnvironment {
    static let preview = SystemEnvironment.mock(environment: TimerViewEnvironment(soundClient: .mock, notificationClient: .mock))
    static let live = SystemEnvironment.live(environment: TimerViewEnvironment(soundClient: .live, notificationClient: .live))
}

public let timerViewReducer = Reducer<TimerViewState, TimerViewAction, SystemEnvironment<TimerViewEnvironment>>.combine(
    countdownReducer.optional().pullback(
        state: \.countdownState,
        action: /TimerViewAction.countdownAction,
        environment: { _ in .live }
    ),
    finishedWorkoutReducer.optional().pullback(
        state: \.finishedState,
        action: /TimerViewAction.finishedAction,
        environment: { _ in .live }
    ),
    Reducer { state, action, environment in
        struct TimerId: Hashable {}
        let id = TimerId()

        switch action {

        case .resume:
            state.isRunning = true
            return Effect
                .timer(id: id, every: environment.timerStep, tolerance: .zero, on: environment.mainQueue())
                .map { _ in TimerViewAction.timerTick }

        case .timerTick:
            state.totalTimeLeft -= environment.timerStep.timeInterval.asDouble ?? 0
            state.timerSections.update(state.currentSection?.id, keyPath: \.timeLeft, value: (state.currentSection?.timeLeft ?? 0) - (environment.timerStep.timeInterval.asDouble ?? 0))

            if state.totalTimeLeft <= 0 {
                state.timerSections.update(state.currentSection?.id, keyPath: \.isFinished, value: true)
                return Effect(value: TimerViewAction.timerFinish)
            }

            if (state.currentSection?.timeLeft ?? 0) <= 0 {
                return Effect(value: TimerViewAction.sectionEnded)
            }

        case .timerFinish:
            let finishedWorkout = FinishedWorkout(
                workout: state.workout,
                totalDuration: state.totalTimeExpired,
                startDate: state.startDate,
                finishDate: Date()
            )
            state.finishedState = FinishedWorkoutState(workout: finishedWorkout)
            return .cancel(id: id)

        case .timerBegin:
            state.isRunning = true
            return Effect
                .timer(id: id, every: environment.timerStep, tolerance: .zero, on: environment.mainQueue())
                .map { _ in TimerViewAction.timerTick }

        case .sectionEnded:
            state.timerSections.update(state.currentSection?.id, keyPath: \.isFinished, value: true)
//            guard environment.settings.soundEnabled else { break }
//            return environment
//                .soundClient
//                .play(.segment)
//                .fireAndForget()

        case .countdownAction(.finished):
            state.countdownState = nil
            
        case .pause:
            state.isRunning = false
            return .cancel(id: id)
            
        case .closeButtonTapped:
            state.alert = .init(
                title: .init("Stop workout?"),
                message: .init("Are you sure you want to stop this workout?"),
                primaryButton: .cancel(.init("Cancel"), action: .send(.alertCancelTapped)),
                secondaryButton: .default(.init("Yes"), action: .send(.alertConfirmTapped))
            )
            return Effect(value: .pause)
            
        case .alertCancelTapped, .alertDismissed:
            state.alert = nil
            return Effect(value: .resume)

        case .alertConfirmTapped:
            return Effect(value: .stop)
            
        case .stop:
            state.isRunning = false
            if state.shouldGoToFinishedScreen {
                let finishedWorkout = FinishedWorkout(
                    workout: state.workout,
                    totalDuration: state.totalTimeExpired,
                    startDate: state.startDate,
                    finishDate: Date()
                )
                state.finishedState = FinishedWorkoutState(workout: finishedWorkout)
                return .cancel(id: id)
            } else {
                return .cancel(id: id).merge(with: .init(value: .close)).eraseToEffect()
            }
            
        case .finishedAction(.closeButtonTapped):
            return .init(value: .close)

        case .finishedAction, .countdownAction, .close:
            break
        }

        return .none
    }
)

extension TimerViewState {
    var currentSection: TimerSection? {
        timerSections.first { $0.isFinished == false }
    }
    
    var finishedSections: Int {
        timerSections.filter { $0.type == .work && $0.isFinished == true }.count
    }

    var totalTimeExpired: TimeInterval {
        timerSections.totalDuration - totalTimeLeft
    }
    
    var workoutState: WorkoutState {
        isRunning ? (currentSection?.type == .work ? .workout : .rest) : .pause
    }
}

private extension TimerViewState {
    var shouldGoToFinishedScreen: Bool {
        totalTimeLeft <= timerSections.totalDuration - (timerSections.totalDuration * 2) / 3
    }
}
