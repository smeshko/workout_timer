import XCTest
import WorkoutCore
@testable import QuickTimer
import ComposableArchitecture

class QuickTimerControlsTests: XCTestCase {
    
    func testFlow() {
        let store = TestStore(
            initialState: QuickTimerControlsState(),
            reducer: quickTimerControlsReducer,
            environment: QuickTimerControlsEnvironment()
        )
        
        store.assert(
            .send(.start) {
                $0.isRunning = true
            },
            .send(.pause) {
                $0.isRunning = false
            },
            .send(.start) {
                $0.isRunning = true
            },
            .send(.stop) {
                $0.isRunning = false
            }
        )
    }
}
