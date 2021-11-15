import SwiftUI
import ComposableArchitecture
import CoreInterface
import NewTimerForm

#if os(watchOS)
struct TimersList: View {
    let store: Store<TimersListState, TimersListAction>

    var body: some View {
        WithViewStore(store.scope(state: \.isPresentingTimerForm)) { viewStore in
            ScrollView(showsIndicators: false) {
                VStack {
                    ListContents(store: store)
                }
            }
            .sheet(isPresented: viewStore.binding(get: { $0 }),
                   onDismiss: { viewStore.send(.timerForm(.dismiss))}) {
                CreateQuickWorkoutView(store: store.scope(state: \.createWorkoutState,
                                                          action: TimersListAction.createWorkoutAction))
            }
        }
        .fullHeight()
        .fullWidth()
    }
}

private extension View {
    func settingSize(_ binding: Binding<CGSize>) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear { binding.wrappedValue = proxy.size }
            })
    }
}

private struct ListContents: View {
    let store: Store<TimersListState, TimersListAction>
    @State private var cellSize: CGSize = .zero

    var body: some View {
        WithViewStore(store.scope(state: \.isPresentingTimerForm)) { viewStore in
            ForEachStore(store.scope(state: { $0.workoutStates },
                                     action: TimersListAction.workoutCardAction(id:action:))) { cardViewStore in
                QuickWorkoutCardView(store: cardViewStore)
            }
        }
    }
}

struct WorkoutsListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutsList(
            store: Store<TimersListState, TimersListAction>(
                initialState: QuickWorkoutsListState(
                    workouts: [mockQuickWorkout1, mockQuickWorkout2]),
                reducer: timersListReducer,
                environment: .preview
            )
        )
        .previewDevice(.iPadPro)
    }
}

#endif
