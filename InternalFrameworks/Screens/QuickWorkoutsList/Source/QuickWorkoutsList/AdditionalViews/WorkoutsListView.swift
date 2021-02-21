import SwiftUI
import ComposableArchitecture
import CoreInterface
import QuickWorkoutForm

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
                } else {
                    VStack {
                        ListContents(store: store)
                    }
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
        .padding(.horizontal, Spacing.margin(horizontalSizeClass))
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
    }

    private func actions(
        _ store: Store<QuickWorkoutCardState, QuickWorkoutCardAction>,
        viewStore: ViewStore<Bool, QuickWorkoutsListAction>
    ) -> UIMenu {
        let cardViewStore = ViewStore(store)

        let deleteAction = UIAction(title: "delete".localized, image: UIImage(systemName: "trash"), attributes: .destructive) { action in
            viewStore.send(.deleteWorkout(cardViewStore.workout))
        }

        let edit = UIAction(title: "edit".localized, image: UIImage(systemName: "pencil")) { _ in
            viewStore.send(.editWorkout(cardViewStore.workout))
            viewStore.send(.timerForm(.present))
        }

        let start = UIAction(title: "start".localized, image: UIImage(systemName: "play.fill")) { action in
            cardViewStore.send(.tapStart)
        }

        let deleteMenu = UIMenu(title: "delete".localized, image: UIImage(systemName: "trash"), options: .destructive, children: [deleteAction])

        return UIMenu(title: "", children: [start, edit, deleteMenu])
    }
}
