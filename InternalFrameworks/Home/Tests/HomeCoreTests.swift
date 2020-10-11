import XCTest
import ComposableArchitecture
import WorkoutCore
@testable import Home

class HomeCoreTests: XCTestCase {

    let scheduler = DispatchQueue.testScheduler

    let featuredWorkout = Workout(id: "workout-1", name: "Mock workout", imageKey: "image", sets: [])
    let category = WorkoutCategory(id: "category-1", name: "Mock category", workouts: [
        Workout(id: "workout-1", name: "Mock workout", imageKey: "image", sets: [])
    ])

    func testFlow() {
//        let store = TestStore(
//            initialState: HomeState(),
//            reducer: homeReducer,
//            environment: HomeEnvironment(
//                service: .mock,
//                mainQueue: AnyScheduler(self.scheduler)
//            )
//        )
//
//        store.assert(
//            .send(.beginNavigation) {
//                $0.loadingState = .loading
//            },
//            .receive(.featuredLoaded(.success([featuredWorkout]))) {
//                $0.loadingState = .done
//                $0.featuredWorkouts = [self.featuredWorkout]
//                $0.selectedFeaturedWorkout = self.featuredWorkout
//            },
//            .receive(.categoriesLoaded(.success([category]))) {
//                $0.categories = [self.category]
//            },
//            .receive(.workoutCategoryChanged(category)) {
//                $0.selectedCategory = self.category
//            }
//        )

    }
}
