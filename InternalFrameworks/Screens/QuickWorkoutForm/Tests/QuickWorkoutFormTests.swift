import XCTest
import ComposableArchitecture
import CorePersistence
@testable import QuickWorkoutForm

class QuickWorkoutFormTests: XCTestCase {

    func testFlow() {
        let store = TestStore(
            initialState: PickerState(),
            reducer: pickerReducer,
            environment: PickerEnvironment()
        )

        let store2 = TestStore(
            initialState: AddTimerSegmentState(id: UUID()),
            reducer: addTimerSegmentReducer,
            environment: AddTimerSegmentEnvironment(uuid: UUID.init)
        )

        let store3 = TestStore(
            initialState: CreateQuickWorkoutState(),
            reducer: createQuickWorkoutReducer,
            environment: CreateQuickWorkoutEnvironment(mainQueue: AnyScheduler(DispatchQueue.testScheduler), repository: .mock)
        )
    }
}
