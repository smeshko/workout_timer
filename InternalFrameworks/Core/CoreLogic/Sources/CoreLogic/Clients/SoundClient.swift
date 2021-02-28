import AVFoundation
import Foundation
import ComposableArchitecture

public enum Sound {
    case segment
    case workout

   fileprivate var systemId: Int? {
        switch self {
        case .segment: return 1008
        default: return nil
        }
    }

    fileprivate var resource: (String, String)? {
        switch self {
        case .workout: return ("applause", "mp3")
        default: return nil
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
            #if os(iOS)
            if let id = sound.systemId {
                AudioServicesPlaySystemSound(SystemSoundID(id))
            } else if let resource = sound.resource,
                      let bundle = Bundle(identifier: "com.tsonev.mobile.ios.CoreLogic"),
                      let path = bundle.path(forResource: resource.0, ofType: resource.1) {
                play(at: path)
            }
            #endif
        }
    }
    
    static let mock = SoundClient { sound in
        .fireAndForget {}
    }

    private static func play(at path: String) {
        let resource = URL(fileURLWithPath: path)

        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        player = try? AVAudioPlayer(contentsOf: resource)
        player?.prepareToPlay()
        player?.play()
    }
}
