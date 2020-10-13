import XCTest
import WorkoutCore
@testable import QuickTimer
import ComposableArchitecture

class TimerCoreTests: XCTestCase {
    
    let scheduler = DispatchQueue.testScheduler
    
    static let uuid: () -> UUID = {
        UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    }
    
    let segments = [QuickTimerSet(id: uuid, work: 1, pause: 1), QuickTimerSet(id: uuid, work: 1, pause: 0)]
    
    func testFlow() {
//        let store = TestStore(
//            initialState: QuickTimerState(
//                circuitPickerState: AddTimerSegmentState(sets: 1, workoutTime: 60, breakTime: 20)),
//            reducer: quickTimerReducer,
//            environment: QuickTimerEnvironment(
//                uuid: TimerCoreTests.uuid,
//                mainQueue: AnyScheduler(self.scheduler),
//                soundClient: .mock,
//                timerStep: 1
//            )
//        )
//
//        store.assert(
//            .send(.circuitPickerUpdatedValues(.updatedSegments(segments))) {
//                $0.segments = self.segments
//            },
//            .send(.setRunningTimer(isPresented: true)) {
//                $0.isRunningTimerPresented = true
//                $0.runningTimerState = RunningTimerState(segments: self.segments)
//            },
//            .send(.setRunningTimer(isPresented: false)) {
//                $0.isRunningTimerPresented = false
//                $0.runningTimerState = RunningTimerState()
//            }
//        )
    }
    
}
