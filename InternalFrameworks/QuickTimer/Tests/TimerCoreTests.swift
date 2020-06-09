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
        let store = TestStore(
            initialState: QuickTimerState(circuitPickerState: QuickExerciseBuilderState(sets: 1, workoutTime: 60, breakTime: 20)),
            reducer: quickTimerReducer,
            environment: QuickTimerEnvironment(
                uuid: TimerCoreTests.uuid,
                mainQueue: AnyScheduler(self.scheduler),
                soundClient: .mock,
                timerStep: 1
            )
        )
        
        store.assert(
            .send(.circuitPickerUpdatedValues(.updatedSegments(segments))) {
                $0.currentSegment = self.segments.first?.work
                $0.totalTimeLeft = 3
                $0.segmentTimeLeft = 1
                $0.segments = self.segments
            },
            .send(.timerControlsUpdatedState(.start)) {
                $0.timerControlsState.timerState = .running
                $0.circuitPickerState.breakTimeState.isInteractionDisabled = true
                $0.circuitPickerState.workoutTimeState.isInteractionDisabled = true
                $0.circuitPickerState.setsState.isInteractionDisabled = true
            },
            .do {
                self.scheduler.advance(by: 1)
            },
            .receive(.timerTicked) {
                $0.totalTimeLeft = 2
                $0.segmentTimeLeft = 0
            },
            .receive(.segmentEnded) {
                $0.segmentTimeLeft = 1
                $0.currentSegment = self.segments.first?.pause
            },
            .do {
                self.scheduler.advance(by: 1)
            },
            .receive(.timerTicked) {
                $0.totalTimeLeft = 1
                $0.segmentTimeLeft = 0
            },
            .receive(.segmentEnded) {
                $0.segmentTimeLeft = 1
                $0.currentSegment = self.segments.last?.work
            },
            .do {
                self.scheduler.advance(by: 1)
            },
            .receive(.timerTicked) {
                $0.totalTimeLeft = 0
                $0.segmentTimeLeft = 0
            },
            .receive(.timerFinished) {
                $0.circuitPickerState.setsState.value = 2
                $0.segments = []
                $0.currentSegment = nil
                $0.timerControlsState.timerState = .finished
                $0.circuitPickerState.breakTimeState.isInteractionDisabled = false
                $0.circuitPickerState.workoutTimeState.isInteractionDisabled = false
                $0.circuitPickerState.setsState.isInteractionDisabled = false
            }
        )
    }
    
}
