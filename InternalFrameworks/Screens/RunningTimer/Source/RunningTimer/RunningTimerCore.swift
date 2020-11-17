import Foundation
import CoreInterface
import ComposableArchitecture
import CoreLogic
import DomainEntities

fileprivate struct Constants {
    static let preCountdown: TimeInterval = 3
}

public enum RunningTimerAction: Equatable {
    case timerControlsUpdatedState(TimerControlsAction)
    case segmentedProgressAction(SegmentedProgressAction)
    case finishedWorkoutAction(FinishedWorkoutAction)

    case timerTicked
    case timerFinished
    case timerClosed

    case onAppear
    case onActive
    case onBackground
    case onPush

    case preCountdownFinished
    case sectionEnded

    case alertButtonTapped
    case alertCancelTapped
    case alertDismissed
}

public struct RunningTimerState: Equatable {
    var currentSection: TimerSection? = nil
    var totalTimeLeft: TimeInterval = 0
    var sectionTimeLeft: TimeInterval = 0
    var timerControlsState: TimerControlsState
    var segmentedProgressState: SegmentedProgressState
    var finishedSections: Int = 0
    var workout: QuickWorkout
    var timerSections: [TimerSection]
    var alert: AlertState<RunningTimerAction>?
    var isPresented = true
    var finishedWorkoutState: FinishedWorkoutState?

    var preCountdownTimeLeft: TimeInterval = Constants.preCountdown
    var isInPreCountdown: Bool

    var progressSegmentsCount: Int {
        timerSections.filter { $0.type == .work }.count
    }

    public init(workout: QuickWorkout,
                currentSection: TimerSection? = nil,
                timerControlsState: TimerControlsState = TimerControlsState(),
                segmentedProgressState: SegmentedProgressState = SegmentedProgressState(totalSegments: 0, isCompact: true),
                isInPreCountdown: Bool = true,
                isCompact: Bool = true) {
        self.workout = workout
        self.timerControlsState = timerControlsState
        self.segmentedProgressState = segmentedProgressState
        self.isInPreCountdown = isInPreCountdown
        self.timerSections = workout.segments.map { TimerSection.create(from: $0) }.flatMap { $0 }.dropLast()
        self.currentSection = currentSection ?? timerSections.first
    }
}

public struct RunningTimerEnvironment {
  
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var soundClient: SoundClient
    var notificationClient: LocalNotificationClient
    var timerStep: DispatchQueue.SchedulerTimeType.Stride

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        soundClient: SoundClient,
        notificationClient: LocalNotificationClient,
        timerStep: DispatchQueue.SchedulerTimeType.Stride = .seconds(1)
    ) {
        self.mainQueue = mainQueue
        self.soundClient = soundClient
        self.notificationClient = notificationClient
        self.timerStep = timerStep
    }
}

public let runningTimerReducer = Reducer<RunningTimerState, RunningTimerAction, RunningTimerEnvironment>.combine(
    Reducer { state, action, environment in
        struct TimerId: Hashable {}

        switch action {

        case .onAppear:
            state.updateSegments()
            return Effect(value: RunningTimerAction.timerControlsUpdatedState(.start))

        case .onActive:
            if state.isInPreCountdown {
                return Effect(value: RunningTimerAction.timerControlsUpdatedState(.start))
            }

        case .onBackground:
            return environment.notificationClient.scheduleLocalNotification(.timerPaused, .immediately)
                .map { _ in
                    RunningTimerAction.timerControlsUpdatedState(.pause)
                }

        case .timerControlsUpdatedState(let controlsAction):
            switch controlsAction {
            case .pause:
                return Effect<RunningTimerAction, Never>.cancel(id: TimerId())

            case .stop:
                return Effect(value: RunningTimerAction.alertButtonTapped)

            case .start:
                return Effect
                    .timer(id: TimerId(), every: environment.timerStep, tolerance: .zero, on: environment.mainQueue)
                    .map { _ in RunningTimerAction.timerTicked }
            }

        case .segmentedProgressAction:
            break

        case .timerTicked:
            if state.isInPreCountdown {
                state.preCountdownTimeLeft -= environment.timerStep.timeInterval.asDouble ?? 0
            } else {
                state.totalTimeLeft -= environment.timerStep.timeInterval.asDouble ?? 0
                state.sectionTimeLeft -= environment.timerStep.timeInterval.asDouble ?? 0
            }

            if state.isInPreCountdown && state.preCountdownTimeLeft <= 0 {
                return Effect(value: RunningTimerAction.preCountdownFinished)
            }

            if state.totalTimeLeft <= 0 {
                state.finishedSections += 1
                return Effect(value: RunningTimerAction.timerFinished)
            }

            if state.sectionTimeLeft <= 0, !state.isCurrentSegmentLast {
                return Effect(value: RunningTimerAction.sectionEnded)
            }

        case .preCountdownFinished:
            state.isInPreCountdown = false

        case .sectionEnded:
            state.moveToNextSection()
            return environment
                .soundClient
                .play(.segment)
                .fireAndForget()

        case .alertButtonTapped:
            state.alert = .init(
                title: "Stop workout?",
                message: "Are you sure you want to stop this workout?",
                primaryButton: .cancel(send: .timerControlsUpdatedState(.start)),
                secondaryButton: .default("Yes", send: .timerClosed)
            )
            return Effect(value: RunningTimerAction.timerControlsUpdatedState(.pause))

        case .timerFinished:
            state.finish()
            return Effect<RunningTimerAction, Never>
                .cancel(id: TimerId())
                .flatMap { _ in environment.soundClient.play(.segment).fireAndForget() }
                .eraseToEffect()

        case .timerClosed:
            state.isPresented = false
            return Effect(value: RunningTimerAction.timerFinished)

        case .finishedWorkoutAction(.didTapDoneButton):
            state.isPresented = false

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
        totalTimeLeft = TimeInterval(timerSections.map(\.duration).reduce(0, +))
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
        segmentedProgressState = SegmentedProgressState(totalSegments: progressSegmentsCount, filledSegments: 0, title: "Sections", isCompact: true)
        currentSection = timerSections.first
        calculateInitialTime()
    }

    mutating func finish() {
        finishedWorkoutState = FinishedWorkoutState(workout: workout)
        timerControlsState = TimerControlsState(timerState: .finished)
        alert = nil
    }

    var isCurrentSegmentLast: Bool {
        guard let section = currentSection, let index = timerSections.firstIndex(of: section) else { return true }
        return index == timerSections.count - 1
    }
}

private extension LocalNotificationClient.Content {
    static let timerPaused = LocalNotificationClient.Content(title: "Timer paused", message: "Timer has been paused. Open the app to continue workout")
}
