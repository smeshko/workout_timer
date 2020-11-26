import SwiftUI
import DomainEntities
import ComposableArchitecture
import RunningTimer

struct QuickWorkoutCardView: View {

    let store: Store<QuickWorkoutCardState, QuickWorkoutCardAction>
    let viewStore: ViewStore<QuickWorkoutCardState, QuickWorkoutCardAction>

    let size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

    @Binding var origin: CGPoint

    init(store: Store<QuickWorkoutCardState, QuickWorkoutCardAction>, origin: Binding<CGPoint>) {
        self.store = store
        self._origin = origin
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 18) {

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(viewStore.duration) mins")
                        .font(.h3)

                    Text("\(viewStore.segmentsCount) segments")
                        .font(.bodySmall)
                }

                HStack {
                    Text(viewStore.workout.name)
                        .font(.h1)

                    Spacer()

                    GeometryReader { buttonProxy in
                        Button(action: {
                            withAnimation {
                                viewStore.send(.tapStart)
                                let buttonOrigin = buttonProxy.frame(in: .global).origin
                                origin = CGPoint(
                                    x: buttonOrigin.x,
                                    y: buttonOrigin.y - buttonProxy.size.height / 2
                                )
                            }
                        }, label: {
                            Image(systemName: "play.fill")
                                .padding(12)
                                .foregroundColor(.appWhite)
                                .background(viewStore.workout.color.color)
                                .mask(Circle())

                        })
                    }
                    .frame(width: 40, height: 40)
                }
            }
            .padding(18)
            .background(Color.appCardBackground)
            .cornerRadius(12)
        }
    }
}

struct QuickWorkoutCardView_Previews: PreviewProvider {
    static var previews: some View {

        let store = Store<QuickWorkoutCardState, QuickWorkoutCardAction>(
            initialState: QuickWorkoutCardState(
                workout: QuickWorkout(id: UUID(),
                                      name: "Quick Workout",
                                      color: WorkoutColor(hue: 0.53, saturation: 0.54, brightness: 0.33),
                                      segments: [
                                        QuickWorkoutSegment(id: UUID(), sets: 4, work: 20, pause: 10),
                                        QuickWorkoutSegment(id: UUID(), sets: 2, work: 60, pause: 10)
                                      ])),
            reducer: quickWorkoutCardReducer,
            environment: QuickWorkoutCardEnvironment()
        )

        return Group {
            QuickWorkoutCardView(store: store, origin: .constant(.zero))
                .padding()
                .previewLayout(.fixed(width: 375, height: 180))
                .preferredColorScheme(.dark)

            QuickWorkoutCardView(store: store, origin: .constant(.zero))
                .padding()
                .previewLayout(.fixed(width: 375, height: 180))
        }
    }
}
