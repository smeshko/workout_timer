import ComposableArchitecture
import Foundation
import Combine

public enum TimerAction: Equatable {
    case start
    case stop
    case pause
    case timerTicked
    case segmentEnded
    case timerFinished
    case changeSetsCount(Int)
    case changeBreakTime(Int)
    case changeWorkoutTime(Int)
}

public struct TimerState: Equatable {
    var isRunning: Bool = false
    var segments: [Segment] = []
    var currentSegment: Segment? = nil
    var sets: Int = 0
    var workoutTime: Int = 0
    var breakTime: Int = 0
    var totalTimeLeft: Int = 0
    var segmentTimeLeft: Int = 0
    
    public init(isRunning: Bool = false,
                segments: [Segment] = [],
                currentSegment: Segment? = nil,
                sets: Int = 0,
                workoutTime: Int = 0,
                breakTime: Int = 0,
                totalTimeLeft: Int = 0,
                segmentTimeLeft: Int = 0) {
        self.isRunning = isRunning
        self.segments = segments
        self.currentSegment = currentSegment
        self.sets = sets
        self.workoutTime = workoutTime
        self.breakTime = breakTime
        self.totalTimeLeft = totalTimeLeft
        self.segmentTimeLeft = segmentTimeLeft
    }
}

public struct TimerEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var soundClient: SoundClient
    
    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        soundClient: SoundClient
    ) {
        self.mainQueue = mainQueue
        self.soundClient = soundClient
    }
}

public let timerReducer = Reducer<TimerState, TimerAction, TimerEnvironment> { state, action, environment in
    struct TimerId: Hashable {}
    
    switch action {
        case .pause, .stop:
            state.isRunning = false
        
        case .start:
            state.isRunning = true
            state.createSegments()
            state.currentSegment = state.segments.first
            state.calculateInitialTime()
            
            return Effect
                .timer(id: TimerId(), every: 1, tolerance: .zero, on: environment.mainQueue)
                .map { _ in TimerAction.timerTicked }
        
        case .changeSetsCount(let count):
            state.sets = count
            state.calculateInitialTime()
        
        case .changeBreakTime(let time):
            state.breakTime = time
            state.calculateInitialTime()
        
        case .changeWorkoutTime(let time):
            state.workoutTime = time
            state.calculateInitialTime()
        
        case .timerTicked:
            state.totalTimeLeft -= 1
            state.segmentTimeLeft -= 1
            
            if state.totalTimeLeft <= 0 {
                return Effect(value: TimerAction.timerFinished)
            }
        
            if state.segmentTimeLeft == 0, !state.isCurrentSegmentLast {
                return Effect(value: TimerAction.segmentEnded)
            }

        case .segmentEnded:
            state.moveToNextSegment()
            return environment
                .soundClient.play(.segment)
                .fireAndForget()

        
        case .timerFinished:
            state.reset()
            return Effect<TimerAction, Never>.cancel(id: TimerId())
    }
    
    return .none
}

private extension TimerState {
    mutating func calculateInitialTime() {
        totalTimeLeft = sets * workoutTime + (sets - 1) * breakTime
        segmentTimeLeft = currentSegment?.duration ?? 0
    }
    
    mutating func moveToNextSegment() {
        guard let segment = currentSegment, let index = segments.firstIndex(of: segment), index != segments.count - 1 else { return }
        currentSegment = segments[index + 1]
        segmentTimeLeft = currentSegment?.duration ?? 0
    }
    
    mutating func createSegments() {
        segments = []
        
        (0 ..< sets).enumerated().forEach { index, _ in
            segments.append(Segment(duration: workoutTime, category: .workout))
            if index != sets - 1 {
                segments.append(Segment(duration: breakTime, category: .pause))
            }
        }
    }
    
    mutating func reset() {
        self = TimerState()
    }
    
    var isCurrentSegmentLast: Bool {
        guard let segment = currentSegment, let index = segments.firstIndex(of: segment) else { return true }
        return index == segments.count - 1
    }
}

extension TimerState {
    
    var formattedTotalTimeLeft: String {
        String(format: "%02d:%02d", totalTimeLeft / 60, totalTimeLeft % 60)
    }
    
    var formattedSegmentTimeLeft: String {
        String(format: "%02d:%02d", segmentTimeLeft / 60, segmentTimeLeft % 60)
    }

}
