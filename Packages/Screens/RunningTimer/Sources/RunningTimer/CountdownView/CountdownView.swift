import SwiftUI
import CoreInterface
import DomainEntities
import ComposableArchitecture

public struct CountdownView: View {
    @ObservedObject var viewStore: ViewStore<CountdownState, CountdownAction>

    public init(store: Store<CountdownState, CountdownAction>) {
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Spacer()
                Text("\(viewStore.timeLeft)")
                    .font(.giganticMono)
                    .foregroundColor(.appWhite)
                Spacer()
            }
            
            Button {
                viewStore.send(.skip)
            } label: {
                Text("Skip")
                    .font(.h4)
                    .foregroundColor(.appWhite)
            }
            .padding(.vertical, Spacing.m)
            .padding(.horizontal, Spacing.xl)
            .background(Capsule().foregroundColor(.appGrey).opacity(0.3))
            .padding(.bottom, Spacing.xxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .ignoresSafeArea(.all)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.appSecondary.monochromatic, .appSecondary]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onAppear {
            viewStore.send(.start)
        }
    }
}

private extension TimeInterval {
    var clean: String {
        guard self >= 0 else { return String(format: "%.0f", 0) }
        return String(format: "%.0f", self)
    }
}

//struct CountdownView_Previews: PreviewProvider {
//    static var previews: some View {
//        return CountdownView(
//            store: Store<CountdownState, CountdownAction>(
//                initialState: CountdownState(),
//                reducer: countdownReducer,
//                environment: .preview
//            )
//        )
//    }
//}
