import SwiftUI
import ComposableArchitecture
import CoreInterface
import NewTimerForm

#if os(iOS)
struct TimersList: View {
    let store: Store<TimersListState, TimersListAction>

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
        }
        .fullHeight()
        .fullWidth()
    }
}

private struct ListContents: View {

    let store: Store<TimersListState, TimersListAction>

    var body: some View {
        WithViewStore(store.scope(state: \.query)) { viewStore in
            ForEachStore(store.scope(state: { $0.workoutStates },
                                     action: TimersListAction.workoutCardAction(id:action:))) { cardViewStore in
                TimerCardView(store: cardViewStore)
            }
            .searchable(text: viewStore.binding(get: { $0 }, send: TimersListAction.onUpdateQuery))
        }
    }
}
#endif

//struct WorkoutsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TimersList(
//            store: Store<QuickWorkoutsListState, TimersListAction>(
//                initialState: QuickWorkoutsListState(
//                    workouts: [mockQuickWorkout1, mockQuickWorkout2]),
//                reducer: timersListReducer,
//                environment: .preview
//            )
//        )
//        .previewDevice(.iPadPro)
//    }
//}
