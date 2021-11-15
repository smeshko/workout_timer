import ComposableArchitecture
import XCTest
import DomainEntities
@testable import TimersList

private let uuid = { UUID(uuidString: "c06e5e63-d74f-4291-8673-35ce994754dc")! }
private let newWorkout = QuickWorkout(id: uuid(), name: "", color: .empty, segments: [])

class QuickWorkoutsListTests: XCTestCase {

    func testNavigation() {
        let store = TestStore(
            initialState: TimersListState(workouts: [newWorkout]),
            reducer: timersListReducer,
            environment: .mock(
                environment: TimersListEnvironment(
                    repository: .test,
                    notificationClient: .mock
                ),
                mainQueue: { AnyScheduler(DispatchQueue.testScheduler) },
                uuid: uuid
            )
        )

        store.assert(
            .send(.settings(.present)) {
                $0.isPresentingSettings = true
            },
            .send(.settingsAction(.close)),
            .receive(.settings(.dismiss)) {
                $0.isPresentingSettings = false
            }
        )

        store.assert(
            .send(.timerForm(.present)) {
                $0.isPresentingTimerForm = true
            },
            .send(.createWorkoutAction(.cancel)),
            .receive(.timerForm(.dismiss)) {
                $0.isPresentingTimerForm = false
            }
        )
    }
}
