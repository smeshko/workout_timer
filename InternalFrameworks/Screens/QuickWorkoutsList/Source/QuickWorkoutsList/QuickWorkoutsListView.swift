import SwiftUI
import DomainEntities
import ComposableArchitecture
import QuickWorkoutForm
import CoreInterface

public struct QuickWorkoutsListView: View {

    let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>
    @ObservedObject var viewStore: ViewStore<QuickWorkoutsListState, QuickWorkoutsListAction>

    @State var isPresenting: Bool = false
    @State var editMode: EditMode = .inactive

    public init(store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        NavigationView {
            if viewStore.workoutStates.isEmpty && viewStore.loadingState.isFinished {
                NoWorkoutsView(store: store)
            } else {
                WorkoutsList(store: store, isPresenting: $isPresenting)
                    .environment(\.editMode, $editMode)
                    .toolbar {
                        HStack(spacing: 12) {
//                            Button(action: {
//                                withAnimation {
//                                    editMode.toggle()
//                                }
//                            }, label: {
//                                if editMode.isEditing {
//                                    Text("Done")
//                                } else {
//                                    Image(systemName: "pencil.circle")
//                                        .font(.system(size: 28))
//                                }
//                            })

                            Button(action: {
                                isPresenting = true
                            }, label: {
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 28))
                            })
                            .disabled(editMode.isEditing)
                        }
                    }
            }
        }
        .sheet(isPresented: $isPresenting) {
            CreateQuickWorkoutView(store: store.scope(state: \.createWorkoutState,
                                                      action: QuickWorkoutsListAction.createWorkoutAction))
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
    }
}

struct QuickWorkoutsListView_Previews: PreviewProvider {
    static var previews: some View {
        let emptyStore = Store<QuickWorkoutsListState, QuickWorkoutsListAction>(
            initialState: QuickWorkoutsListState(),
            reducer: quickWorkoutsListReducer,
            environment: QuickWorkoutsListEnvironment(
                repository: .mock,
                mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                notificationClient: .mock
            )
        )

        let filledStore = Store<QuickWorkoutsListState, QuickWorkoutsListAction>(
            initialState: QuickWorkoutsListState(workouts: [mockQuickWorkout1, mockQuickWorkout2]),
            reducer: quickWorkoutsListReducer,
            environment: QuickWorkoutsListEnvironment(
                repository: .mock,
                mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                notificationClient: .mock
            )
        )

        return Group {
            QuickWorkoutsListView(store: emptyStore)
                .previewDevice(.iPhone11)
                .preferredColorScheme(.dark)

            QuickWorkoutsListView(store: filledStore)
                .previewDevice(.iPhone11)
        }
    }
}

private struct NoWorkoutsView: View {
    let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>

    @State var isPresenting: Bool = false

    var body: some View {
        VStack(spacing: 18) {
            Button(action: {
                isPresenting = true
            }, label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(.appSuccess)
                        .frame(width: 125, height: 125)

                    Image(systemName: "plus")
                        .font(.gigantic)
                        .foregroundColor(.appWhite)
                }
            })
            .sheet(isPresented: $isPresenting) {
                CreateQuickWorkoutView(store: store.scope(state: \.createWorkoutState,
                                                          action: QuickWorkoutsListAction.createWorkoutAction))
            }
            Text("Create your first workout")
                .font(.h2)
                .foregroundColor(.appText)
        }
    }
}

private struct WorkoutsList: View {
    let store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>
    let viewStore: ViewStore<QuickWorkoutsListState, QuickWorkoutsListAction>

    @Binding var isPresenting: Bool
    @Environment(\.editMode) var editMode

    init(store: Store<QuickWorkoutsListState, QuickWorkoutsListAction>, isPresenting: Binding<Bool>) {
        self.store = store
        self.viewStore = ViewStore(store)
        self._isPresenting = isPresenting
    }

    var body: some View {
        List(store.scope(state: { $0.workoutStates },
                         action: QuickWorkoutsListAction.workoutCardAction(id:action:))) { cardViewStore in
            QuickWorkoutCardView(store: cardViewStore)
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
        }
        .onDelete { insets in
            withAnimation {
                viewStore.send(QuickWorkoutsListAction.deleteWorkouts(insets))
                editMode?.animation().wrappedValue.toggle()
            }
        }
        .actionProvider { index in
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                viewStore.send(.deleteWorkouts(index))
            }

            let start = UIAction(title: "Start", image: UIImage(systemName: "play.fill")) { action in
                viewStore.send(.workoutCardAction(id: UUID(), action: .tapStart))
            }

            let deleteMenu = UIMenu(title: "Delete", image: UIImage(systemName: "trash"), options: .destructive, children: [deleteAction])

            return UIMenu(title: "", children: [start, deleteMenu])
        }
        .previewProvider { store in
            WorkoutPreview(store: store)
        }
        .destination { viewStore in
            WorkoutPreview(store: viewStore)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .navigationTitle("Workouts")
    }
}

private struct WorkoutPreview: View {
    let store: Store<QuickWorkoutCardState, QuickWorkoutCardAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {
                HStack {
                    Text(viewStore.workout.name)
                        .font(.h1)
                        .foregroundColor(.appWhite)

                    Spacer()

                    Text("\(viewStore.duration) mins")
                        .font(.h2)
                        .foregroundColor(.appWhite)
                }

                ForEach(viewStore.workout.segments) { segment in
                    HStack {
                        Text("\(segment.sets) sets")
                        Spacer()
                        Text("\(segment.work)sec")
                    }
                    .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity)
                    .font(.h3)
                    .foregroundColor(.appWhite)
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(viewStore.workout.color.color.opacity(0.6))
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 5, y: 5)
                    )
                    .padding(.top, 12)
                }
            }
            .padding(28)
            .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity, minHeight: 0, idealHeight: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(viewStore.workout.color.monochromatic)
        }
    }
}

private extension WorkoutColor {
    var monochromatic: Color {
        Color(hue: hue, saturation: saturation - 0.2, brightness: brightness - 0.1)
    }
}

private extension EditMode {
    mutating func toggle() {
        self = self == .active ? .inactive : .active
    }
}
