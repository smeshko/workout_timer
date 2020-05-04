import AVFoundation
import ComposableArchitecture

public enum Sound: Int {
    case segment = 1008
}

public struct SoundClient {
    var play: (Sound) -> Effect<Never, Never>
}

public extension SoundClient {
    static let live = SoundClient { sound in
        .fireAndForget {
            AudioServicesPlaySystemSound(SystemSoundID(sound.rawValue))
        }
    }
    
    static let mock = SoundClient { sound in
        .fireAndForget {
            print("Chosen sound id: \(sound.rawValue)")
        }
    }
}
