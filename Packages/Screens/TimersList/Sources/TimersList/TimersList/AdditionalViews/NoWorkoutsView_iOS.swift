import SwiftUI
import CoreInterface
import ComposableArchitecture
import NewTimerForm

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
                            .styling(font: .gigantic)
                    }
                })
                Text(key: "first_workout")
                    .styling(font: .h2)
            }
            .sheet(isPresented: viewStore.binding(get: { $0 } )) {
                IfLetStore(
                    store.scope(state: \.newTimerFormState, action: TimersListAction.newTimerFormAction)) { store in
                        NewTimerForm(store: store)
                            .interactiveDismissDisabled()
                    }
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
