import SwiftUI
import DomainEntities
import CoreInterface
import ComposableArchitecture
import RunningTimer

#if os(iOS)
struct QuickWorkoutCardView: View {

    private let store: Store<QuickWorkoutCardState, QuickWorkoutCardAction>
    @ObservedObject private var viewStore: ViewStore<QuickWorkoutCardState, QuickWorkoutCardAction>

    init(store: Store<QuickWorkoutCardState, QuickWorkoutCardAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("mins".localized(viewStore.duration))
                    .font(.h3)

                Text("rounds".localized(viewStore.segmentsCount))
                    .font(.bodySmall)
            }

            HStack {
                Text(viewStore.workout.name)
                    .font(.h1)
                Spacer()
                Button(action: {
                    withAnimation {
                        viewStore.send(.tapStart)
                    }
                }, label: {
                    Image(systemName: "play.fill")
                        .padding(Spacing.s)
                        .background(viewStore.workout.color.color)
                        .mask(Circle())

                })
                .frame(width: 40, height: 40)
            }
        }
        .foregroundColor(.appWhite)
        .padding(Spacing.l)
        .background(
            GeometryReader { proxy in
                ZStack(alignment: .trailing) {
                    LinearGradient(
                        gradient: Gradient(colors: [viewStore.workout.color.color, viewStore.workout.color.monochromatic]),
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )

                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [viewStore.workout.color.color, viewStore.workout.color.monochromatic]),
                                startPoint: .bottomLeading,
                                endPoint: .trailing
                            )
                        )
                        .scaleEffect(1.2)
                        .offset(x: proxy.size.width / 2, y: 35)
                        .clipped()
                }
            }
        )
    }
}

struct QuickWorkoutCardView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(TintColor.allTints) { tint in
            QuickWorkoutCardView(store: Store<QuickWorkoutCardState, QuickWorkoutCardAction>(
                initialState: QuickWorkoutCardState(
                    workout: QuickWorkout(
                        id: UUID(),
                        name: "This is Mock Workout",
                        color: WorkoutColor(color: tint.color),
                        segments: [mockSegment1, mockSegment3]
                    )
                ),
                reducer: quickWorkoutCardReducer,
                environment: QuickWorkoutCardEnvironment()
            ))
            .padding()
            .previewLayout(.fixed(width: 375, height: 180))
            .preferredColorScheme(.dark)
        }
    }
}

private extension WorkoutColor {
    var monochromatic: Color {
        Color(hue: hue, saturation: saturation, brightness: brightness + 0.4)
    }
}
#endif
