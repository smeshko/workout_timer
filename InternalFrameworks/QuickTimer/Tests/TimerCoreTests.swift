import XCTest
import WorkoutCore
@testable import QuickTimer
import ComposableArchitecture

class TimerCoreTests: XCTestCase {

    let scheduler = DispatchQueue.testScheduler
    
    func testFlow() {
        let store = TestStore(
          initialState: QuickTimerState(circuitPickerState: QuickExerciseBuilderState(sets: 1, workoutTime: 60, breakTime: 20)),
            reducer: quickTimerReducer,
            environment: QuickTimerEnvironment(
                mainQueue: AnyScheduler(self.scheduler),
                soundClient: .mock
            )
        )
        
      store.assert(
        
        .send(.circuitPickerUpdatedValues(.updatedSegments([Segment(duration: 60, category: .workout)]))) {
          $0.segments = [Segment(duration: 60, category: .workout)]
        },
        
        .send(.setNavigation) {
          $0.segments = [
            Segment(duration: 60, category: .workout),
          ]
        }
      
      )
      
//        store.assert(
//            .send(.changeSetsCount(2)) {
//                $0.sets = 2
//            },
//            .send(.changeBreakTime(30)) {
//                $0.breakTime = 30
//            },
//            .send(.changeWorkoutTime(60)) {
//                $0.workoutTime = 60
//            },
//            .send(.start) {
//                $0.totalTimeLeft = 150
//                $0.currentSegment = $0.segments.first
//            },
//            .send(.timerFinished)
//
    }
    
}
