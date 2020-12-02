import SwiftUI

public extension View {
    func border(stroke: Color, width: CGFloat = 1, radius: CGFloat = CornerRadius.m) -> some View {
        overlay(RoundedRectangle(cornerRadius: radius).stroke(stroke, lineWidth: width))
    }
}
