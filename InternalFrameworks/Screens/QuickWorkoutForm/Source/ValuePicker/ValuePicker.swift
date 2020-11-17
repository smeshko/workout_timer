import SwiftUI
import ComposableArchitecture
import CoreInterface

struct ValuePicker: View {

    let store: Store<PickerState, PickerAction>
    let viewStore: ViewStore<PickerState, PickerAction>
    let valueName: String

    @State private var contentOffset: CGPoint = .zero

    private var allNumbers: [Int] = []
    private let tint: Color
    private let textHeight = 20
    private let shouldUseScrollView: Bool

    public init(store: Store<PickerState, PickerAction>,
                shouldUseScrollView: Bool = false,
                maxCount: Int,
                valueName: String,
                tint: Color) {
        self.allNumbers = Array(0...maxCount)
        self.tint = tint
        self.shouldUseScrollView = shouldUseScrollView
        self.store = store
        self.valueName = valueName
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !shouldUseScrollView {
                TextField(valueName, text: viewStore.binding(get: \.stringValue, send: PickerAction.stringValueUpdated))
                    .font(.h2)
                    .keyboardType(.numberPad)

                Text(valueName)
                    .foregroundColor(tint)
                    .font(.label)
            } else {
                ScrollView(contentOffset: $contentOffset) {
                    ForEach(viewStore.allNumbers, id: \.self) { number in
                        Text("\(number)")
                            .id(number)
                            .frame(height: CGFloat(textHeight))
                            .font(viewStore.value == number ? .h2 : .h3)
                            .foregroundColor(viewStore.value == number ? tint : .appGrey)
                    }
                }
                .onDecelerate(onScrollViewStopMoving)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(tint, lineWidth: 2))
                .frame(width: 50, height: 40)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        onScrollViewStopMoving(CGPoint(x: 0, y: CGFloat(viewStore.value * textHeight)))
                    }
                }

                Text(valueName)
                    .font(.label)
                    .foregroundColor(.appText)
            }
        }
    }

    private func onScrollViewStopMoving(_ point: CGPoint) {
        let times = Int(point.y) / textHeight
        contentOffset = CGPoint(x: point.x, y: CGFloat(times * textHeight))
        viewStore.send(.valueUpdated(Int(abs(point.y)) / textHeight))
    }
}

struct ValuePicker_Previews: PreviewProvider {
    static var previews: some View {

        let store = Store<PickerState, PickerAction>(
            initialState: PickerState(),
            reducer: pickerReducer,
            environment: PickerEnvironment()
        )

        return Group {
            ValuePicker(store: store, maxCount: 20, valueName: "Sets", tint: .appSuccess)
                .padding()
                .previewLayout(.sizeThatFits)

            ValuePicker(store: store, maxCount: 20, valueName: "Sets", tint: .appSuccess)
                .preferredColorScheme(.dark)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
}

private struct ScrollView<Content: View>: UIViewRepresentable {

    private var onDecelerate: (CGPoint) -> Void = { _ in }
    private var onContentOffsetChange: (CGPoint) -> Void = { _ in }
    private var content: Content

    private let axis: Axis
    private let scrollView: UIScrollView

    private var contentOffset: Binding<CGPoint>

    init(axis: Axis = .vertical, contentOffset: Binding<CGPoint>, @ViewBuilder _ content: () -> Content) {
        self.content = content()
        self.axis = axis
        self.scrollView = UIScrollView()
        self.contentOffset = contentOffset
    }

    func onDecelerate(_ action: @escaping (CGPoint) -> Void) -> Self {
        var copy = self
        copy.onDecelerate = action
        return copy
    }

    func onContentOffsetChange(_ action: @escaping (CGPoint) -> Void) -> Self {
        var copy = self
        copy.onContentOffsetChange = action
        return copy
    }

    func makeUIView(context: Context) -> UIScrollView {
        scrollView.delegate = context.coordinator
        scrollView.contentOffset = contentOffset.wrappedValue
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        updateContent(of: scrollView)
        return scrollView
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(offset: contentOffset, onDecelerate: onDecelerate, onContentOffsetChange: onContentOffsetChange)
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        print("ScrollView updateUIView")
        updateContent(of: uiView)

        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .curveEaseInOut, .beginFromCurrentState], animations: {
            uiView.contentOffset = contentOffset.wrappedValue
        })
    }

    private func updateContent(of scrollView: UIScrollView) {
        scrollView.subviews.forEach { $0.removeFromSuperview() }

        let hosting = UIHostingController(rootView: content)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(hosting.view)
        scrollView.constraints.forEach { scrollView.removeConstraint($0) }

        let constraints: [NSLayoutConstraint]
        switch self.axis {
        case .horizontal:
            constraints = [
                hosting.view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
                hosting.view.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
                hosting.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
                hosting.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                hosting.view.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
            ]
        case .vertical:
            constraints = [
                hosting.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                hosting.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                hosting.view.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 10),
                hosting.view.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -10),
                hosting.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
            ]
        }
        scrollView.addConstraints(constraints)
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var onDecelerate: (CGPoint) -> Void
        var onContentOffsetChange: (CGPoint) -> Void
        private let offset: Binding<CGPoint>

        init(offset: Binding<CGPoint>, onDecelerate: @escaping (CGPoint) -> Void, onContentOffsetChange: @escaping (CGPoint) -> Void) {
            self.offset = offset
            self.onDecelerate = onDecelerate
            self.onContentOffsetChange = onContentOffsetChange
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            DispatchQueue.main.async {
                self.onDecelerate(scrollView.contentOffset)
            }
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            DispatchQueue.main.async {
                self.onContentOffsetChange(scrollView.contentOffset)
            }
        }

        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            DispatchQueue.main.async {
                self.onDecelerate(scrollView.contentOffset)
            }
        }
    }
}

private struct StepperInput: View {
    let store: Store<PickerState, PickerAction>
    let viewStore: ViewStore<PickerState, PickerAction>
    let name: String
    let tint: Color

    init(store: Store<PickerState, PickerAction>, name: String, tint: Color) {
        self.store = store
        self.viewStore = ViewStore(store)
        self.name = name
        self.tint = tint
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 8) {
                FastForwardButton {
                    viewStore.send(.valueUpdated(viewStore.value - 1))
                } buttonContent: {
                    Image(systemName: "minus")
                        .font(.bodySmall)
                        .foregroundColor(tint)
                }

                Text("\(viewStore.value)")
                    .font(.h2)

                FastForwardButton {
                    viewStore.send(.valueUpdated(viewStore.value + 1))
                } buttonContent: {
                    Image(systemName: "plus")
                        .font(.bodySmall)
                        .foregroundColor(tint)
                }
            }
            Text(name)
                .foregroundColor(tint)
                .font(.label)
        }
    }
}
