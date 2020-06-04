import XCTest
import ComposableArchitecture
import WorkoutCore
@testable import WorkoutFeed

let workout = Workout(id: "workout-1", name: "Mock workout", image: "image", sets: [])
let category = WorkoutCategory(id: "category-1", name: "Mock category", workouts: [workout])

class WorkoutFeedTests: XCTestCase {

    let scheduler = DispatchQueue.testScheduler

    func testFlow() {
        let store = TestStore(
            initialState: WorkoutsFeedState(),
            reducer: workoutsFeedReducer,
            environment: WorkoutsFeedEnvironment(
                service: .mock,
                mainQueue: AnyScheduler(self.scheduler)
            )
        )
        
        store.assert(
            .send(.beginNavigation),
            .do {
                self.scheduler.advance()
            },
            .receive(.categoriesLoaded(.success([category]))) {
                $0.categories = [category]
            },
            .receive(.workoutCategoryChanged(category)) {
                $0.selectedCategory = category
            }
        )
    }
}
