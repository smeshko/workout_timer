import SwiftUI
import CoreInterface
import ComposableArchitecture
import QuickWorkoutForm

#if os(iOS)
struct NoWorkoutsView: View {
    let store: Store<TimersListState, TimersListAction>

    var body: some View {
        WithViewStore(store.scope(state: \.isPresentingTimerForm)) { viewStore in
            VStack(spacing: Spacing.l) {
                Button(action: {
                    viewStore.send(.onTimerFormPresentationChange(true))
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
            .sheet(isPresented: viewStore.binding(get: { $0 } )) {
                CreateQuickWorkoutView(store: store.scope(state: \.createWorkoutState, action: TimersListAction.createWorkoutAction))
                    .interactiveDismissDisabled()
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct NoWorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        NoWorkoutsView(
            store: Store<TimersListState, TimersListAction>(
                initialState: TimersListState(workouts: []),
                reducer: timersListReducer,
                environment: .preview
            )
        )
    }
}
#endif
