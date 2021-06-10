import Foundation

public class WorkoutColor: NSObject, NSCoding {
    public let hue: Double
    public let saturation: Double
    public let brightness: Double

    public init(hue: Double, saturation: Double, brightness: Double) {
        self.hue = hue
        self.brightness = brightness
        self.saturation = saturation
    }

    required public init?(coder: NSCoder) {
        hue = coder.decodeDouble(forKey: "hue")
        saturation = coder.decodeDouble(forKey: "saturation")
        brightness = coder.decodeDouble(forKey: "brightness")
    }

    public func encode(with coder: NSCoder) {
        coder.encode(hue, forKey: "hue")
        coder.encode(saturation, forKey: "saturation")
        coder.encode(brightness, forKey: "brightness")
    }

    public static var empty: WorkoutColor {
        WorkoutColor(hue: 0, saturation: 0, brightness: 0)
    }
}
