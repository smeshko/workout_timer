import SwiftUI
import CoreInterface
import ComposableArchitecture

struct HeaderView: View {
    private let store: Store<HeaderState, HeaderAction>
    @ObservedObject var viewStore: ViewStore<HeaderState, HeaderAction>

    init(store: Store<HeaderState, HeaderAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        HStack(spacing: Spacing.l) {
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
            .cornerRadius(12)

            if viewStore.isFinished {
                Spacer()
            } else {
                HStack {
                    Text(viewStore.workoutName)
                        .font(.h3)
                        .foregroundColor(.appText)

                    Spacer()

                    Text(viewStore.timeLeft.formattedTimeLeft)
                        .foregroundColor(.appText)
                        .font(.h1Mono)
                }
                .transition(.move(edge: .trailing))
                .animation(.easeInOut(duration: 0.55))
            }
        }
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(
            store: Store<HeaderState, HeaderAction>(
                initialState: HeaderState(),
                reducer: headerReducer,
                environment: HeaderEnvironment()
            )
        )
    }
}
