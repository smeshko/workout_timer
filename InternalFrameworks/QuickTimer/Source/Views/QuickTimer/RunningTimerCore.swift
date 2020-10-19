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
    var segments: [QuickTimerSet] = []
    var currentSegment: QuickTimerSet.Segment? = nil
    var totalTimeLeft: TimeInterval = 0
    var segmentTimeLeft: TimeInterval = 0
    var timerControlsState: QuickTimerControlsState
    var finishedSegments: Int = 0

    public init(segments: [QuickTimerSet] = [],
                currentSegment: QuickTimerSet.Segment? = nil,
                timerControlsState: QuickTimerControlsState = QuickTimerControlsState()) {
        self.segments = segments
        self.currentSegment = currentSegment
        self.timerControlsState = timerControlsState
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
            state.segmentTimeLeft -= environment.timerStep.timeInterval.asDouble ?? 0
            
            if state.totalTimeLeft <= 0 {
                return Effect(value: RunningTimerAction.timerFinished)
            }

            if state.segmentTimeLeft <= 0, !state.isCurrentSegmentLast {
                return Effect(value: RunningTimerAction.segmentEnded)
            }

        case .segmentEnded:
            state.moveToNextSegment()
            return environment
                .soundClient.play(.segment)
                .fireAndForget()

        case .timerFinished:
            state.reset()
            return Effect<QuickTimerAction, Never>
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
        totalTimeLeft = segments.map { $0.duration }.reduce(0, +)
        segmentTimeLeft = currentSegment?.duration ?? 0
    }

    mutating func moveToNextSegment() {
        guard let segment = currentSegment, let currentSet = segments[segment], let index = segments.firstIndex(of: segment) else { return }
        if segment.category == .workout {
            currentSegment = currentSet.pause
            finishedSegments += 1
        } else {
            if let newSet = segments[safe: index + 1] {
                currentSegment = newSet.work
            }
        }
        segmentTimeLeft = currentSegment?.duration ?? 0
    }

    mutating func updateSegments() {
        currentSegment = segments.first?.work
        calculateInitialTime()
    }

    mutating func reset() {
        self = RunningTimerState()
        currentSegment = segments.first?.work
        calculateInitialTime()
    }

    var isCurrentSegmentLast: Bool {
        guard let segment = currentSegment, let index = segments.firstIndex(of: segment) else { return true }
        return index == segments.count - 1
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
