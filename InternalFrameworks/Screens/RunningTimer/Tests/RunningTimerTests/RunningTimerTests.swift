import XCTest
import Foundation
import DomainEntities
@testable import CoreLogic
import ComposableArchitecture
@testable import RunningTimer
@testable import CoreInterface
import Combine

let testScheduler = DispatchQueue.testScheduler
let notificationScheduled = PassthroughSubject<Bool, Never>()
let soundPlayed = PassthroughSubject<Never, Never>()
let uuidGenerator = { UUID(uuidString: "c06e5e63-d74f-4291-8673-35ce994754dc")! }

extension LocalNotificationClient {
    static let test = LocalNotificationClient(
        requestAuthorisation: { .fireAndForget {} },
        scheduleLocalNotification: { _, _ in
            Effect(notificationScheduled)
        })
}

extension SystemEnvironment where Environment == RunningTimerEnvironment {
    static let test = SystemEnvironment.mock(
        environment: RunningTimerEnvironment(soundClient: .mock, notificationClient: .test, timerStep: .seconds(1)),
        mainQueue: { AnyScheduler(testScheduler) },
        uuid: uuidGenerator
    )
}

class RunningTimerTests: XCTestCase {

    func testFlow() {
        let workout = QuickWorkout(
            id: UUID(),
            name: "Mock Workout",
            color: WorkoutColor(hue: 0, saturation: 0, brightness: 0),
            segments: [
                QuickWorkoutSegment(id: uuidGenerator(), name: "Segment", sets: 1, work: 2, pause: 1),
                QuickWorkoutSegment(id: uuidGenerator(), name: "Segment", sets: 1, work: 4, pause: 1)
            ])

        let state = RunningTimerState(workout: workout, precountdownState: PreCountdownState())
        let sections = state.timerSections

        let store = TestStore(
            initialState: state,
            reducer: runningTimerReducer,
            environment: .test
        )

        store.assert(
            .send(.preCountdownAction(.finished)) {
                $0.precountdownState = nil
                $0.currentSection = sections.first
                $0.headerState.timeLeft = 7
                $0.sectionTimeLeft = 2
                $0.segmentedProgressState = SegmentedProgressState(segments: workout.segments)
            },
            .receive(.timerControlsUpdatedState(.start)) {
                $0.timerControlsState.timerState = .running
            },

            // 1. work section
            .do { testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.headerState.timeLeft = 6
                $0.sectionTimeLeft = 1
            },
            .do { testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.headerState.timeLeft = 5
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
                $0.headerState.timeLeft = 4
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
                $0.headerState.timeLeft = 3
                $0.sectionTimeLeft = 3
            },
            .do {testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.headerState.timeLeft = 2
                $0.sectionTimeLeft = 2
            },
            .do {testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.headerState.timeLeft = 1
                $0.sectionTimeLeft = 1
            },
            .do {testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.headerState.timeLeft = 0
                $0.sectionTimeLeft = 0
                $0.finishedSections = 2
            },

            // finish
            .receive(.timerFinished) {
                $0.timerControlsState.timerState = .finished
                $0.headerState.isFinished = true
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
                QuickWorkoutSegment(id: uuidGenerator(), name: "Segment", sets: 1, work: 2, pause: 1)
            ])

        let state = RunningTimerState(workout: workout, precountdownState: PreCountdownState())
        let sections = state.timerSections

        let store = TestStore(
            initialState: state,
            reducer: runningTimerReducer,
            environment: .test
        )

        store.assert(
            .send(.preCountdownAction(.finished)) {
                $0.precountdownState = nil
                $0.currentSection = sections.first
                $0.headerState.timeLeft = 2
                $0.sectionTimeLeft = 2
                $0.segmentedProgressState = SegmentedProgressState(segments: workout.segments)
            },
            .receive(.timerControlsUpdatedState(.start)) {
                $0.timerControlsState.timerState = .running
            },

            // close
            .do { testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.headerState.timeLeft = 1
                $0.sectionTimeLeft = 1
            },
            .send(.headerAction(.closeButtonTapped)) {
                $0.headerState.alert = .init(
                    title: TextState("Stop workout?"),
                    message: TextState("Are you sure you want to stop this workout?"),
                    primaryButton: .cancel(send: .alertCancelTapped),
                    secondaryButton: .default(TextState("Yes"), send: .alertConfirmTapped)
                )
            },
            .receive(.timerControlsUpdatedState(.pause)) {
                $0.timerControlsState.timerState = .paused
            },
            .send(.headerAction(.alertConfirmTapped)),

            // finish
            .receive(.timerFinished) {
                $0.headerState.alert = nil
                $0.headerState.isFinished = true
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
                    QuickWorkoutSegment(id: uuidGenerator(), name: "Segment", sets: 1, work: 2, pause: 1)
                ]),
            precountdownState: PreCountdownState()
            )
        let sections = state.timerSections
        
        let store = TestStore(
            initialState: state,
            reducer: runningTimerReducer,
            environment: .test
        )

        store.assert(
            .send(.preCountdownAction(.finished)) {
                $0.precountdownState = nil
                $0.currentSection = sections.first
                $0.headerState.timeLeft = 2
                $0.sectionTimeLeft = 2
                $0.segmentedProgressState = SegmentedProgressState(segments: state.workout.segments)
            },
            .receive(.timerControlsUpdatedState(.start)) {
                $0.timerControlsState.timerState = .running
            },

            // pause / play / pause
            .do {testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.headerState.timeLeft = 1
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
                    QuickWorkoutSegment(id: uuidGenerator(), name: "Segment", sets: 1, work: 2, pause: 1)
                ]),
            precountdownState: PreCountdownState()
            )
        let sections = state.timerSections

        let store = TestStore(
            initialState: state,
            reducer: runningTimerReducer,
            environment: .test
        )

        store.assert(
            .send(.preCountdownAction(.finished)) {
                $0.precountdownState = nil
                $0.currentSection = sections.first
                $0.headerState.timeLeft = 2
                $0.sectionTimeLeft = 2
                $0.segmentedProgressState = SegmentedProgressState(segments: state.workout.segments)
            },
            .receive(.timerControlsUpdatedState(.start)) {
                $0.timerControlsState.timerState = .running
            },

            .do {testScheduler.advance(by: 1) },
            .receive(.timerTicked) {
                $0.headerState.timeLeft -= 1
                $0.sectionTimeLeft = 1
            },
            .send(.onBackground),
            .do {
                notificationScheduled.send(true)
                notificationScheduled.send(completion: .finished)
            },
            .receive(.timerControlsUpdatedState(.pause)) {
                $0.timerControlsState.timerState = .paused
            }
        )
    }
}
