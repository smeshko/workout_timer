import SwiftUI
import CoreLogic
import ComposableArchitecture

public struct CreateQuickWorkoutView: View {
    let store: Store<CreateQuickWorkoutState, CreateQuickWorkoutAction>

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    public init(store: Store<CreateQuickWorkoutState, CreateQuickWorkoutAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                NavigationView {
                    WorkoutForm(store: store)
                        .navigationTitle(viewStore.isEditing ? "Edit Workout" : "Create workout")
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Save", action: {
                                    presentationMode.wrappedValue.dismiss()
                                    viewStore.send(.save)
                                })
                                .disabled(viewStore.isFormIncomplete)
                            }
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel", action: {
                                    presentationMode.wrappedValue.dismiss()
                                    viewStore.send(.cancel)
                                })
                            }
                        }
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct CreateQuickWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        let emptyStore = Store<CreateQuickWorkoutState, CreateQuickWorkoutAction>(
            initialState: CreateQuickWorkoutState(),
            reducer: createQuickWorkoutReducer,
            environment: CreateQuickWorkoutEnvironment(
                mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                repository: .mock
            )
        )

        let filledStore = Store<CreateQuickWorkoutState, CreateQuickWorkoutAction>(
            initialState: CreateQuickWorkoutState(
                workout: mockQuickWorkout1
            ),
            reducer: createQuickWorkoutReducer,
            environment: CreateQuickWorkoutEnvironment(
                mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                repository: .mock
            )
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
    let store: Store<CreateQuickWorkoutState, CreateQuickWorkoutAction>
    let viewStore: ViewStore<CreateQuickWorkoutState, CreateQuickWorkoutAction>

    init(store: Store<CreateQuickWorkoutState, CreateQuickWorkoutAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                TextField("Workout name", text: viewStore.binding(get: \.name, send: CreateQuickWorkoutAction.updateName))
                    .padding(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(viewStore.selectedColor, lineWidth: 1))


                VStack(spacing: 12) {
                    ColorPicker("Choose workout color", selection: viewStore.binding(
                        get: \.selectedColor,
                        send: CreateQuickWorkoutAction.selectColor(_:)
                    ))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
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
                }

                ForEachStore(store.scope(state: { $0.addTimerSegmentStates }, action: CreateQuickWorkoutAction.addTimerSegmentAction(id:action:))) { segmentViewStore in
                    AddTimerSegmentView(store: segmentViewStore, color: viewStore.selectedColor)
                        .padding(.bottom, 8)
                }
            }
            .padding(28)
        }
    }
}

private struct ColorsView: View {
    let viewStore: ViewStore<CreateQuickWorkoutState, CreateQuickWorkoutAction>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
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
    }
}
