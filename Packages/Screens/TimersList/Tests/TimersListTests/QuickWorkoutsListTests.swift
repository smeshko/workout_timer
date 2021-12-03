import ComposableArchitecture
import XCTest
import DomainEntities
import CorePersistence
@testable import TimersList

private let uuid = { UUID(uuidString: "00000000-0000-0000-0000-000000000000")! }
private let scheduler = DispatchQueue.test

class QuickWorkoutsListTests: XCTestCase {

    func testFetchTimers() {
        var repo = QuickWorkoutsRepository.test
        repo.fetchAllWorkouts = { Effect(value: [Mocks.mockQuickWorkout1]).eraseToAnyPublisher() }
        
        let store = TestStore(
            initialState: TimersListState(workouts: []),
            reducer: timersListReducer,
            environment: .mock(
                environment: TimersListEnvironment(
                    repository: repo,
                    notificationClient: .mock
                ),
                mainQueue: scheduler.eraseToAnyScheduler,
                uuid: uuid
            )
        )
        
        store.send(.onAppear) {
            $0.loadingState = .loading
        }
        scheduler.advance()
        store.receive(.didFetchWorkouts(.success([Mocks.mockQuickWorkout1]))) {
            $0.workouts = [Mocks.mockQuickWorkout1]
            $0.workoutStates = [TimerCardState(workout: Mocks.mockQuickWorkout1)]
            $0.loadingState = .finished
        }
        
        scheduler.run()

//        store.assert(
//            .send(.settings(.present)) {
//                $0.isPresentingSettings = true
//            },
//            .send(.settingsAction(.close)),
//            .receive(.settings(.dismiss)) {
//                $0.isPresentingSettings = false
//            }
//        )
//
//        store.assert(
//            .send(.timerForm(.present)) {
//                $0.isPresentingTimerForm = true
//            },
//            .send(.createWorkoutAction(.cancel)),
//            .receive(.timerForm(.dismiss)) {
//                $0.isPresentingTimerForm = false
//            }
//        )
    }
}
