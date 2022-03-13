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
                .styling(font: .gigantic)

            Spacer()

            VStack(alignment: .leading, spacing: Spacing.l) {
                InfoView(image: "suit.heart.fill", color: .orange,
                         title: "onboarding_title_1",
                         text: "onboarding_text_1")
                InfoView(image: "timer", color: .blue,
                         title: "onboarding_title_2",
                         text: "onboarding_text_2")
                InfoView(image: "icloud.fill", color: .red,
                         title: "onboarding_title_3",
                         text: "onboarding_text_3")
            }

            Spacer()

            Button(action: {
                withAnimation {
                    viewStore.send(.start)
                }
            }, label: {
                Text(key: "start")
                    .padding(.vertical, Spacing.m)
                    .styling(font: .h3, color: .appWhite)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(CornerRadius.m)
            })
        }
        .transition(.opacity)
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
    let title: LocalizedStringKey
    let text: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: image)
                .styling(font: .h1, color: color)
                .frame(width: 40, height: 40, alignment: .top)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(key: title)
                    .styling(font: .h3)
                Text(key: text)
                    .styling(font: .bodyRegular)
            }
            Spacer()
        }
        .fullWidth()
    }
}
