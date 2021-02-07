import SwiftUI
import ComposableArchitecture
import CoreInterface
import QuickWorkoutForm

struct WorkoutsList: View {
    private let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>
    @ObservedObject private var viewStore: ViewStore<QuickWorkoutsListState, QuickWorkoutsListAction>

    @Binding private var origin: CGPoint
    @State private var cellSize: CGSize = .zero

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    init(store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>,
         origin: Binding<CGPoint>
    ) {
        self.store = store
        self.viewStore = ViewStore(store)
        self._origin = origin
    }

    var body: some View {
        List(store.scope(state: { $0.workoutStates },
                         action: QuickWorkoutsListAction.workoutCardAction(id:action:))) { cardViewStore in
            ContextMenuView {
                QuickWorkoutCardView(store: cardViewStore, origin: $origin)
                    .padding(.horizontal, Spacing.l)
                    .padding(.vertical, Spacing.xs)
                    .settingSize($cellSize)
            } previewProvider: {
                WorkoutPreview(store: cardViewStore)
            }
            .actionProvider {
                let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                    viewStore.send(.deleteWorkout(ViewStore(cardViewStore).workout))
                }

                let edit = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { _ in
                    viewStore.send(.editWorkout(ViewStore(cardViewStore).workout))
                    viewStore.send(.timerForm(.present))
                }

                let start = UIAction(title: "Start", image: UIImage(systemName: "play.fill")) { action in
                    ViewStore(cardViewStore).send(.tapStart)
                }

                let deleteMenu = UIMenu(title: "Delete", image: UIImage(systemName: "trash"), options: .destructive, children: [deleteAction])

                return UIMenu(title: "", children: [start, edit, deleteMenu])
            }
            .onPreviewTap {
                viewStore.send(.editWorkout(ViewStore(cardViewStore).workout))
                viewStore.send(.timerForm(.present))
            }
            .frame(height: cellSize.height)
        }
        .onDelete { insets in
            withAnimation {
                viewStore.send(QuickWorkoutsListAction.deleteWorkouts(insets))
            }
        }
        .rowHeight(cellSize.height)
        .sheet(isPresented: viewStore.binding(get: \.isPresentingTimerForm),
               onDismiss: { viewStore.send(.timerForm(.dismiss))}) {
            CreateQuickWorkoutView(store: store.scope(state: \.createWorkoutState,
                                                      action: QuickWorkoutsListAction.createWorkoutAction))
        }
        .fullHeight()
        .fullWidth()
        .padding(.horizontal, Spacing.margin(horizontalSizeClass))
        .edgesIgnoringSafeArea(.all)
        .navigationTitle("Workouts")

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
            ),
            origin: .constant(.zero)
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
