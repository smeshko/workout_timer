import SwiftUI

public struct ActivityIndicator: UIViewRepresentable {
    
    @Binding private var isAnimating: Bool
    
    public init(isAnimating: Binding<Bool>) {
        self._isAnimating = isAnimating
    }
    
    public func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        UIActivityIndicatorView(style: .medium)
    }
    
    public func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
