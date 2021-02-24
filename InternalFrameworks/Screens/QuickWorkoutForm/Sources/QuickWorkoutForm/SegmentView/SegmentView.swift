import SwiftUI
import CoreInterface
import ComposableArchitecture

struct SegmentView: View {
    let store: Store<SegmentState, SegmentAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(viewStore.name)
                    .font(.h2)
                    .foregroundColor(.appText)

                HStack(alignment: .bottom, spacing: 3) {
                    Text("\(viewStore.sets)")
                        .font(.h3)
                        .foregroundColor(.orange)
                        +
                    Text(key: "sets_of")
                        .font(.h4)
                        .foregroundColor(.appText)

                    Text("\(viewStore.work)")
                        .font(.h3)
                        .foregroundColor(.blue)
                        +
                    Text(key: "seconds_work")
                        .font(.h4)
                        .foregroundColor(.appText)

                    Text("\(viewStore.rest)")
                        .font(.h3)
                        .foregroundColor(.red)
                        +
                    Text(key: "seconds_rest")
                        .font(.h4)
                        .foregroundColor(.appText)
                }
            }
            .fullWidth()
            .cardBackground()
        }
    }
}

struct SegmentView_Previews: PreviewProvider {
    static var previews: some View {
        SegmentView(
            store: Store<SegmentState, SegmentAction>(
                initialState: SegmentState(id: UUID(), name: "Jumping rope", sets: 3, rest: 30, work: 90),
                reducer: segmentReducer,
                environment: SegmentEnvironment()
            )
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
