import XCTest
import CoreLogic
@testable import QuickWorkoutsList
import ComposableArchitecture

class RunningTimerCoreTests: XCTestCase {

    let scheduler = DispatchQueue.testScheduler

    static let uuid: () -> UUID = {
        UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    }

//    let segments = [QuickTimerSet(id: uuid, work: 1, pause: 1), QuickTimerSet(id: uuid, work: 1, pause: 0)]

    func testFlow() {
//        let store = TestStore(
//            initialState: RunningTimerState(segments: segments),
//            reducer: runningTimerReducer,
//            environment: RunningTimerEnvironment(
//                uuid: RunningTimerCoreTests.uuid,
//                mainQueue: AnyScheduler(self.scheduler),
//                soundClient: .mock,
//                timerStep: 1
//            )
//        )
//
//        store.assert(
//            .send(.didAppear) {
//                $0.totalTimeLeft = 3
//                $0.currentSegment = self.segments.first?.work
//                $0.segmentTimeLeft = 1
//            },
//            .receive(.timerControlsUpdatedState(.start)) {
//                $0.timerControlsState.timerState = .running
//            },
//            .do {
//                self.scheduler.advance(by: 1)
//            },
//            .receive(.timerTicked) {
//                $0.totalTimeLeft = 2
//                $0.segmentTimeLeft = 0
//            },
//            .receive(.segmentEnded) {
//                $0.segmentTimeLeft = 1
//                $0.finishedSegments = 1
//                $0.currentSegment = self.segments.first?.pause
//            },
//            .do {
//                self.scheduler.advance(by: 1)
//            },
//            .receive(.timerTicked) {
//                $0.totalTimeLeft = 1
//                $0.segmentTimeLeft = 0
//            },
//            .receive(.segmentEnded) {
//                $0.segmentTimeLeft = 1
//                $0.currentSegment = self.segments.last?.work
//            },
//            .do {
//                self.scheduler.advance(by: 1)
//            },
//            .receive(.timerTicked) {
//                $0.totalTimeLeft = 0
//                $0.segmentTimeLeft = 0
//            },
//            .receive(.timerFinished) {
//                $0.finishedSegments = 0
//                $0.segments = []
//                $0.currentSegment = nil
//                $0.timerControlsState.timerState = .finished
//            }
//        )
    }

}
