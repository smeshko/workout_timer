import Foundation
import SwiftUI
import ComposableArchitecture

public struct ConfettiState: Equatable {

    var color: Color
    var rainHeight: CGFloat
    var openingAngle: Angle
    var closingAngle: Angle
    var radius: CGFloat
    var explosionAnimationDuration: Double
    var rainAnimationDuration: Double

    var animationDuration:Double{
        explosionAnimationDuration + rainAnimationDuration
    }

    init(color: Color = .blue,
         rainHeight: CGFloat = 600,
         openingAngle: Angle = .degrees(60),
         closingAngle: Angle = .degrees(120),
         radius: CGFloat = 300
    ) {
        self.color = color
        self.rainHeight = rainHeight
        self.openingAngle = openingAngle
        self.closingAngle = closingAngle
        self.radius = radius
        self.explosionAnimationDuration = Double(radius / 1500)
        self.rainAnimationDuration = Double((rainHeight + radius) / 300)
    }
}

public struct ConfettiEnvironment {
    public init() {}
}

public let confettiReducer = Reducer<ConfettiState, Never, ConfettiEnvironment>.empty
