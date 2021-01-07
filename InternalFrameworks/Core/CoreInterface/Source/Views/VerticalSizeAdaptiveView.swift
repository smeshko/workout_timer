import SwiftUI

public struct VerticalSizeAdaptiveView<Content: View>: View {

    private let content: Content
    private let spacing: CGFloat?

    public init(spacing: CGFloat? = nil, @ViewBuilder _ content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    @Environment(\.verticalSizeClass) private var verticalSizeClass: UserInterfaceSizeClass?

    public var body: some View {
        if verticalSizeClass == .compact {
            VStack(spacing: Spacing.l) {
                content
            }
        } else {
            HStack(spacing: Spacing.l) {
                content
            }
        }
    }
}

struct VerticalSizeAdaptiveView_Previews: PreviewProvider {
    static var previews: some View {
        VerticalSizeAdaptiveView {
            Text("")
        }
    }
}
