import Combine
import Foundation

public class TimerViewModel: ObservableObject {
    
    @Published var timeLeft: String = "00:00"
    @Published var sets: String = "0" { didSet { updateTimeLeft(totalTime) } }
    @Published var breakTime: String = "0" { didSet { updateTimeLeft(totalTime) } }
    @Published var workoutTime: String = "0" { didSet { updateTimeLeft(totalTime) } }
    
    private var totalTime: Int {
        guard let workoutInt = Int(workoutTime), let setsInt = Int(sets), let breakInt = Int(breakTime) else { return 0 }
        return (workoutInt + breakInt) * setsInt
    }
    
    public func begin() {
        var totalTime = self.totalTime
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            totalTime -= 1
            self.updateTimeLeft(totalTime)
        }
    }
    
    private func updateTimeLeft(_ timeLeft: Int) {
        let minutes = timeLeft / 60
        let seconds = timeLeft % 60
        
        self.timeLeft = String(format: "%02d:%02d", minutes, seconds)
    }
}
