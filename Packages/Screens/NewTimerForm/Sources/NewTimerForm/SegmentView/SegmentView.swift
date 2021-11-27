import SwiftUI
import CoreInterface
import ComposableArchitecture

struct SegmentView: View {
    let store: Store<SegmentState, SegmentAction>
    let isInputActive: FocusState<Bool>

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    TextField("exercise name", text: viewStore.binding(\.$name))
                        .focused(isInputActive.projectedValue)
                        .font(.h3)
                        .foregroundColor(viewStore.color)

                    Text("Rest")
                        .font(.h3)
                        .foregroundColor(.appPrimary)

                    Text("Sets")
                        .font(.h3)
                        .foregroundColor(.appSuccess)
                }

                Spacer()

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    DurationSetView(value: viewStore.binding(\.$work), step: 5, timeFormatted: true)
                    DurationSetView(value: viewStore.binding(\.$rest), step: 5, timeFormatted: true)
                    DurationSetView(value: viewStore.binding(\.$sets), step: 1, timeFormatted: false)
                }
            }
        }
    }
}

private struct DurationSetView: View {
    @Binding var value: Int
    let step: Int
    let timeFormatted: Bool

    var body: some View {
        HStack {
            Button {
                guard value >= step else { return }
                value -= step
            } label: {
                Image(systemName: "minus")
                    .font(.h4)
                    .foregroundColor(.appText)
            }
            .buttonStyle(BorderlessButtonStyle())

            Text(timeFormatted ? value.formattedTimeLeft : "\(value)")
                .font(.h3)
                .monospacedDigit()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            Button {
                value += step
            } label: {
                Image(systemName: "plus")
                    .font(.h4)
                    .foregroundColor(.appText)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}
//struct SegmentView_Previews: PreviewProvider {
//    static var previews: some View {
//        SegmentView(
//            store: Store<SegmentState, SegmentAction>(
//                initialState: SegmentState(id: UUID(), name: "Jumping rope", sets: 3, rest: 30, work: 90),
//                reducer: segmentReducer,
//                environment: SegmentEnvironment()
//            )
//        )
//        .padding()
//        .previewLayout(.sizeThatFits)
//    }
//}
