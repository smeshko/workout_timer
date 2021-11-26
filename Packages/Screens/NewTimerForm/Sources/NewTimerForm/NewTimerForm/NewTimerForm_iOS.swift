import ComposableArchitecture
import SwiftUI
import DomainEntities
import CoreInterface

public struct NewTimerForm: View {

    @FocusState var isInputActive: Bool

    private let store: Store<NewTimerFormState, NewTimerFormAction>

    public init(store: Store<NewTimerFormState, NewTimerFormAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                Form {
                    Section {
                        TextField("unnamed workout", text: viewStore.binding(\.$name))

                        NavigationLink {
                            ColorPickerView(colors: viewStore.preselectedTints, selectedColor: viewStore.binding(\.$selectedColor))
                                .navigationBarTitle(Text("Pick a color"))
                        } label: {
                            HStack {
                                Text("Pick a Color")
                                    .font(.bodyRegular)

                                Spacer()

                                Circle()
                                    .frame(width: 40, height: 24)
                                    .foregroundColor(viewStore.selectedColor.color)
                            }
                        }
                    }

                    if !viewStore.segmentStates.isEmpty {
                        Section {
                            ExercisesList(store: store, isInputActive: _isInputActive)
                                .toolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()

                                        Button("Done") {
                                            isInputActive = false
                                        }
                                    }
                                }

                        } header: {
                            if !viewStore.segmentStates.isEmpty {
                                EditButton()
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .overlay(Text("Exercises"), alignment: .leading)
                            }
                        }
                    }

                    Section {
                        HStack {
                            Spacer()

                            Button("+") {
                                viewStore.send(.addEmptySegment, animation: .default)
                            }
                            .foregroundColor(.white)
                            .font(.h2)

                            Spacer() }

                    }
                }
                .navigationTitle(viewStore.isEditing ? "Edit workout" : "Create workout")
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
            }
        }
    }
}


private struct ExercisesList: View {
    private let store: Store<NewTimerFormState, NewTimerFormAction>
    let isInputActive: FocusState<Bool>
    @Environment(\.editMode) var editMode

    public init(store: Store<NewTimerFormState, NewTimerFormAction>, isInputActive: FocusState<Bool>) {
        self.store = store
        self.isInputActive = isInputActive
    }

    var body: some View {
        WithViewStore(store.scope(state: \.segmentStates)) { viewStore in
            List {
                ForEachStore(store.scope(state: \.segmentStates, action: NewTimerFormAction.segmentAction)) { segmentStore in
                    SegmentView(store: segmentStore, isInputActive: isInputActive)
                        .padding(.vertical, Spacing.s)
                }
                .onMove { indexSet, index in
                    viewStore.send(.moveSegment(indexSet, index))
                }
                .onDelete { indexSet in
                    viewStore.send(.deleteSegments(indexSet), animation: .default)
                    if viewStore.isEmpty { editMode?.wrappedValue = .inactive }
                }
            }
        }
    }
}

private struct ColorPickerView: View {
    let colors: [TintColor]
    @Binding var selectedColor: TintColor
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            ForEach(colors, id: \.id) { color in
                Button {
                    selectedColor = color
                    dismiss()
                } label: {
                    HStack {
                        Circle()
                            .frame(width: 40, height: 24)
                            .foregroundColor(color.color)

                        Text(color.name)
                            .font(.bodyRegular)

                        Spacer()

                        if selectedColor == color {
                            Image(systemName: "checkmark")
                                .font(.bodyRegular)
                        }
                    }
                    .tint(.appText)

                }
            }
        }
    }
}

//struct NewTimerView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewTimerForm(
//            store: Store<NewTimerFormState, NewTimerFormAction>(
//                initialState: NewTimerFormState(),
//                reducer: newTimerFormReducer,
//                environment: .preview
//            )
//        )
//    }
//}
