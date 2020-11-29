import SwiftUI
import ComposableArchitecture

struct HeaderView: View {
    private let store: Store<RunningTimerState, RunningTimerAction>
    @ObservedObject var viewStore: ViewStore<RunningTimerState, RunningTimerAction>

    init(store: Store<RunningTimerState, RunningTimerAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        HStack(spacing: 18) {
            Button(action: {
                viewStore.send(.alertButtonTapped)
            }, label: {
                Image(systemName: "xmark")
                    .frame(width: 18, height: 18)
                    .padding(10)
                    .foregroundColor(.appText)
            })
            .alert(
              self.store.scope(state: { $0.alert }),
              dismiss: .alertDismissed
            )
            .background(Color.appCardBackground)
            .cornerRadius(12)

            if viewStore.timerControlsState.isFinished {
                Spacer()
            } else {
                HStack {
                    Text(viewStore.workout.name)
                        .font(.h3)
                        .foregroundColor(.appText)

                    Spacer()

                    Text(viewStore.totalTimeLeft.formattedTimeLeft)
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
            store: Store<RunningTimerState, RunningTimerAction>(
                initialState: RunningTimerState(workout: mockQuickWorkout1),
                reducer: runningTimerReducer,
                environment: .preview
            )
        )
    }
}
