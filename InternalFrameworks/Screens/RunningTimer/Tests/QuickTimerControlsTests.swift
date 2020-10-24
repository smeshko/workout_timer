import XCTest
import ComposableArchitecture
@testable import RunningTimer

class QuickTimerControlsTests: XCTestCase {
    
    func testFlow() {
        let store = TestStore(
            initialState: QuickTimerControlsState(),
            reducer: quickTimerControlsReducer,
            environment: QuickTimerControlsEnvironment()
        )

        store.assert(
            .send(.start) {
                $0.timerState = .running
            },
            .send(.pause) {
                $0.timerState = .paused
            },
            .send(.start) {
                $0.timerState = .running
            },
            .send(.stop) {
                $0.timerState = .finished
            }
        )
    }
}
