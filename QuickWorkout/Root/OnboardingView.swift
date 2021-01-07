import SwiftUI
import ComposableArchitecture
import CoreLogic
import CoreInterface

enum OnboardingAction {
    case start
}

struct OnboardingState: Equatable {}

let onboardingReducer = Reducer<OnboardingState, OnboardingAction, Void> { state, action, _ in

    return .none
}

struct OnboardingView: View {
    private let store: Store<OnboardingState, OnboardingAction>
    @ObservedObject private var viewStore: ViewStore<OnboardingState, OnboardingAction>

    init(store: Store<OnboardingState, OnboardingAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Text("Welcome!")
                .font(.gigantic)
                .foregroundColor(.appText)
                .padding(.top, 100)
                .padding(.bottom, 100)

            VStack(alignment: .leading, spacing: Spacing.l) {
                InfoView(image: "suit.heart.fill", color: .orange,
                         title: "Create workouts",
                         text: "It's easy to create a new workout! Add as many intervals to it as you want.")
                InfoView(image: "timer", color: .blue,
                         title: "Follow your routine",
                         text: "Following the workout you've setup is easy. The timer will help you keep track of exercises and progress!")
                InfoView(image: "icloud.fill", color: .red,
                         title: "Sync across all devices",
                         text: "Workouts you create on one device will be automatically synced to all your other iCloud enabled devices.")
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
        OnboardingView(
            store: Store<OnboardingState, OnboardingAction>(
                initialState: OnboardingState(),
                reducer: .empty,
                environment: ()
            )
        )
    }
}

private struct InfoView: View {
    let image: String
    let color: Color
    let title: String
    let text: String

    var body: some View {
        HStack {
            Image(systemName: image)
                .foregroundColor(color)
                .font(.h1)
                .frame(width: 50, height: 50, alignment: .center)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.h3)
                Text(text)
                    .font(.bodyLarge)
            }
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity)
    }
}
