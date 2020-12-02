import SwiftUI
import CoreLogic
import CoreInterface
import ComposableArchitecture

public struct CreateQuickWorkoutView: View {
    private let store: Store<CreateQuickWorkoutState, CreateQuickWorkoutAction>
    @ObservedObject private var viewStore: ViewStore<CreateQuickWorkoutState, CreateQuickWorkoutAction>

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    private var isPresentingSegmentPopup: Bool {
        viewStore.addSegmentState != nil
    }

    public init(store: Store<CreateQuickWorkoutState, CreateQuickWorkoutAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    WorkoutForm(store: store)
                }
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
                .navigationTitle(viewStore.isEditing ? "Edit Workout" : "Create workout")
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
            .blur(radius: isPresentingSegmentPopup ? 2 : 0)

            IfLetStore(store.scope(state: \.addSegmentState, action: CreateQuickWorkoutAction.addSegmentAction),
                       then: { AddTimerSegmentView(store: $0) }
            )
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
    private let store: Store<CreateQuickWorkoutState, CreateQuickWorkoutAction>
    @ObservedObject private var viewStore: ViewStore<CreateQuickWorkoutState, CreateQuickWorkoutAction>

    init(store: Store<CreateQuickWorkoutState, CreateQuickWorkoutAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xxl) {
                TextField("Workout name", text: viewStore.binding(get: \.name, send: CreateQuickWorkoutAction.updateName))
                    .padding(Spacing.s)
                    .border(stroke: viewStore.selectedColor)

                VStack(spacing: Spacing.s) {
                    ColorPicker("Choose workout color", selection: viewStore.binding(
                        get: \.selectedColor,
                        send: CreateQuickWorkoutAction.selectColor(_:)
                    ))
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
                }
                ForEachStore(store.scope(state: \.segmentStates, action: CreateQuickWorkoutAction.segmentAction)) { store in
                    SegmentView(store: store)
                        .border(stroke: viewStore.selectedColor)
                        .padding(.bottom, Spacing.xs)
                        .onTapGesture {
                            withAnimation {
                                viewStore.send(.editSegment(id: ViewStore(store).state.id))
                            }
                        }
                }

                Button(action: {
                    withAnimation {
                        viewStore.send(.newSegmentButtonTapped)
                    }
                }) {
                    Label("Add segment", systemImage: "plus")
                        .font(.h2)
                        .foregroundColor(.appText)
                }
            }
            .padding(Spacing.xxl)
        }
    }
}
