import SwiftUI
import DomainEntities
import ComposableArchitecture

public struct CountdownView: View {
    @ObservedObject var viewStore: ViewStore<CountdownState, CountdownAction>

    public init(store: Store<CountdownState, CountdownAction>) {
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        Text("\(viewStore.timeLeft)")
            .font(.giganticMono)
            .foregroundColor(.appWhite)
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
