import Foundation
import ServiceRegistry
import AVFoundation

public class SoundService: SoundServiceProtocol {

    private let session: AudioSession
    private var player: AudioPlayer?

    public init() {
        session = AVAudioSession.sharedInstance()
    }

    init(session: AudioSession, player: AudioPlayer) {
        self.session = session
        self.player = player
    }

    public func play(_ sound: Sound) async {
        if let resource = sound.resource,
           let path = Bundle.module.path(forResource: resource.0, ofType: resource.1) {
            let resource = URL(fileURLWithPath: path)

            try? session.set(category: .ambient)
            try? session.activate()
            player = try? AVAudioPlayer(contentsOf: resource)
            player?.prepare()
            player?.start()
        }
    }
}

protocol AudioPlayer {
    init(contentsOf: URL) throws
    func prepare()
    func start()
}

enum AudioCategory {
    case ambient

    var avfCategory: AVAudioSession.Category {
        switch self {
        case .ambient: return .ambient
        }
    }
}

protocol AudioSession {
    func set(category: AudioCategory) throws
    func activate() throws
}

extension AVAudioSession: AudioSession {
    func set(category: AudioCategory) throws {
        try setCategory(category.avfCategory)
    }

    func activate() throws {
        try setActive(true, options: .notifyOthersOnDeactivation)
    }
}

extension AVAudioPlayer: AudioPlayer {

    func prepare() {
        prepareToPlay()
    }

    func start() {
        play()
    }
}

extension Sound {
    var resource: (String, String)? {
        switch self {
        case .segment: return ("round_over", "m4a")
        case .workout: return ("applause", "mp3")
        }
    }
}
