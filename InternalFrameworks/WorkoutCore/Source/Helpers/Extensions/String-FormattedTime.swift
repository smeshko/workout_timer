import Foundation

public extension TimeInterval {
  var formattedTimeLeft: String {
    Int(self).formattedTimeLeft
  }
}

public extension Int {
  var formattedTimeLeft: String {
    String(format: "%02d:%02d", self / 60, self % 60)
  }
}
