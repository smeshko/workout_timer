import AVFoundation

public enum Sound: Int {
    case segment = 1008
}

public protocol SoundServiceProtocol {
    func play(_ sound: Sound)
}

public class SoundService: SoundServiceProtocol {
    
    public init() {}
    
    public func play(_ sound: Sound) {
        AudioServicesPlaySystemSound(SystemSoundID(sound.rawValue))
    }
}
