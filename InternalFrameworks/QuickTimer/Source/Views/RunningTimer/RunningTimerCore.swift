import Foundation
import ComposableArchitecture
import WorkoutCore
import CorePersistence

public enum RunningTimerAction: Equatable {
    case timerTicked
    case segmentEnded
    case timerFinished
    case didAppear
    case timerControlsUpdatedState(QuickTimerControlsAction)
}

public struct RunningTimerState: Equatable {
    var currentSection: TimerSection? = nil
    var totalTimeLeft: TimeInterval = 0
    var sectionTimeLeft: TimeInterval = 0
    var timerControlsState: QuickTimerControlsState
    var finishedSections: Int = 0
    var workout: QuickWorkout
    var timerSections: [TimerSection]

    public init(workout: QuickWorkout,
                currentSection: TimerSection? = nil,
                timerControlsState: QuickTimerControlsState = QuickTimerControlsState()) {
        self.workout = workout
        self.timerControlsState = timerControlsState
        self.timerSections = workout.segments.map { TimerSection.create(from: $0, isLast: false) }.flatMap { $0 }
        self.currentSection = currentSection ?? timerSections.first
    }
}

public struct RunningTimerEnvironment {
  
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var soundClient: SoundClient
    var uuid: () -> UUID
    var timerStep: DispatchQueue.SchedulerTimeType.Stride

    public init(
        uuid: @escaping () -> UUID,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        soundClient: SoundClient,
        timerStep: DispatchQueue.SchedulerTimeType.Stride = .seconds(1)
    ) {
        self.uuid = uuid
        self.mainQueue = mainQueue
        self.soundClient = soundClient
        self.timerStep = timerStep
    }
}

public let runningTimerReducer = Reducer<RunningTimerState, RunningTimerAction, RunningTimerEnvironment>.combine(
    Reducer { state, action, environment in
        struct TimerId: Hashable {}

        switch action {

        case .didAppear:
            state.updateSegments()
            return Effect(value: RunningTimerAction.timerControlsUpdatedState(.start))

        case .timerControlsUpdatedState(let controlsAction):
            switch controlsAction {
            case .pause:
                return Effect<RunningTimerAction, Never>.cancel(id: TimerId())

            case .stop:
                return Effect(value: RunningTimerAction.timerFinished)

            case .start:
                return Effect
                    .timer(id: TimerId(), every: environment.timerStep, tolerance: .zero, on: environment.mainQueue)
                    .map { _ in RunningTimerAction.timerTicked }
            }

        case .timerTicked:
            state.totalTimeLeft -= environment.timerStep.timeInterval.asDouble ?? 0
            state.sectionTimeLeft -= environment.timerStep.timeInterval.asDouble ?? 0
            
            if state.totalTimeLeft <= 0 {
                return Effect(value: RunningTimerAction.timerFinished)
            }

            if state.sectionTimeLeft <= 0, !state.isCurrentSegmentLast {
                return Effect(value: RunningTimerAction.segmentEnded)
            }

        case .segmentEnded:
            state.moveToNextSection()
            return environment
                .soundClient.play(.segment)
                .fireAndForget()

        case .timerFinished:
            state.reset()
            return Effect<RunningTimerAction, Never>
                .cancel(id: TimerId())
                .flatMap { _ in environment.soundClient.play(.segment).fireAndForget() }
                .eraseToEffect()
        }
        return .none
    },
    quickTimerControlsReducer.pullback(
        state: \.timerControlsState,
        action: /RunningTimerAction.timerControlsUpdatedState,
        environment: { _ in QuickTimerControlsEnvironment()}
    )
)

private extension RunningTimerState {
    mutating func calculateInitialTime() {
        totalTimeLeft = TimeInterval(workout.segments.map { $0.sets * ($0.pause + $0.work) }.reduce(0, +))
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
        currentSection = timerSections.first
        calculateInitialTime()
    }

    mutating func reset() {
        self = RunningTimerState(workout: QuickWorkout(id: UUID(), name: "", color: WorkoutColor(hue: 0, saturation: 0, brightness: 0), segments: []))
        currentSection = timerSections.first
        calculateInitialTime()
    }

    var isCurrentSegmentLast: Bool {
        guard let section = currentSection, let index = timerSections.firstIndex(of: section) else { return true }
        return index == timerSections.count - 1
    }
}

extension DispatchTimeInterval {
    var asDouble: Double? {
        var result: Double? = 0

        switch self {
        case .seconds(let value):
            result = Double(value)
        case .milliseconds(let value):
            result = Double(value)*0.001
        case .microseconds(let value):
            result = Double(value)*0.000001
        case .nanoseconds(let value):
            result = Double(value)*0.000000001
        case .never:
            result = nil
        @unknown default:
            fatalError()
        }

        return result
    }
}

public struct TimerSection: Equatable {
    enum SectionType {
        case work, pause
    }

    let duration: TimeInterval
    let type: SectionType

    static func create(from segment: QuickWorkoutSegment, isLast: Bool) -> [TimerSection] {
        var sections: [TimerSection] = []

        (0 ..< segment.sets).forEach { index in
            sections.append(TimerSection(duration: TimeInterval(segment.work), type: .work))
            if !(isLast && index == segment.sets - 1) {
                sections.append(TimerSection(duration: TimeInterval(segment.work), type: .pause))
            }
        }

        return sections
    }
}
