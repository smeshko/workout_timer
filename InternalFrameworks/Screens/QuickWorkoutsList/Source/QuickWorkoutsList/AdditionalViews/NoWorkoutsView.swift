import SwiftUI
import CoreInterface
import ComposableArchitecture
import QuickWorkoutForm

struct NoWorkoutsView: View {
    private let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>
    @ObservedObject private var viewStore: ViewStore<QuickWorkoutsListState, QuickWorkoutsListAction>

    init(store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
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
            Text("Create your first workout")
                .font(.h2)
                .foregroundColor(.appText)
        }
        .sheet(isPresented: viewStore.binding(get: \.isPresentingTimerForm),
               onDismiss: { viewStore.send(.timerForm(.dismiss)) }) {
            CreateQuickWorkoutView(store: store.scope(state: \.createWorkoutState,
                                                      action: QuickWorkoutsListAction.createWorkoutAction))
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
