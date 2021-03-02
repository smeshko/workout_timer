import SwiftUI
import ComposableArchitecture
import CoreInterface
import QuickWorkoutForm

#if os(watchOS)
struct WorkoutsList: View {
    let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>

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
                                                          action: QuickWorkoutsListAction.createWorkoutAction))
            }
        }
        .fullHeight()
        .fullWidth()
        .navigationTitle("workouts".localized)
    }
}

struct WorkoutsListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutsList(
            store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>(
                initialState: QuickWorkoutsListState(
                    workouts: [mockQuickWorkout1, mockQuickWorkout2]),
                reducer: quickWorkoutsListReducer,
                environment: .preview
            )
        )
        .previewDevice(.iPadPro)
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
    let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>
    @State private var cellSize: CGSize = .zero

    var body: some View {
        WithViewStore(store.scope(state: \.isPresentingTimerForm)) { viewStore in
            ForEachStore(store.scope(state: { $0.workoutStates },
                                     action: QuickWorkoutsListAction.workoutCardAction(id:action:))) { cardViewStore in
                QuickWorkoutCardView(store: cardViewStore)
            }
        }
    }
}
#endif
