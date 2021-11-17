import SwiftUI
import ComposableArchitecture

public struct CountdownView: View {
    @ObservedObject var viewStore: ViewStore<CountdownState, CountdownAction>

    public init(store: Store<CountdownState, CountdownAction>) {
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        Text("\(viewStore.timeLeft)")
            .font(.giganticMono)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .ignoresSafeArea(.all)
            .background(viewStore.workoutColor.color)
    }
}

private extension TimeInterval {
    var clean: String {
        guard self >= 0 else { return String(format: "%.0f", 0) }
        return String(format: "%.0f", self)
    }
}
