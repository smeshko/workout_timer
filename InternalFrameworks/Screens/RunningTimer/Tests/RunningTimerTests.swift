import XCTest
import Foundation
import DomainEntities
@testable import CoreLogic
import ComposableArchitecture
@testable import RunningTimer

class RunningTimerTests: XCTestCase {

    let testScheduler = DispatchQueue.testScheduler

    func testFlow() {
        let store = TestStore(
            initialState: RunningTimerState(
                workout: QuickWorkout(
                    id: UUID(),
                    name: "Mock Workout",
                    color: WorkoutColor(hue: 0, saturation: 0, brightness: 0),
                    segments: [
                        QuickWorkoutSegment(id: UUID(), sets: 1, work: 2, pause: 1),
                        QuickWorkoutSegment(id: UUID(), sets: 1, work: 4, pause: 1)
                    ])
                ),
                reducer: runningTimerReducer,
                environment: RunningTimerEnvironment(
                    mainQueue: AnyScheduler(testScheduler),
                    soundClient: .mock
                )
            )

        let sections = [
            TimerSection(duration: 2, type: .work),
            TimerSection(duration: 1, type: .pause),
            TimerSection(duration: 4, type: .work),
            TimerSection(duration: 1, type: .pause)
        ]

        store.assert(
            .send(.onAppear) {
                $0.currentSection = sections.first
                $0.totalTimeLeft = 7
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

            // 1. work section
            .do { self.testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.totalTimeLeft = 6
                $0.sectionTimeLeft = 1
            },
            .do { self.testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.totalTimeLeft = 5
                $0.sectionTimeLeft = 0
            },

            // pause section
            .receive(.sectionEnded) {
                $0.currentSection = sections[1]
                $0.sectionTimeLeft = 1
                $0.finishedSections = 1
            },
            .do { self.testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.totalTimeLeft = 4
                $0.sectionTimeLeft = 0
                $0.finishedSections = 1
            },

            // 2. work section
            .receive(.sectionEnded) {
                $0.currentSection = sections[2]
                $0.sectionTimeLeft = 4
            },
            .do { self.testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.totalTimeLeft = 3
                $0.sectionTimeLeft = 3
            },
            .do { self.testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.totalTimeLeft = 2
                $0.sectionTimeLeft = 2
            },
            .do { self.testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.totalTimeLeft = 1
                $0.sectionTimeLeft = 1
            },
            .do { self.testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.totalTimeLeft = 0
                $0.sectionTimeLeft = 0
            },

            // finish
            .receive(.timerFinished) {
                $0.timerControlsState.timerState = .finished
            }
        )
    }

    func testCloseTimer() {
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

        let sections = [
            TimerSection(duration: 2, type: .work),
            TimerSection(duration: 1, type: .pause)
        ]

        store.assert(
            .send(.onAppear) {
                $0.currentSection = sections.first
                $0.totalTimeLeft = 2
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

            // close
            .do { self.testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.totalTimeLeft = 1
                $0.sectionTimeLeft = 1
            },
            .send(.alertButtonTapped) {
                $0.alert = .init(
                    title: "Stop workout?",
                    message: "Are you sure you want to stop this workout?",
                    primaryButton: .cancel(send: .timerControlsUpdatedState(.start)),
                    secondaryButton: .default("Yes", send: .timerClosed)
                )
            },
            .receive(.timerControlsUpdatedState(.pause)) {
                $0.timerControlsState.timerState = .paused
            },
            .send(.timerClosed) {
                $0.isPresented = false
            },

            // finish
            .receive(.timerFinished) {
                $0.alert = nil
                $0.timerControlsState.timerState = .finished
            }
        )
    }

    func testPlayPause() {
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

        let sections = [
            TimerSection(duration: 2, type: .work),
            TimerSection(duration: 1, type: .pause)
        ]

        store.assert(
            .send(.onAppear) {
                $0.currentSection = sections.first
                $0.totalTimeLeft = 2
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

            // pause / play / pause
            .do { self.testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.totalTimeLeft = 1
                $0.sectionTimeLeft = 1
            },
            .send(.timerControlsUpdatedState(.pause)) {
                $0.timerControlsState.timerState = .paused
            },
            .send(.timerControlsUpdatedState(.start)) {
                $0.timerControlsState.timerState = .running
            },
            .send(.timerControlsUpdatedState(.pause)) {
                $0.timerControlsState.timerState = .paused
            }
        )
    }
}
