import SwiftUI
import WorkoutCore
import ComposableArchitecture

struct CreateQuickWorkoutView: View {
    let store: Store<CreateQuickWorkoutState, CreateQuickWorkoutAction>

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
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
                .onAppear {
                    viewStore.send(.onAppear)
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save", action: {
                            viewStore.send(.save)
                            presentationMode.wrappedValue.dismiss()
                        })
                        .disabled(viewStore.isFormIncomplete)
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", action: {
                            viewStore.send(.cancel)
                            presentationMode.wrappedValue.dismiss()
                        })
                    }
                }
                .navigationTitle("Create workout")
            }
        }
    }
}

struct CreateQuickWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
//        CreateQuickWorkoutView()
        Text("")
    }
}
