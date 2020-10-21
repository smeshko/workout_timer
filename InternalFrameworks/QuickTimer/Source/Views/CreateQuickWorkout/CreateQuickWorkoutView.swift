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
                            .padding(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(viewStore.color, lineWidth: 1))

                        ColorPicker("Choose workout color", selection: viewStore.binding(
                            get: {
                                Color(hue: $0.colorComponents.hue,
                                      saturation: $0.colorComponents.saturation,
                                      brightness: $0.colorComponents.brightness)
                            },
                            send: {
                                let components = UIColor($0).components()
                                return CreateQuickWorkoutAction.updateColorComponents(ColorComponents(hue: components.h, brightness: components.b, saturation: components.s))
                            }
                        ))

                        ForEachStore(store.scope(state: { $0.addTimerSegments }, action: CreateQuickWorkoutAction.addTimerSegmentAction(id:action:))) { segmentViewStore in
                            AddTimerSegmentView(store: segmentViewStore, color: viewStore.color)
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

extension UIColor {
    func components() -> (h: Double, s: Double, b: Double) {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getHue(&h, saturation: &s, brightness: &b, alpha: &a)

        return (Double(h), Double(s), Double(b))
    }
}

extension CreateQuickWorkoutState {
    var color: Color {
        Color(hue: colorComponents.hue, saturation: colorComponents.saturation, brightness: colorComponents.brightness)
    }
}
