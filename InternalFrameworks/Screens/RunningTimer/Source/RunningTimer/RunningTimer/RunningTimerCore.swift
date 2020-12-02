import Foundation
import UIKit
import CoreInterface
import ComposableArchitecture
import CoreLogic
import DomainEntities

public enum RunningTimerAction: Equatable {
    case timerControlsUpdatedState(TimerControlsAction)
    case segmentedProgressAction(SegmentedProgressAction)
    case finishedWorkoutAction(FinishedWorkoutAction)
    case preCountdownAction(PreCountdownAction)
    case headerAction(HeaderAction)

    case timerTicked
    case timerFinished

    case onBackground
    case sectionEnded
}

public struct RunningTimerState: Equatable {
    var precountdownState: PreCountdownState?
    var headerState: HeaderState
    var timerControlsState: TimerControlsState
    var segmentedProgressState = SegmentedProgressState(totalSegments: 0)
    var finishedWorkoutState: FinishedWorkoutState?

    var currentSection: TimerSection? = nil
    var sectionTimeLeft: TimeInterval = 0
    var finishedSections: Int = 0
    var workout: QuickWorkout
    var timerSections: [TimerSection]

    var progressSegmentsCount: Int {
        timerSections.filter { $0.type == .work }.count
    }

    public init(workout: QuickWorkout,
                currentSection: TimerSection? = nil,
                timerControlsState: TimerControlsState = TimerControlsState()) {
        self.workout = workout
        self.timerControlsState = timerControlsState
        self.headerState = HeaderState(timeLeft: 0, workoutName: workout.name)
        self.precountdownState = PreCountdownState(workoutColor: workout.color)
        self.timerSections = workout.segments.map { TimerSection.create(from: $0) }.flatMap { $0 }.dropLast()
        self.currentSection = currentSection ?? timerSections.first
    }
}

public struct RunningTimerEnvironment {
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

public extension SystemEnvironment where Environment == RunningTimerEnvironment {
    static let preview = SystemEnvironment.live(environment: RunningTimerEnvironment(soundClient: .mock, notificationClient: .mock))
    static let live = SystemEnvironment.live(environment: RunningTimerEnvironment(soundClient: .live, notificationClient: .live))
}

public let runningTimerReducer = Reducer<RunningTimerState, RunningTimerAction, SystemEnvironment<RunningTimerEnvironment>>.combine(
    preCountdownReducer.optional().pullback(
        state: \.precountdownState,
        action: /RunningTimerAction.preCountdownAction,
        environment: { _ in .live }
    ),
    headerReducer.pullback(
        state: \.headerState,
        action: /RunningTimerAction.headerAction,
        environment: { _ in HeaderEnvironment() }
    ),
    Reducer { state, action, environment in
        struct TimerId: Hashable {}
        let id = TimerId()

        switch action {

        case .preCountdownAction(.finished):
            state.precountdownState = nil
            state.updateSegments()
            return Effect(value: RunningTimerAction.timerControlsUpdatedState(.start))

        case .onBackground:
            return environment.notificationClient.scheduleLocalNotification(.timerPaused, .immediately)
                .map { _ in
                    RunningTimerAction.timerControlsUpdatedState(.pause)
                }

        case .timerControlsUpdatedState(let controlsAction):
            switch controlsAction {
            case .pause:
                return Effect<RunningTimerAction, Never>.cancel(id: id)

            case .start:
                return Effect
                    .timer(id: id, every: environment.timerStep, tolerance: .zero, on: environment.mainQueue())
                    .map { _ in RunningTimerAction.timerTicked }
            }

        case .segmentedProgressAction:
            break

        case .timerTicked:
            state.headerState.timeLeft -= environment.timerStep.timeInterval.asDouble ?? 0
            state.sectionTimeLeft -= environment.timerStep.timeInterval.asDouble ?? 0

            if state.headerState.timeLeft <= 0 {
                state.finishedSections += 1
                return Effect(value: RunningTimerAction.timerFinished)
            }

            if state.sectionTimeLeft <= 0, !state.isCurrentSegmentLast {
                return Effect(value: RunningTimerAction.sectionEnded)
            }

        case .sectionEnded:
            state.moveToNextSection()
            guard environment.settings.soundEnabled else { return .none }
            return environment
                .soundClient
                .play(.segment)
                .fireAndForget()

        case .headerAction(.closeButtonTapped):
            if !state.timerControlsState.isFinished {
                return Effect(value: RunningTimerAction.timerControlsUpdatedState(.pause))
            }

        case .headerAction(.alertCancelTapped):
            return Effect(value: RunningTimerAction.timerControlsUpdatedState(.start))

        case .headerAction(.alertConfirmTapped):
            return Effect(value: RunningTimerAction.timerFinished)

        case .timerFinished:
            state.finish()

        default: break
        }
        return .none
    },
    quickTimerControlsReducer.pullback(
        state: \.timerControlsState,
        action: /RunningTimerAction.timerControlsUpdatedState,
        environment: { _ in QuickTimerControlsEnvironment()}
    ),
    segmentedProgressReducer.pullback(
        state: \.segmentedProgressState,
        action: /RunningTimerAction.segmentedProgressAction,
        environment: { _ in SegmentedProgressEnvironment() }
    ),
    finishedWorkoutReducer.optional().pullback(
        state: \.finishedWorkoutState,
        action: /RunningTimerAction.finishedWorkoutAction,
        environment: { _ in FinishedWorkoutEnvironment(repository: .live) }
    )
)

private extension RunningTimerState {
    mutating func calculateInitialTime() {
        headerState.timeLeft = TimeInterval(timerSections.map(\.duration).reduce(0, +))
        sectionTimeLeft = currentSection?.duration ?? 0
    }

    mutating func moveToNextSection() {
        guard let section = currentSection,
              let index = timerSections.firstIndex(of: section) else { return }

        if let newSet = timerSections[safe: index + 1] {
            if section.type == .work {
                finishedSections += 1
            }
            currentSection = newSet
        }

        sectionTimeLeft = currentSection?.duration ?? 0
    }

    mutating func updateSegments() {
        segmentedProgressState = SegmentedProgressState(totalSegments: progressSegmentsCount, filledSegments: 0, title: "Sections")
        currentSection = timerSections.first
        calculateInitialTime()
    }

    mutating func finish() {
        finishedWorkoutState = FinishedWorkoutState(workout: workout)
        timerControlsState = TimerControlsState(timerState: .finished)
        headerState.alert = nil
        headerState.isFinished = true
    }

    var isCurrentSegmentLast: Bool {
        guard let section = currentSection, let index = timerSections.firstIndex(of: section) else { return true }
        return index == timerSections.count - 1
    }
}

private extension LocalNotificationClient.Content {
    static let timerPaused = LocalNotificationClient.Content(title: "Timer paused", message: "Timer has been paused. Open the app to continue workout")
}
