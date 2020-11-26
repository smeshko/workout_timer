import XCTest
import Foundation
import DomainEntities
@testable import CoreLogic
import ComposableArchitecture
@testable import RunningTimer
@testable import CoreInterface

let testScheduler = DispatchQueue.testScheduler

extension SystemEnvironment where Environment == RunningTimerEnvironment {
    static let test = SystemEnvironment.mock(
        environment: RunningTimerEnvironment(soundClient: .mock, notificationClient: .mock, timerStep: .seconds(1)),
        mainQueue: { AnyScheduler(testScheduler) },
        uuid: { UUID(uuidString: "c06e5e63-d74f-4291-8673-35ce994754dc")! }
    )
}

class RunningTimerTests: XCTestCase {

    func testFlow() {
        let workout = QuickWorkout(
            id: UUID(),
            name: "Mock Workout",
            color: WorkoutColor(hue: 0, saturation: 0, brightness: 0),
            segments: [
                QuickWorkoutSegment(id: UUID(), sets: 1, work: 2, pause: 1),
                QuickWorkoutSegment(id: UUID(), sets: 1, work: 4, pause: 1)
            ])

        let state = RunningTimerState(workout: workout)
        let sections = state.timerSections

        let store = TestStore(
            initialState: state,
            reducer: runningTimerReducer,
            environment: .test
        )

        store.assert(
            .send(.onAppear) {
                $0.currentSection = sections.first
                $0.totalTimeLeft = 7
                $0.sectionTimeLeft = 2
                $0.segmentedProgressState.originalTotalCount = 2
                $0.segmentedProgressState.title = "Sections"
            },
            .send(.preCountdownAction(.finished)) {
                $0.precountdownState = nil
                $0.phase = .timer
            },
            .receive(.timerControlsUpdatedState(.start)) {
                $0.timerControlsState.timerState = .running
            },

            // 1. work section
            .do { testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.totalTimeLeft = 6
                $0.sectionTimeLeft = 1
            },
            .do { testScheduler.advance(by: 1) },
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
            .do { testScheduler.advance(by: 1) },
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
            .do {testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.totalTimeLeft = 3
                $0.sectionTimeLeft = 3
            },
            .do {testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.totalTimeLeft = 2
                $0.sectionTimeLeft = 2
            },
            .do {testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.totalTimeLeft = 1
                $0.sectionTimeLeft = 1
            },
            .do {testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.totalTimeLeft = 0
                $0.sectionTimeLeft = 0
                $0.finishedSections = 2
            },

            // finish
            .receive(.timerFinished) {
                $0.phase = .finished
                $0.timerControlsState.timerState = .finished
                $0.finishedWorkoutState = FinishedWorkoutState(workout: workout)
            }
        )
    }

    func testCloseTimer() {
        let workout = QuickWorkout(
            id: UUID(),
            name: "Mock Workout",
            color: WorkoutColor(hue: 0, saturation: 0, brightness: 0),
            segments: [
                QuickWorkoutSegment(id: UUID(), sets: 1, work: 2, pause: 1)
            ])

        let state = RunningTimerState(workout: workout)
        let sections = state.timerSections

        let store = TestStore(
            initialState: state,
            reducer: runningTimerReducer,
            environment: .test
        )

        store.assert(
            .send(.onAppear) {
                $0.currentSection = sections.first
                $0.totalTimeLeft = 2
                $0.sectionTimeLeft = 2
                $0.segmentedProgressState.originalTotalCount = 1
                $0.segmentedProgressState.title = "Sections"
            },
            .send(.preCountdownAction(.finished)) {
                $0.phase = .timer
                $0.precountdownState = nil
            },
            .receive(.timerControlsUpdatedState(.start)) {
                $0.timerControlsState.timerState = .running
            },

            // close
            .do {testScheduler.advance(by: 1) },
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
                $0.phase = .finished
                $0.alert = nil
                $0.timerControlsState.timerState = .finished
                $0.finishedWorkoutState = FinishedWorkoutState(workout: workout)
            }
        )
    }

    func testPlayPause() {
        let state = RunningTimerState(
            workout: QuickWorkout(
                id: UUID(),
                name: "Mock Workout",
                color: WorkoutColor(hue: 0, saturation: 0, brightness: 0),
                segments: [
                    QuickWorkoutSegment(id: UUID(), sets: 1, work: 2, pause: 1)
                ])
            )
        let sections = state.timerSections
        
        let store = TestStore(
            initialState: state,
            reducer: runningTimerReducer,
            environment: .test
        )

        store.assert(
            .send(.onAppear) {
                $0.currentSection = sections.first
                $0.totalTimeLeft = 2
                $0.sectionTimeLeft = 2
                $0.segmentedProgressState.originalTotalCount = 1
                $0.segmentedProgressState.title = "Sections"
            },
            .send(.preCountdownAction(.finished)) {
                $0.phase = .timer
                $0.precountdownState = nil
            },
            .receive(.timerControlsUpdatedState(.start)) {
                $0.timerControlsState.timerState = .running
            },

            // pause / play / pause
            .do {testScheduler.advance(by: 1) },
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

    func testBackground() {
        let state = RunningTimerState(
            workout: QuickWorkout(
                id: UUID(),
                name: "Mock Workout",
                color: WorkoutColor(hue: 0, saturation: 0, brightness: 0),
                segments: [
                    QuickWorkoutSegment(id: UUID(), sets: 1, work: 2, pause: 1)
                ])
            )
        let sections = state.timerSections

        let store = TestStore(
            initialState: state,
            reducer: runningTimerReducer,
            environment: .test
        )

        store.assert(
            .send(.onAppear) {
                $0.currentSection = sections.first
                $0.totalTimeLeft = 2
                $0.sectionTimeLeft = 2
                $0.segmentedProgressState.originalTotalCount = 1
                $0.segmentedProgressState.title = "Sections"
            },
            .send(.preCountdownAction(.finished)) {
                $0.phase = .timer
                $0.precountdownState = nil
            },
            .receive(.timerControlsUpdatedState(.start)) {
                $0.timerControlsState.timerState = .running
            },

            .do {testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.totalTimeLeft -= 1
                $0.sectionTimeLeft = 1
            },
            .send(.onBackground),
            .send(.onActive),
            .send(.timerControlsUpdatedState(.pause)) {
                $0.timerControlsState.timerState = .paused
            }
        )
    }
}
