import SwiftUI
import ComposableArchitecture
import CoreInterface
import QuickWorkoutForm

#if os(iOS)
struct WorkoutsList: View {
    let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        WithViewStore(store.scope(state: \.isPresentingTimerForm)) { viewStore in
            ScrollView(showsIndicators: false) {
                if horizontalSizeClass == .regular {
                    LazyVGrid(columns: columns) {
                        ListContents(store: store)
                    }
                    .padding(.horizontal, Spacing.l)
                } else {
                    VStack {
                        ListContents(store: store)
                    }
                    .padding(.horizontal, Spacing.l)
                }
            }
            .sheet(isPresented: viewStore.binding(get: { $0 }),
                   onDismiss: { viewStore.send(.timerForm(.dismiss))}) {
                CreateQuickWorkoutView(store: store.scope(state: \.createWorkoutState,
                                                          action: QuickWorkoutsListAction.createWorkoutAction))
            }
        }
        .fullHeight()
        .fullWidth()
        .navigationTitle("workouts".localized)
    }
}

//struct WorkoutsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        WorkoutsList(
//            store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>(
//                initialState: QuickWorkoutsListState(
//                    workouts: [mockQuickWorkout1, mockQuickWorkout2]),
//                reducer: quickWorkoutsListReducer,
//                environment: .preview
//            )
//        )
//        .previewDevice(.iPadPro)
//    }
//}

private struct ListContents: View {

    let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>

    var body: some View {
        WithViewStore(store.scope(state: \.query)) { viewStore in
            ForEachStore(store.scope(state: { $0.workoutStates },
                                     action: QuickWorkoutsListAction.workoutCardAction(id:action:))) { cardViewStore in
                TimerCardView(store: cardViewStore)
            }
            .searchable(text: viewStore.binding(get: { $0 }, send: QuickWorkoutsListAction.onUpdateQuery))
        }
    }
}
#endif
