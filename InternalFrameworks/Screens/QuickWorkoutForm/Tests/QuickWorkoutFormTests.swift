import XCTest
import CoreLogic
import DomainEntities
import SwiftUI
import CoreInterface
import ComposableArchitecture
import CorePersistence
@testable import QuickWorkoutForm

private let uuid = { UUID(uuidString: "c06e5e63-d74f-4291-8673-35ce994754dc")! }
private let randomTint = TintColor.allTints.first!
private let newWorkout = QuickWorkout(id: uuid(), name: "", color: .empty, segments: [])

class QuickWorkoutFormTests: XCTestCase {


    func testFlow() {
        let store = TestStore(
            initialState: CreateQuickWorkoutState(),
            reducer: createQuickWorkoutReducer,
            environment: .mock(
                environment:
                    CreateQuickWorkoutEnvironment(repository: .mock),
                mainQueue: { AnyScheduler(DispatchQueue.testScheduler) },
                uuid: uuid
            )
        )

        store.assert(
            .send(.updateName("My workout")) {
                $0.segmentStates = []
                $0.selectedColor = randomTint.color
                $0.selectedTint = randomTint
                $0.name = "My workout"
            },
            .send(.newSegmentButtonTapped) {
                $0.addSegmentState = AddTimerSegmentState(
                    id: uuid(),
                    name: "",
                    sets: 2,
                    workoutTime: 60,
                    breakTime: 20
                )
            },
            .send(.addSegmentAction(action: .add)) {
                $0.segmentStates = [
                    SegmentState(id: uuid(), name: "", sets: 2, rest: 20, work: 60)
                ]
                $0.addSegmentState = nil
            },
            .send(.editSegment(id: uuid())) {
                $0.addSegmentState = AddTimerSegmentState(
                    id: uuid(),
                    name: "",
                    sets: 2,
                    workoutTime: 60,
                    breakTime: 20,
                    isEditing: true
                )
            },
            .send(.addSegmentAction(action: .remove)) {
                $0.segmentStates = []
                $0.addSegmentState = nil
            }
        )
    }
}
