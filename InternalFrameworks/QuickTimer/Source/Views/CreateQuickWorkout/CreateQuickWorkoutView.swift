import SwiftUI
import ComposableArchitecture

struct CreateQuickWorkoutView: View {

    let store: Store<CreateQuickWorkoutState, CreateQuickWorkoutAction>

    @State var color: Color = .blue

    var body: some View {
        NavigationView {
            WithViewStore(store) { viewStore in
                ScrollView {
                    VStack(spacing: 18) {
                        TextField("Workout name", text: viewStore.binding(get: \.name, send: CreateQuickWorkoutAction.updateName))

                        ColorPicker("Colors", selection: $color)

                        ForEachStore(self.store.scope(state: { $0.addTimerSegments }, action: CreateQuickWorkoutAction.addTimerSegmentAction(id:action:))) { viewStore in
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
                        Button("Save", action: {})
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", action: {})
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
