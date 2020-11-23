import SwiftUI
import ComposableArchitecture

struct PreCountdownView: View {
    private let store: Store<PreCountdownState, PreCountdownAction>
    @ObservedObject private var viewStore: ViewStore<PreCountdownState, PreCountdownAction>

    private let proxy = UIScreen.main.bounds
    private let origin: CGPoint

    @State var startAnimation = false

    init(store: Store<PreCountdownState, PreCountdownAction>, origin: CGPoint) {
        self.store = store
        self.origin = origin
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            Circle()
                .scaleEffect(5)
                .overlay(Text("\(viewStore.timeLeft.clean)")
                            .opacity(startAnimation ? 1 : 0)
                            .foregroundColor(.white)
                            .font(.system(size: 72, weight: .heavy, design: .monospaced))
                            .animation(Animation.easeInOut(duration: 0.6))
                )
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .foregroundColor(viewStore.workoutColor.color)
                .transition(
                    AnyTransition.asymmetric(
                        insertion: .scale(scale: 0, anchor: .init(x: origin.x / proxy.size.width, y: origin.y / proxy.size.height)),
                        removal: .scale(scale: 0, anchor: .center)
                    )
                )

                .onAppear {
                    withAnimation {
                        viewStore.send(.onAppear)
                        startAnimation = true
                    }
                }
                .onDisappear {
                    withAnimation {
                        startAnimation = false
                    }
                }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}
struct PrecountdownView_Previews: PreviewProvider {
    static var previews: some View {
        PreCountdownView(
            store: Store<PreCountdownState, PreCountdownAction>(
                initialState: PreCountdownState(workoutColor: .empty),
                reducer: preCountdownReducer,
                environment: PreCountdownEnvironment()
            ),
            origin: .zero
        )
    }
}

private extension TimeInterval {
    var clean: String {
        guard self >= 0 else { return String(format: "%.0f", 0) }
        return String(format: "%.0f", self)
    }
}
