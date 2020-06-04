import XCTest
import WorkoutCore
@testable import QuickTimer
import ComposableArchitecture

class TimerCoreTests: XCTestCase {
    
    let scheduler = DispatchQueue.testScheduler
    
    let uuid: () -> UUID = {
        UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    }
    
    let workSegment = Segment(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, duration: 2, category: .workout)
    let pauseSegment = Segment(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, duration: 1, category: .pause)
    
    func testFlow() {
        let store = TestStore(
            initialState: QuickTimerState(circuitPickerState: QuickExerciseBuilderState(sets: 1, workoutTime: 60, breakTime: 20)),
            reducer: quickTimerReducer,
            environment: QuickTimerEnvironment(
                uuid: self.uuid,
                mainQueue: AnyScheduler(self.scheduler),
                soundClient: .mock
            )
        )
        
        store.assert(
            .send(.circuitPickerUpdatedValues(.updatedSegments([workSegment, pauseSegment]))) {
                $0.currentSegment = self.workSegment
                $0.totalTimeLeft = 3
                $0.segmentTimeLeft = 2
                $0.segments = [
                    self.workSegment,
                    self.pauseSegment
                ]
            },
            .send(.timerControlsUpdatedState(.start)) {
                $0.isRunning = true
                $0.timerControlsState.isRunning = true
                $0.circuitPickerState.breakTimeState.isInteractionDisabled = true
                $0.circuitPickerState.workoutTimeState.isInteractionDisabled = true
                $0.circuitPickerState.setsState.isInteractionDisabled = true
            },
            .do {
                self.scheduler.advance(by: 1)
            },
            .receive(.timerTicked) {
                $0.totalTimeLeft = 2
                $0.segmentTimeLeft = 1
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
                $0.currentSegment = self.pauseSegment
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
                $0.isRunning = false
                $0.currentSegment = nil
                $0.timerControlsState.isRunning = false
                $0.circuitPickerState.breakTimeState.isInteractionDisabled = false
                $0.circuitPickerState.workoutTimeState.isInteractionDisabled = false
                $0.circuitPickerState.setsState.isInteractionDisabled = false
            }
        )
    }
    
}

















































