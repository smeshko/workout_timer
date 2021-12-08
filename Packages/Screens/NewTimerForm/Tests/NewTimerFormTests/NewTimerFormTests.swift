import XCTest
import CoreLogic
import DomainEntities
import SwiftUI
import CoreInterface
import ComposableArchitecture
import CorePersistence
@testable import NewTimerForm

private var uuidIndex = 0
private let uuid: () -> UUID = {
    uuidIndex += 1
    return UUID(uuidString: "00000000-0000-0000-0000-00000000000\(uuidIndex)")!
}
private let scheduler = DispatchQueue.test

private let segmentState1 = SegmentState(
    id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, name: "Exercise 1",
    sets: 1, rest: 30, work: 60, color: TintColor.default.color
)

private let segmentState2 = SegmentState(
    id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!, name: "Exercise 2",
    sets: 1, rest: 30, work: 60, color: TintColor.default.color
)

class NewTimerFormTests: XCTestCase {

    func testCreateFlow() {
        let store = TestStore(
            initialState: NewTimerFormState(),
            reducer: newTimerFormReducer,
            environment: .mock(
                environment: NewTimerFormEnvironment(repository: .test),
                mainQueue: { scheduler.eraseToAnyScheduler() },
                uuid: uuid
            )
        )

        store.send(.binding(.set(\.$name, "My Workout"))) {
            $0.name = "My Workout"
        }
        store.send(.addEmptySegment) {
            $0.segmentStates = [segmentState1]
        }
        store.send(.addEmptySegment) {
            $0.segmentStates = [segmentState1, segmentState2]
        }
        store.send(.moveSegment([0], 2)) {
            $0.segmentStates = [segmentState2, segmentState1]
        }
        store.send(.deleteSegments([0])) {
            $0.segmentStates = [segmentState1]
        }
        store.send(.binding(.set(\.$countdown, 0))) {
            $0.countdown = 1
        }
        store.send(.binding(.set(\.$countdown, 2))) {
            $0.countdown = 2
        }
    }

    func testEditFlow() {
        let store = TestStore(
            initialState: NewTimerFormState(
                workout: QuickWorkout(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                    name: "My Workout", color: WorkoutColor(color: TintColor.default.color), countdown: 3,
                    segments: [
                        QuickWorkoutSegment(
                            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                            name: "Segment", sets: 3, work: 45, pause: 20
                        )
                    ]
                )
            ),
            reducer: newTimerFormReducer,
            environment: .mock(
                environment: NewTimerFormEnvironment(repository: .test),
                mainQueue: { scheduler.eraseToAnyScheduler() },
                uuid: uuid
            )
        )

        store.send(.binding(.set(\.$name, "Edited Workout"))) {
            $0.name = "Edited Workout"
        }
        uuidIndex = 1
        store.send(.addEmptySegment) {
            $0.segmentStates = [
                SegmentState(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                    name: "Segment", sets: 3, rest: 20, work: 45, color: TintColor.default.color
                ),
                segmentState2
            ]
        }
    }
}
