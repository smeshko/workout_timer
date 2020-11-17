import SwiftUI

public struct TintColor: Identifiable, Equatable {
    public var id: String { name }
    public let name: String
    public let color: Color

    public static var allTints: [TintColor] {
        [
            TintColor(name: "Red Salsa", color: Color(red: 249 / 255, green: 65 / 255, blue: 68 / 255)),
            TintColor(name: "Orange red", color: Color(red: 243 / 255, green: 114 / 255, blue: 44 / 255)),
            TintColor(name: "Yellow Orange Color Wheel", color: Color(red: 248 / 255, green: 150 / 255, blue: 30 / 255)),
            TintColor(name: "Mango Tango", color: Color(red: 249 / 255, green: 132 / 255, blue: 74 / 255)),
            TintColor(name: "Maize Crayola", color: Color(red: 249 / 255, green: 199 / 255, blue: 79 / 255)),
            TintColor(name: "Pistachio", color: Color(red: 144 / 255, green: 190 / 255, blue: 109 / 255)),
            TintColor(name: "Zomp", color: Color(red: 67 / 255, green: 170 / 255, blue: 139 / 255)),
            TintColor(name: "Cadet Blue", color: Color(red: 77 / 255, green: 144 / 255, blue: 142 / 255)),
            TintColor(name: "Queen Blue", color: Color(red: 87 / 255, green: 117 / 255, blue: 144 / 255)),
            TintColor(name: "CG Blue", color: Color(red: 39 / 255, green: 125 / 255, blue: 161 / 255))
        ]
    }
}

public extension Array where Element == TintColor {
    subscript(_ color: Color) -> TintColor? {
        first { $0.color.description == color.description }
    }
}
