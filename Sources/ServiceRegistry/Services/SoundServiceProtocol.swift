import Foundation

public enum Sound {
    case segment
    case workout
}

public protocol SoundServiceProtocol {
    func play(_ sound: Sound) async
}
