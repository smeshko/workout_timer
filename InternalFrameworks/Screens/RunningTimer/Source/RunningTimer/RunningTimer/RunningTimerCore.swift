import Foundation
import UIKit
import CoreInterface
import ComposableArchitecture
import CoreLogic
import DomainEntities

enum Phase {
    case countdown
    case timer
    case finished
}

public enum RunningTimerAction: Equatable {
    case timerControlsUpdatedState(TimerControlsAction)
    case segmentedProgressAction(SegmentedProgressAction)
    case finishedWorkoutAction(FinishedWorkoutAction)
    case preCountdownAction(PreCountdownAction)

    case timerTicked
    case timerFinished
    case timerClosed

    case onAppear
    case onActive
    case onBackground
    case onSizeClassChange(isCompact: Bool)

    case sectionEnded

    case alertButtonTapped
    case alertCancelTapped
    case alertDismissed
}

public struct RunningTimerState: Equatable {
    var precountdownState: PreCountdownState?
    var phase: Phase = .countdown

    var currentSection: TimerSection? = nil
    var totalTimeLeft: TimeInterval = 0
    var sectionTimeLeft: TimeInterval = 0
    var timerControlsState: TimerControlsState
    var segmentedProgressState = SegmentedProgressState(totalSegments: 0)
    var finishedSections: Int = 0
    var workout: QuickWorkout
    var timerSections: [TimerSection]
    var alert: AlertState<RunningTimerAction>?
    var isPresented = true
    var isCompact = true
    var finishedWorkoutState: FinishedWorkoutState?

    var progressSegmentsCount: Int {
        timerSections.filter { $0.type == .work }.count
    }

    public init(workout: QuickWorkout,
                currentSection: TimerSection? = nil,
                timerControlsState: TimerControlsState = TimerControlsState(),
                isCompact: Bool = true) {
        self.workout = workout
        self.timerControlsState = timerControlsState
        self.precountdownState = PreCountdownState(workoutColor: workout.color)
        self.timerSections = workout.segments.map { TimerSection.create(from: $0) }.flatMap { $0 }.dropLast()
        self.currentSection = currentSection ?? timerSections.first
        self.isCompact = isCompact
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
    Reducer { state, action, environment in
        struct TimerId: Hashable {}
        let id = TimerId()

        switch action {

        case .onAppear:
            state.updateSegments()

        case .preCountdownAction(.finished):
            state.precountdownState = nil
            state.phase = .timer
            return Effect(value: RunningTimerAction.timerControlsUpdatedState(.start))

        case .onSizeClassChange(let compact):
            state.isCompact = compact

        case .onBackground:
            return environment.notificationClient.scheduleLocalNotification(.timerPaused, .immediately)
                .map { _ in
                    RunningTimerAction.timerControlsUpdatedState(.pause)
                }

        case .timerControlsUpdatedState(let controlsAction):
            switch controlsAction {
            case .pause:
                return Effect<RunningTimerAction, Never>.cancel(id: id)

            case .stop:
                return Effect(value: RunningTimerAction.alertButtonTapped)

            case .start:
                return Effect
                    .timer(id: id, every: environment.timerStep, tolerance: .zero, on: environment.mainQueue())
                    .map { _ in RunningTimerAction.timerTicked }
            }

        case .segmentedProgressAction:
            break

        case .timerTicked:
            state.totalTimeLeft -= environment.timerStep.timeInterval.asDouble ?? 0
            state.sectionTimeLeft -= environment.timerStep.timeInterval.asDouble ?? 0

            if state.totalTimeLeft <= 0 {
                state.finishedSections += 1
                return Effect(value: RunningTimerAction.timerFinished)
            }

            if state.sectionTimeLeft <= 0, !state.isCurrentSegmentLast {
                return Effect(value: RunningTimerAction.sectionEnded)
            }

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
        segmentedProgressState = SegmentedProgressState(totalSegments: progressSegmentsCount, filledSegments: 0, title: "Sections", isCompact: isCompact)
        currentSection = timerSections.first
        calculateInitialTime()
    }

    mutating func finish() {
        finishedWorkoutState = FinishedWorkoutState(workout: workout)
        timerControlsState = TimerControlsState(timerState: .finished)
        phase = .finished
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
