import SwiftUI
import ComposableArchitecture
import CoreInterface
import QuickWorkoutForm

struct WorkoutsList: View {
    let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>

    @State private var cellSize: CGSize = .zero
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView(showsIndicators: false) {
                ForEachStore(store.scope(state: { $0.workoutStates },
                                         action: QuickWorkoutsListAction.workoutCardAction(id:action:))) { cardViewStore in
                    ContextMenuView {
                        QuickWorkoutCardView(store: cardViewStore)
                            .padding(.horizontal, Spacing.l)
                            .padding(.vertical, Spacing.xxs)
                            .settingSize($cellSize)
                    } previewProvider: {
                        WorkoutPreview(store: cardViewStore)
                    }
                    .actionProvider {
                        actions(cardViewStore, viewStore: viewStore)
                    }
                    .onPreviewTap {
                        viewStore.send(.editWorkout(ViewStore(cardViewStore).workout))
                        viewStore.send(.timerForm(.present))
                    }
                    .frame(height: cellSize.height)
                }
            }
            .sheet(isPresented: viewStore.binding(get: \.isPresentingTimerForm),
                   onDismiss: { viewStore.send(.timerForm(.dismiss))}) {
                CreateQuickWorkoutView(store: store.scope(state: \.createWorkoutState,
                                                          action: QuickWorkoutsListAction.createWorkoutAction))
            }
        }
        .fullHeight()
        .fullWidth()
        .padding(.horizontal, Spacing.margin(horizontalSizeClass))
        .navigationTitle("Workouts")
    }

    private func actions(
        _ store: Store<QuickWorkoutCardState, QuickWorkoutCardAction>,
        viewStore: ViewStore<QuickWorkoutsListState, QuickWorkoutsListAction>
    ) -> UIMenu {
        let cardViewStore = ViewStore(store)

        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
            viewStore.send(.deleteWorkout(cardViewStore.workout))
        }

        let edit = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { _ in
            viewStore.send(.editWorkout(cardViewStore.workout))
            viewStore.send(.timerForm(.present))
        }

        let start = UIAction(title: "Start", image: UIImage(systemName: "play.fill")) { action in
            cardViewStore.send(.tapStart)
        }

        let deleteMenu = UIMenu(title: "Delete", image: UIImage(systemName: "trash"), options: .destructive, children: [deleteAction])

        return UIMenu(title: "", children: [start, edit, deleteMenu])
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
