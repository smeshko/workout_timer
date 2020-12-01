import SwiftUI
import ComposableArchitecture

struct SegmentView: View {
    let store: Store<SegmentState, SegmentAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: 8) {
                Text(viewStore.name)
                    .font(.h2)
                    .foregroundColor(.appText)

                HStack(alignment: .bottom, spacing: 3) {
                    Text("\(viewStore.sets)")
                        .font(.h3)
                        .foregroundColor(.orange)
                        +
                        Text(" sets of")
                        .font(.h4)
                        .foregroundColor(.appText)

                    Text("\(viewStore.work)")
                        .font(.h3)
                        .foregroundColor(.blue)
                        +
                        Text("s work and ")
                        .font(.h4)
                        .foregroundColor(.appText)
                        +
                        Text("\(viewStore.rest)")
                        .font(.h3)
                        .foregroundColor(.red)
                        +
                        Text("s rest")
                        .font(.h4)
                        .foregroundColor(.appText)
                }
            }
            .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealWidth: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            .padding(.vertical, 18)
            .background(Color.appCardBackground)
            .cornerRadius(12)
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
