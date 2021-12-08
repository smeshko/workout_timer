import ComposableArchitecture
import XCTest
import DomainEntities
import CorePersistence
@testable import TimersList
import NewTimerForm
import RunningTimer

private let uuid = { UUID(uuidString: "00000000-0000-0000-0000-000000000000")! }
private let scheduler = DispatchQueue.test
private let mockState = TimerCardState(workout: Mocks.mockQuickWorkout1)

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
            $0.workoutStates = [mockState]
            $0.loadingState = .finished
        }
        store.send(.onUpdateQuery("Blah")) {
            $0.query = "Blah"
            $0.workoutStates = []
        }
        store.send(.onUpdateQuery("Mock")) {
            $0.query = "Mock"
            $0.workoutStates = [TimerCardState(workout: Mocks.mockQuickWorkout1)]
        }
        store.send(.workoutCardAction(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, action: .edit)) {
            $0.newTimerFormState = NewTimerFormState(workout: mockState.workout)
            $0.isPresentingTimerForm = true
        }
        store.send(.workoutCardAction(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, action: .start)) {
            $0.isPresentingTimer = true
            $0.timerViewState = TimerViewState(workout: mockState.workout)
        }
        store.send(.workoutCardAction(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, action: .delete))
        store.receive(.didFinishDeleting(.success(["00000000-0000-0000-0000-000000000000"]))) {
            $0.workoutStates = []
        }

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
