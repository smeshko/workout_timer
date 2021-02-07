import ComposableArchitecture
import XCTest
import DomainEntities
@testable import WorkoutSettings

class SettingsTest: XCTestCase {

    func testExample() throws {
        let store = TestStore(
            initialState: SettingsState(),
            reducer: settingsReducer,
            environment: SettingsEnvironment(client: .mock)
        )

        store.assert(
            .send(.toggleScreen(true)) {
                $0.keepScreen = true
            },
            .send(.toggleSound(true)) {
                $0.sound = true
            },
            .send(.onboarding(.present)) {
                $0.isPresentingOnboarding = true
            },
            .send(.onboarding(.dismiss)) {
                $0.isPresentingOnboarding = false
            }
        )
    }
}
