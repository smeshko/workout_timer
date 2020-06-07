import XCTest
import WorkoutCore
@testable import QuickTimer
import ComposableArchitecture

class QuickExerciseBuilderTests: XCTestCase {
    
    let uuid: () -> UUID = {
        UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    }
    
    func segment(duration: TimeInterval, category: Segment.Category) -> Segment {
        Segment(id: uuid(), duration: duration, category: category)
    }

    func testFlow() {
        let store = TestStore(
            initialState: QuickExerciseBuilderState(),
            reducer: quickExerciseBuilderReducer,
            environment: QuickExerciseBuilderEnvironment(uuid: self.uuid)
        )
        
        store.assert(
            .send(.setNavigation) {
                $0.segments = []
            },
            .receive(.updatedSegments([])),
            .send(.changeSetsCount(.valueUpdated(2))) {
                $0.setsState.value = 2
                $0.segments = [
                    self.segment(duration: 0, category: .workout),
                    self.segment(duration: 0, category: .pause),
                    self.segment(duration: 0, category: .workout)
                ]
            },
            .receive(.updatedSegments([
                self.segment(duration: 0, category: .workout),
                self.segment(duration: 0, category: .pause),
                self.segment(duration: 0, category: .workout)
            ])),
            .send(.changeWorkoutTime(.valueUpdated(10))) {
                $0.workoutTimeState.value = 10
                $0.segments = [
                    self.segment(duration: 10, category: .workout),
                    self.segment(duration: 0, category: .pause),
                    self.segment(duration: 10, category: .workout)
                ]
            },
            .receive(.updatedSegments([
                self.segment(duration: 10, category: .workout),
                self.segment(duration: 0, category: .pause),
                self.segment(duration: 10, category: .workout)
            ]))
        )
    }
}
