import AVFoundation
import ComposableArchitecture

public enum Sound {
    case segment
    case workout

    fileprivate var resource: (String, String)? {
        switch self {
        case .segment: return ("round_over", "m4a")
        case .workout: return ("applause", "mp3")
        }
    }
}

public struct SoundClient {
    public var play: (Sound) -> Effect<Never, Never>
}

private var player: AVAudioPlayer? = nil

public extension SoundClient {
    static let live = SoundClient { sound in
        .fireAndForget {
            if let resource = sound.resource,
               let bundle = Bundle(identifier: "com.tsonev.mobile.ios.CoreLogic"),
               let path = bundle.path(forResource: resource.0, ofType: resource.1) {
                
                let resource = URL(fileURLWithPath: path)
                
                try? AVAudioSession.sharedInstance().setCategory(.playback)
                try? AVAudioSession.sharedInstance().setActive(true)
                player = try? AVAudioPlayer(contentsOf: resource)
                player?.prepareToPlay()
                player?.play()
            }
        }
    }
    
    static let mock = SoundClient { sound in
        .fireAndForget {}
    }
}
