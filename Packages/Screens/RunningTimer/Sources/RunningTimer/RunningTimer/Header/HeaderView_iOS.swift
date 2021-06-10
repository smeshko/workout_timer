import SwiftUI
import CoreInterface
import ComposableArchitecture

#if os(iOS)
struct HeaderView: View {
    private let store: Store<HeaderState, HeaderAction>
    @ObservedObject private var viewStore: ViewStore<HeaderState, HeaderAction>
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    init(store: Store<HeaderState, HeaderAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        VerticalSizeAdaptiveView(spacing: Spacing.l) {
            Button(action: {
                viewStore.send(.closeButtonTapped)
            }, label: {
                Image(systemName: "xmark")
                    .frame(width: 18, height: 18)
                    .padding(Spacing.s)
                    .foregroundColor(.appText)
            })
            .alert(
              self.store.scope(state: { $0.alert }),
              dismiss: .alertDismissed
            )
            .background(Color.appCardBackground)
            .cornerRadius(CornerRadius.m)

            if viewStore.isFinished {
                Spacer()
            } else {
                VerticalSizeAdaptiveView {
                    Text(viewStore.workoutName)
                        .font(.h3)
                        .foregroundColor(.appText)

                    Spacer()

                    Text(viewStore.timeLeft.formattedTimeLeft)
                        .foregroundColor(.appText)
                        .font(.h1Mono)
                }
                .transition(.move(edge: verticalSizeClass == .compact ? .leading : .trailing))
                .animation(.easeInOut(duration: 0.55))
            }
        }
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(
            store: Store<HeaderState, HeaderAction>(
                initialState: HeaderState(workoutName: "Some workout"),
                reducer: headerReducer,
                environment: HeaderEnvironment()
            )
        )
    }
}
#endif
