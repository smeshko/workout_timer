import SwiftUI
import CoreLogic2
import CoreInterface
import ComposableArchitecture

public struct CreateQuickWorkoutView: View {

    fileprivate struct State: Equatable {
        var isFormIncomplete = false
        var isEditing = false
        var isPresentingCreateIntervalView = false
        var selectedColor: Color
    }

    private let store: Store<CreateQuickWorkoutState, CreateQuickWorkoutAction>

    public init(store: Store<CreateQuickWorkoutState, CreateQuickWorkoutAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store.scope(state: \.createView)) { viewStore in
            NavigationView {
                WorkoutForm(store: store)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button(key: "save") {
                                viewStore.send(.save)
                            }
                            .disabled(viewStore.isFormIncomplete)
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button(key: "cancel") {
                                viewStore.send(.cancel)
                            }
                        }
                    }
                    .navigationTitle(viewStore.isEditing ? "edit_workout".localized : "create_workout".localized)
                    .sheet(isPresented: viewStore.binding(get: \.isPresentingCreateIntervalView)) {
                        IfLetStore(store.scope(state: \.addSegmentState, action: CreateQuickWorkoutAction.addSegmentAction),
                                   then: { AddTimerSegmentView(store: $0, tint: viewStore.selectedColor) }
                        )
                    }
            }
        }
    }
}

struct CreateQuickWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        let emptyStore = Store<CreateQuickWorkoutState, CreateQuickWorkoutAction>(
            initialState: CreateQuickWorkoutState(),
            reducer: createQuickWorkoutReducer,
            environment: .preview
        )

        let filledStore = Store<CreateQuickWorkoutState, CreateQuickWorkoutAction>(
            initialState: CreateQuickWorkoutState(
                workout: mockQuickWorkout1
            ),
            reducer: createQuickWorkoutReducer,
            environment: .preview
        )

        return Group {
            CreateQuickWorkoutView(store: emptyStore)
                .previewDevice(.iPhone11)
                .preferredColorScheme(.dark)

            CreateQuickWorkoutView(store: filledStore)
                .previewDevice(.iPhone11)
        }
    }
}

private struct WorkoutForm: View {
    fileprivate struct State: Equatable {
        var preselectedTints: [TintColor]
        var selectedColor: Color
        var selectedTint: TintColor?
        var name: String
    }
    private let store: Store<CreateQuickWorkoutState, CreateQuickWorkoutAction>

    init(store: Store<CreateQuickWorkoutState, CreateQuickWorkoutAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store.scope(state: \.formView)) { viewStore in
            ScrollView {
                VStack(spacing: Spacing.xxl) {
                    TextField("workout_name_placeholder".localized, text: viewStore.binding(get: \.name, send: CreateQuickWorkoutAction.updateName))
                        .padding(Spacing.s)
                        .border(stroke: viewStore.selectedColor)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.s) {
                            ForEach(viewStore.preselectedTints) { tint in
                                ZStack {
                                    Circle()
                                        .foregroundColor(tint.color)
                                        .onTapGesture {
                                            viewStore.send(.selectColor(tint.color))
                                        }
                                    if viewStore.selectedTint == tint {
                                        Image(systemName: "checkmark")
                                            .frame(width: 25, height: 25)
                                            .foregroundColor(.white)
                                            .font(.h3)
                                    }
                                }
                                .frame(width: 40, height: 40)
                            }
                        }
                    }

                    ForEachStore(store.scope(state: \.segmentStates, action: CreateQuickWorkoutAction.segmentAction)) { store in
                        SegmentView(store: store)
                            .border(stroke: viewStore.selectedColor)
                            .padding(.bottom, Spacing.xs)
                            .onTapGesture {
                                withAnimation {
                                    viewStore.send(.editSegment(id: ViewStore(store).state.id))
                                    viewStore.send(.createInterval(.present))
                                }
                            }
                    }

                    Button(action: {
                        withAnimation {
                            viewStore.send(.newSegmentButtonTapped)
                            viewStore.send(.createInterval(.present))
                        }
                    }) {
                        Label(key: "add_round", systemImage: "plus")
                            .font(.h2)
                            .foregroundColor(.appText)
                    }
                }
            }
        }
        .padding(Spacing.xxl)
    }
}

private extension CreateQuickWorkoutState {
    var formView: WorkoutForm.State {
        WorkoutForm.State(
            preselectedTints: preselectedTints,
            selectedColor: selectedColor,
            selectedTint: selectedTint,
            name: name
        )
    }

    var createView: CreateQuickWorkoutView.State {
        CreateQuickWorkoutView.State(
            isFormIncomplete: isFormIncomplete,
            isEditing: isEditing,
            isPresentingCreateIntervalView: isPresentingCreateIntervalView,
            selectedColor: selectedColor
        )
    }
}
