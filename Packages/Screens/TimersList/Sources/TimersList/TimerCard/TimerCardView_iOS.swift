import SwiftUI
import DomainEntities
import CoreInterface
import ComposableArchitecture
import RunningTimer

#if os(iOS)
struct TimerCardView: View {

    private let store: Store<TimerCardState, TimerCardAction>
    @ObservedObject private var viewStore: ViewStore<TimerCardState, TimerCardAction>

    init(store: Store<TimerCardState, TimerCardAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            HStack {
                Text(viewStore.workout.name)
                    .font(.h1)
                Spacer()

                Menu {
                    Button("edit", action: { viewStore.send(.edit) })
                    Button("start", action: { viewStore.send(.start) })
                    Button("delete", role: .destructive, action: { viewStore.send(.delete) })
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.appText)
                }
            }

            HStack(spacing: Spacing.s) {
                Text("mins".localized(viewStore.duration))
                    .font(.h3)

                Text("rounds".localized(viewStore.segmentsCount))
                    .font(.bodyRegular)

                Spacer()

                Button(action: {
                    withAnimation {
                        viewStore.send(.start)
                    }
                }, label: {
                    Image(systemName: "play.fill")
                        .padding(Spacing.s)
                        .foregroundColor(.appWhite)
                        .background(viewStore.workout.color.color)
                        .mask(Circle())
                })
                .frame(width: 40, height: 40)
            }
        }
        .onTapGesture { viewStore.send(.edit) }
        .padding(Spacing.l)
        .background(Color.appCardBackground)
        .cornerRadius(CornerRadius.m)
    }
}

//struct QuickWorkoutCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        ForEach(TintColor.allTints) { tint in
//            TimerCardView(store: Store<TimerCardState, TimerCardAction>(
//                initialState: QuickWorkoutCardState(
//                    workout: QuickWorkout(
//                        id: UUID(),
//                        name: "This is Mock Workout",
//                        color: WorkoutColor(color: tint.color),
//                        segments: [mockSegment1, mockSegment3]
//                    )
//                ),
//                reducer: timerCardReducer,
//                environment: QuickWorkoutCardEnvironment()
//            ))
//            .padding()
//            .previewLayout(.fixed(width: 375, height: 180))
//            .preferredColorScheme(.dark)
//        }
//    }
//}
#endif
