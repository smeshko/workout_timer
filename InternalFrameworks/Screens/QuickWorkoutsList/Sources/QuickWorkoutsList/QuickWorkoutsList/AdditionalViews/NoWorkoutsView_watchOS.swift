import SwiftUI
import CoreInterface
import ComposableArchitecture
import QuickWorkoutForm

#if os(watchOS)
struct NoWorkoutsView: View {
    let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>

    var body: some View {
        WithViewStore(store.scope(state: \.isPresentingTimerForm)) { viewStore in
            VStack(spacing: Spacing.l) {
                Text(key: "first_workout")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.appText)
                
                Button(action: {
                    viewStore.send(.timerForm(.present))
                }, label: {
                    Image(systemName: "plus")
                        .foregroundColor(.appWhite)
                })
            }
            .sheet(isPresented: viewStore.binding(get: { $0 }),
                   onDismiss: { viewStore.send(.timerForm(.dismiss)) }) {
                CreateQuickWorkoutView(store: store.scope(state: \.createWorkoutState,
                                                          action: QuickWorkoutsListAction.createWorkoutAction))
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct NoWorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        NoWorkoutsView(
            store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>(
                initialState: QuickWorkoutsListState(workouts: []),
                reducer: quickWorkoutsListReducer,
                environment: .preview
            )
        )
    }
}
#endif