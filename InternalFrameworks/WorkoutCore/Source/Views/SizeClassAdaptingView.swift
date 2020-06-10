import SwiftUI

public struct SizeClassAdaptingView<Content>: View where Content: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    private let content: Content
    private let spacing: CGFloat?
    private let compactAxis: Axis
    private let regularAxis: Axis
    
    public init(spacing: CGFloat? = nil,
                _ compactAxis: Axis = .vertical,
                _ regularAxis: Axis = .horizontal,
                @ViewBuilder content: () -> Content) {
        self.content = content()
        self.spacing = spacing
        self.compactAxis = compactAxis
        self.regularAxis = regularAxis
    }
    
    public var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                if compactAxis == .vertical {
                    VStack(spacing: spacing, content: { content })
                } else {
                    HStack(spacing: spacing, content: { content })
                }
            } else {
                if regularAxis == .horizontal {
                    HStack(spacing: spacing, content: { content })
                } else {
                    VStack(spacing: spacing, content: { content })
                }
            }
        }
    }
}
