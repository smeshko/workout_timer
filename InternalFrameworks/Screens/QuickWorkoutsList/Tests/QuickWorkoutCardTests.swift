import XCTest
import RunningTimer
import DomainEntities
import ComposableArchitecture
@testable import QuickWorkoutsList

class QuickWorkoutCardTests: XCTestCase {

    let workout = QuickWorkout(id: UUID(), name: "Mock", color: .empty, segments: [])

    func test() {
        let store = TestStore(
            initialState: QuickWorkoutCardState(workout: workout),
            reducer: quickWorkoutCardReducer,
            environment: QuickWorkoutCardEnvironment(notificationClient: .mock)
        )

        store.assert(
            .send(.tapStart) {
                $0.runningTimerState = RunningTimerState(workout: self.workout)
            }
        )
    }
}
