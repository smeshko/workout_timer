import XCTest
import WorkoutCore
@testable import QuickTimer
import ComposableArchitecture

class QuickExerciseBuilderTests: XCTestCase {
    
    let uuid: () -> UUID = {
        UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    }
    
    func segment(pause: TimeInterval, work: TimeInterval) -> QuickTimerSet {
        QuickTimerSet(id: uuid, work: work, pause: pause)
    }

    func testFlow() {
//        let store = TestStore(
//            initialState: AddTimerSegmentState(),
//            reducer: quickExerciseBuilderReducer,
//            environment: AddTimerSegmentEnvironment(uuid: self.uuid)
//        )
//        
//        store.assert(
//            .send(.setNavigation) {
//                $0.segments = []
//            },
//            .receive(.updatedSegments([])),
//            .send(.changeSetsCount(.valueUpdated(2))) {
//                $0.setsState.value = 2
//                $0.segments = [
//                    self.segment(pause: 0, work: 0),
//                    self.segment(pause: 0, work: 0)
//                ]
//            },
//            .receive(.updatedSegments([
//                self.segment(pause: 0, work: 0),
//                self.segment(pause: 0, work: 0)
//            ])),
//            .send(.changeWorkoutTime(.valueUpdated(10))) {
//                $0.workoutTimeState.value = 10
//                $0.segments = [
//                    self.segment(pause: 0, work: 10),
//                    self.segment(pause: 0, work: 10)
//                ]
//            },
//            .receive(.updatedSegments([
//                self.segment(pause: 0, work: 10),
//                self.segment(pause: 0, work: 10)
//            ]))
//        )
    }
}
