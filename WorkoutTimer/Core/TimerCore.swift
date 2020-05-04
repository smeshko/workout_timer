import ComposableArchitecture

enum TimerAction: Equatable {
    case start
    case stop
    case pause
    case changeSetsCount(Int)
    case changeBreakTime(Int)
    case changeWorkoutTime(Int)
    
}

struct TimerState: Equatable {
    var isRunning: Bool = false
    var segments: [Segment] = []
    var currentSegment: Segment? = nil
    var sets: Int = 0
    var workoutTime: Int = 0
    var breakTime: Int = 0
    var totalTimeLeft: Int = 0
    var segmentTimeLeft: Int = 0
}

struct TimerEnvironment {
    var soundClient: SoundClient
}

let timerReducer = Reducer<TimerState, TimerAction, TimerEnvironment> { state, action, _ in
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
