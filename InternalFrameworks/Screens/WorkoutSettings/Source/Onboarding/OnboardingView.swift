import SwiftUI
import ComposableArchitecture
import CoreLogic
import CoreInterface

public enum OnboardingAction {
    case start
}

public struct OnboardingState: Equatable {
    public init() {}
}

public let onboardingReducer = Reducer<OnboardingState, OnboardingAction, Void> { state, action, _ in

    return .none
}

public struct OnboardingView: View {
    private let store: Store<OnboardingState, OnboardingAction>
    @ObservedObject private var viewStore: ViewStore<OnboardingState, OnboardingAction>

    public init(store: Store<OnboardingState, OnboardingAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        VStack(spacing: Spacing.xl) {
            Text("Welcome!")
                .font(.gigantic)
                .foregroundColor(.appText)

            Spacer()

            VStack(alignment: .leading, spacing: Spacing.l) {
                InfoView(image: "suit.heart.fill", color: .orange,
                         title: "Create timers",
                         text: "It's easy to create new workout timers! Add as many rounds to each one as you wish.")
                InfoView(image: "timer", color: .blue,
                         title: "Focus on training",
                         text: "The app will guide you through your workout. You'll always have all the important information at a glance.")
                InfoView(image: "icloud.fill", color: .red,
                         title: "Sync across devices",
                         text: "Timers you create on one device will be automatically synced to all your other iCloud enabled devices.")
            }

            Spacer()

            Button(action: {
                withAnimation {
                    viewStore.send(.start)
                }
            }, label: {
                Text("Start")
                    .padding(.vertical, Spacing.m)
                    .font(.h3)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.appWhite)
                    .cornerRadius(CornerRadius.m)
            })
        }
        .transition(.opacity)
        .animation(.default)
        .padding(Spacing.xxl)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store<OnboardingState, OnboardingAction>(
            initialState: OnboardingState(),
            reducer: .empty,
            environment: ()
        )

        return Group {
            OnboardingView(store: store)
                .previewDevice(.iPhone8)

            OnboardingView(store: store)
                .previewDevice(.iPhone11)
                .preferredColorScheme(.dark)
        }
    }
}

private struct InfoView: View {
    let image: String
    let color: Color
    let title: String
    let text: String

    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: image)
                .foregroundColor(color)
                .font(.h1)
                .frame(width: 40, height: 40, alignment: .top)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(title)
                    .font(.h3)
                Text(text)
                    .font(.bodyRegular)
            }
            Spacer()
        }
        .fullWidth()
    }
}
