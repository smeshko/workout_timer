import SwiftUI

#if !os(watchOS)
public struct ContextMenuView<Content: View, Preview: View>: UIViewRepresentable, KeyPathUpdateable {

    private let content: Content
    private let previewProvider: () -> Preview?

    private var actionProvider: () -> UIMenu? = { nil }
    private var onPreviewTap: () -> Void = {}

    public init(@ViewBuilder _ content: () -> Content,
                             previewProvider: @escaping () -> Preview?) {
        self.content = content()
        self.previewProvider = previewProvider
    }

    public func actionProvider(_ provider: @escaping () -> UIMenu?) -> Self {
        update(\.actionProvider, value: provider)
    }

    public func onPreviewTap(_ action: @escaping () -> Void) -> Self {
        update(\.onPreviewTap, value: action)
    }

    public func makeUIView(context: Context) -> CustomView<Content> {
        let view = CustomView<Content>(frame: .zero)
        let interaction = UIContextMenuInteraction(delegate: context.coordinator)
        view.addInteraction(interaction)
        view.setup(with: content)
        return view
    }

    public func updateUIView(_ uiView: CustomView<Content>, context: Context) {
        context.coordinator.actionProvider = actionProvider
        context.coordinator.previewProvider = previewProvider
        context.coordinator.onPreviewTap = onPreviewTap

        uiView.setup(with: content)
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(actionProvider: actionProvider, previewProvider: previewProvider, onPreviewTap: onPreviewTap)
    }

    public class Coordinator: NSObject, UIContextMenuInteractionDelegate {
        fileprivate var actionProvider: () -> UIMenu?
        fileprivate var previewProvider: () -> Preview?
        fileprivate var onPreviewTap: () -> Void

        fileprivate init(actionProvider: @escaping () -> UIMenu?,
                         previewProvider: @escaping () -> Preview?,
                         onPreviewTap: @escaping () -> Void) {
            self.actionProvider = actionProvider
            self.previewProvider = previewProvider
            self.onPreviewTap = onPreviewTap
        }

        public func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                           willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                                           animator: UIContextMenuInteractionCommitAnimating) {
            animator.addCompletion(onPreviewTap)
        }

        public func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            return UIContextMenuConfiguration(
                identifier: nil,
                previewProvider: {
                    guard let preview = self.previewProvider() else { return nil }
                    let hosting = UIHostingController(rootView: preview)
                    return hosting
                },
                actionProvider: { _ in
                    self.actionProvider()
            })
        }
    }
}

public class CustomView<Content: View>: UIView {
    var host: UIHostingController<Content>?

    func setup(with view: Content) {
        if host == nil {
            let controller = UIHostingController(rootView: view)
            host = controller

            guard let content = controller.view else { return }
            content.translatesAutoresizingMaskIntoConstraints = false
            addSubview(content)

            content.topAnchor.constraint(equalTo: topAnchor).isActive = true
            content.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            content.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            content.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        } else {
            host?.rootView = view
        }
        setNeedsLayout()
    }
}
#endif
