import UIKit
import DomainEntities
import SwiftUI

public struct ColorComponents: Equatable {
    public let hue: Double
    public let brightness: Double
    public let saturation: Double

    public init(hue: Double, brightness: Double, saturation: Double) {
        self.hue = hue
        self.brightness = brightness
        self.saturation = saturation
    }

    public init(color: Color) {
        let components = color.hsbComponents()
        self.init(hue: components.h, brightness: components.b, saturation: components.s)
    }
}

public extension UIColor {
    func hsbComponents() -> (h: Double, s: Double, b: Double) {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getHue(&h, saturation: &s, brightness: &b, alpha: &a)

        return (Double(h), Double(s), Double(b))
    }
}

public extension Color {
    func hsbComponents() -> (h: Double, s: Double, b: Double) {
        UIColor(self).hsbComponents()
    }
}

public extension WorkoutColor {
    convenience init(components: ColorComponents) {
        self.init(hue: components.hue, saturation: components.saturation, brightness: components.brightness)
    }

    convenience init(color: Color) {
        let components = color.hsbComponents()
        self.init(hue: components.h, saturation: components.s, brightness: components.b)
    }

    var color: Color {
        Color(hue: hue, saturation: saturation, brightness: brightness)
    }
}
