import SwiftUI
import CoreInterface
import ComposableArchitecture
import QuickWorkoutForm

struct NoWorkoutsView: View {
    let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>

    var body: some View {
        WithViewStore(store.scope(state: \.isPresentingTimerForm)) { viewStore in
            VStack(spacing: Spacing.l) {
                Button(action: {
                    viewStore.send(.timerForm(.present))
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: CornerRadius.m)
                            .foregroundColor(.appSuccess)
                            .frame(width: 125, height: 125)

                        Image(systemName: "plus")
                            .font(.gigantic)
                            .foregroundColor(.appWhite)
                    }
                })
                Text(key: "first_workout")
                    .font(.h2)
                    .foregroundColor(.appText)
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
