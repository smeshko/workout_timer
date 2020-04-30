import Combine
import Foundation

public enum SegmentType {
    case workout
    case pause
}

public class TimerViewModel: ObservableObject {
    
    @Published var timeLeft: String = "00:00"
    @Published var currentSegmentType: SegmentType = .workout
    @Published var currentSegmentTimeLeft: String = "00:00"
    
    @Published var workoutTime: Int = 0 { didSet { updateSegments() } }
    @Published var breakTime: Int = 0 { didSet { updateSegments() } }
    @Published var sets: Int = 0 { didSet { updateSegments() } }

    private var totalTime: Int {
        segments.map { $0.duration }.reduce(0, +)
    }
    
    private var segments: [Segment] = []
    private var currentSegment: Segment?
    
    private let soundService: SoundServiceProtocol
    
    public init(soundService: SoundServiceProtocol = SoundService()) {
        self.soundService = soundService
    }
    
    public func begin() {
        var currentSegmentIndex = 0
        currentSegment = segments.first
        
        var totalTime = self.totalTime
        guard var segmentTime = currentSegment?.duration else { return }
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            totalTime -= 1
            segmentTime -= 1
            
            if segmentTime == 0, currentSegmentIndex != self.segments.count - 1 {
                currentSegmentIndex += 1
                self.currentSegment = self.segments[currentSegmentIndex]
                segmentTime = self.currentSegment!.duration
                self.soundService.play(.segment)
            }
            
            if totalTime == 0 { timer.invalidate() }
            self.updateTimeLeft(total: totalTime, segment: segmentTime)
        }
    }
}

private extension TimerViewModel {
    
    func updateSegments() {
        segments = []
        
        (0 ..< sets).forEach { _ in
            segments.append(Segment(duration: workoutTime, category: .workout))
            segments.append(Segment(duration: breakTime, category: .pause))
        }
    }
    
    func updateTimeLeft(total: Int, segment: Int) {
        timeLeft = formatTimeLeft(total)
        currentSegmentTimeLeft = formatTimeLeft(segment)
    }

    func formatTimeLeft(_ time: Int) -> String {
        String(format: "%02d:%02d", time / 60, time % 60)
    }
}

private extension Segment.Category {
    var toType: SegmentType {
        switch self {
            case .pause: return .pause
            case .workout: return .workout
        }
    }
}
