import XCTest
import WorkoutCore
@testable import QuickTimer
import ComposableArchitecture

class ValuePickerTests: XCTestCase {
    
    func testFlow() {
        let store = TestStore(
            initialState: PickerState(),
            reducer: pickerReducer,
            environment: PickerEnvironment()
        )
        
        store.assert(
            .send(.valueUpdated(5)) {
                $0.isShowingPicker = false
                $0.value = 5
            },
            .send(.togglePickerVisibility) {
                $0.isShowingPicker = true
            }
        )
    }
}
