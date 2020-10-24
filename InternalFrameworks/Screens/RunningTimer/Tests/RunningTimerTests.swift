import XCTest
import Foundation
import DomainEntities
@testable import CoreLogic
import ComposableArchitecture
@testable import RunningTimer

class RunningTimerTests: XCTestCase {

    let testScheduler = DispatchQueue.testScheduler
    let sections = [
        TimerSection(duration: 2, type: .work),
        TimerSection(duration: 1, type: .pause)
    ]

    func testFlow() {
        let store = TestStore(
            initialState: RunningTimerState(
                workout: QuickWorkout(
                    id: UUID(),
                    name: "Mock Workout",
                    color: WorkoutColor(hue: 0, saturation: 0, brightness: 0),
                    segments: [
                        QuickWorkoutSegment(id: UUID(), sets: 1, work: 2, pause: 1)
                    ])
                ),
                reducer: runningTimerReducer,
                environment: RunningTimerEnvironment(
                    mainQueue: AnyScheduler(testScheduler),
                    soundClient: .mock
                )
            )

        store.assert(
            .send(.onAppear) {
                $0.currentSection = self.sections.first
                $0.totalTimeLeft = 3
                $0.sectionTimeLeft = 2
            },

            // pre countdown
            .receive(.timerControlsUpdatedState(.start)) {
                $0.timerControlsState.timerState = .running
            },
            .do { self.testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.preCountdownTimeLeft = 2
            },
            .do { self.testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.preCountdownTimeLeft = 1
            },
            .do { self.testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.preCountdownTimeLeft = 0
            },
            .receive(.preCountdownFinished) {
                $0.isInPreCountdown = false
            },

            // work section
            .do { self.testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.totalTimeLeft = 2
                $0.sectionTimeLeft = 1
            },
            .do { self.testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.totalTimeLeft = 1
                $0.sectionTimeLeft = 0
            },

            // pause section
            .receive(.sectionEnded) {
                $0.currentSection = self.sections[1]
                $0.sectionTimeLeft = 1
                $0.finishedSections = 1
            },
            .do { self.testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.totalTimeLeft = 0
                $0.sectionTimeLeft = 0
                $0.finishedSections = 1
            },

            // finish
            .receive(.timerFinished) {
                $0.timerControlsState.timerState = .finished
            }
        )
        
    }

}
