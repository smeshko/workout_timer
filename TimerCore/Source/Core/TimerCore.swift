import ComposableArchitecture

public enum TimerAction: Equatable {
    case start
    case stop
    case pause
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
    var soundClient: SoundClient
    
    public init(soundClient: SoundClient) {
        self.soundClient = soundClient
    }
}

public let timerReducer = Reducer<TimerState, TimerAction, TimerEnvironment> { state, action, _ in
    switch action {
        case .pause, .stop:
            state.isRunning = false
        
        case .start:
            state.isRunning = true
        
        case .changeSetsCount(let count):
            state.sets = count
            state.calculateInitialTime()
        
        case .changeBreakTime(let time):
            state.breakTime = time
            state.calculateInitialTime()
        
        case .changeWorkoutTime(let time):
            state.workoutTime = time
            state.calculateInitialTime()
    }
    
    return .none
}

private extension TimerState {
    mutating func calculateInitialTime() {
        totalTimeLeft = segments.map { $0.duration }.reduce(0, +)
        segmentTimeLeft = currentSegment?.duration ?? 0
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
