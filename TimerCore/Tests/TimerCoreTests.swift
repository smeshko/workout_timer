import XCTest
@testable import TimerCore
import ComposableArchitecture
import ComposableArchitectureTestSupport

class TimerCoreTests: XCTestCase {

    let scheduler = DispatchQueue.testScheduler
    
    func testFlow() {
        let store = TestStore(
            initialState: TimerState(),
            reducer: timerReducer,
            environment: TimerEnvironment(
                mainQueue: AnyScheduler(self.scheduler),
                soundClient: .mock
            )
        )
        
        store.assert(
            .send(.changeSetsCount(2)) {
                $0.sets = 2
            },
            .send(.changeBreakTime(30)) {
                $0.breakTime = 30
            },
            .send(.changeWorkoutTime(60)) {
                $0.workoutTime = 60
            },
            .send(.start) {
                $0.totalTimeLeft = 150
                $0.currentSegment = $0.segments.first
            },
            .send(.timerFinished)
            
        )
    }
    
}
