import SwiftUI

public extension View {
    func border(stroke: Color, width: CGFloat = 1, radius: CGFloat = CornerRadius.m) -> some View {
        overlay(RoundedRectangle(cornerRadius: radius).stroke(stroke, lineWidth: width))
    }

    func cardBackground() -> some View {
        padding(Spacing.l)
        .background(Color.appCardBackground)
        .cornerRadius(CornerRadius.m)
    }

    func fullWidth() -> some View {
        frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity)
    }

    func fullHeight() -> some View {
        frame(minHeight: 0, idealHeight: 100, maxHeight: .infinity)
    }
}
