import SwiftUI

public extension View {
    /// Applies the given font and foreground color to the View.
    /// - Parameters:
    ///   - font: the font to apply to the view
    ///   - color: the color to apply to the view. Defaults to `appText`
    func styling(font: Font, color: Color = .appText) -> some View {
        self
            .font(font)
            .foregroundColor(color)
    }
}
