import SwiftUI
import ComposableArchitecture

struct PreCountdownView: View {
    private let store: Store<PreCountdownState, PreCountdownAction>
    private let proxy = UIScreen.main.bounds

    @State var startAnimation = false

    init(store: Store<PreCountdownState, PreCountdownAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Circle()
                    .scaleEffect(startAnimation ? 5 : 0)
                    .foregroundColor(viewStore.workoutColor.color)

                Text("\(viewStore.timeLeft.clean)")
                            .opacity(startAnimation ? 1 : 0)
                            .foregroundColor(.white)
                            .font(.timer)
            }
            .frame(width: proxy.width, height: proxy.height)
            .animation(.easeInOut(duration: 0.55))
            .onAppear {
                viewStore.send(.onAppear)
                startAnimation = true
            }
            .onChange(of: viewStore.timeLeft, perform: { value in
                if value == 0 {
                    startAnimation = false
                }
            })
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
                environment: .preview
            )
        )
    }
}

private extension TimeInterval {
    var clean: String {
        guard self >= 0 else { return String(format: "%.0f", 0) }
        return String(format: "%.0f", self)
    }
}
