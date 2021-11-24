import Foundation

public extension TimeInterval {
    var formattedTimeLeft: String {
        Int(ceil(self)).formattedTimeLeft
    }
}

public extension Int {
    var formattedTimeLeft: String {
        String(format: "%02i:%02i", self / 60, self % 60)
    }
}
