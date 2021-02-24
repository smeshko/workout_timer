import XCTest
import CoreLogic
import ComposableArchitecture
@testable import WorkoutSettings

class SettingsTests: XCTestCase {

    func testFlow() {
        let store = TestStore(
            initialState: SettingsState(),
            reducer: settingsReducer,
            environment: SettingsEnvironment(client: .mock)
        )

        store.assert(
            .send(.onAppear) {
                $0.keepScreen = false
                $0.sound = false
            },
            .send(.toggleSound(true)) {
                $0.sound = true
            },
            .send(.toggleScreen(true)) {
                $0.keepScreen = true
            }
        )
    }
}
