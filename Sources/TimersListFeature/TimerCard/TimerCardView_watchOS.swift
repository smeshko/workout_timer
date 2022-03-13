import SwiftUI
import DomainEntities
import CoreInterface
import ComposableArchitecture
import RunningTimerFeature

#if os(watchOS)
struct TimerCardView: View {

    private let store: Store<TimerCardState, TimerCardAction>
    @ObservedObject private var viewStore: ViewStore<TimerCardState, TimerCardAction>

    init(store: Store<TimerCardState, TimerCardAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                HStack {
                    Text("mins".localized(viewStore.duration))
                        .font(.h4)
                    Spacer()
//                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.white)
                            .padding(Spacing.s)
                            .background(viewStore.workout.color.monochromatic)
                            .mask(Circle())
//                    }
                }
                Text("rounds".localized(viewStore.segmentsCount))
                    .font(.bodySmall)
            }

            HStack {
                Text(viewStore.workout.name)
                    .font(.h3)
                Spacer()
            }
        }
        .padding(.leading, Spacing.m)
        .padding(.trailing, Spacing.xxs)
        .padding(.vertical, Spacing.xs)
        .foregroundColor(.appWhite)
        .background(
            viewStore.workout.color.color
        )
        .cornerRadius(CornerRadius.m)
        .onTapGesture {
//            viewStore.send(.tapStart)
        }
    }
}

struct QuickWorkoutCardView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(TintColor.allTints) { tint in
            QuickWorkoutCardView(store: Store<TimerCardState, TimerCardAction>(
                initialState: QuickWorkoutCardState(
                    workout: QuickWorkout(
                        id: UUID(),
                        name: "This is Mock Workout",
                        color: WorkoutColor(color: tint.color),
                        segments: [mockSegment1, mockSegment3]
                    )
                ),
                reducer: timerCardReducer,
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
