import SwiftUI
import ComposableArchitecture

struct CreateQuickWorkoutView: View {

    let store: Store<CreateQuickWorkoutState, CreateQuickWorkoutAction>

    @State var color: Color = .blue
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                ScrollView {
                    VStack(spacing: 18) {
                        TextField("Workout name", text: viewStore.binding(get: \.name, send: CreateQuickWorkoutAction.updateName))

                        ColorPicker("Colors", selection: $color)

                        ForEachStore(store.scope(state: { $0.addTimerSegments }, action: CreateQuickWorkoutAction.addTimerSegmentAction(id:action:))) { viewStore in
                            AddTimerSegmentView(store: viewStore)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 18)
                                .background(Color.appCardBackground)
                                .cornerRadius(12)
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
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", action: {
                            viewStore.send(.cancel)
                            presentationMode.wrappedValue.dismiss()
                        })
                    }
                }
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
