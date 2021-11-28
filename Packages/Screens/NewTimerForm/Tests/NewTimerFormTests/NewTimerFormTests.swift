import XCTest
import CoreLogic
import DomainEntities
import SwiftUI
import CoreInterface
import ComposableArchitecture
import CorePersistence
@testable import NewTimerForm

private let uuid = { UUID(uuidString: "c06e5e63-d74f-4291-8673-35ce994754dc")! }
private let randomTint = TintColor.allTints.first!
private let newWorkout = QuickWorkout(id: uuid(), name: "", color: .empty, segments: [])

class NewTimerFormTests: XCTestCase {


    func testFlow() {
        let store = TestStore(
            initialState: NewTimerFormState(),
            reducer: newTimerFormReducer,
            environment: .mock(
                environment: NewTimerFormEnvironment(repository: .test),
                mainQueue: { DispatchQueue.test.eraseToAnyScheduler() },
                uuid: uuid
            )
        )
        
        store.assert(
            .send(.binding(.set(\.$name, "My Workout"))) {
                $0.name = "My Workout"
            }
        )
    }
//    func testFlow() {
//        let store = TestStore(
//            initialState: CreateQuickWorkoutState(),
//            reducer: createQuickWorkoutReducer,
//            environment: .mock(
//                environment:
//                    CreateQuickWorkoutEnvironment(repository: .test),
//                mainQueue: { AnyScheduler(DispatchQueue.testScheduler) },
//                uuid: uuid
//            )
//        )
//
//        store.assert(
//            .send(.updateName("My workout")) {
//                $0.segmentStates = []
//                $0.selectedColor = Color(red: 0, green: 0, blue: 0, opacity: 1)
//                $0.selectedTint = nil
//                $0.name = "My workout"
//            },
//            .send(.newSegmentButtonTapped) {
//                $0.addSegmentState = AddTimerSegmentState(
//                    id: uuid(),
//                    name: "",
//                    sets: 2,
//                    workoutTime: 60,
//                    breakTime: 20
//                )
//            },
//            .send(.addSegmentAction(action: .add)) {
//                $0.segmentStates = [
//                    SegmentState(id: uuid(), name: "", sets: 2, rest: 20, work: 60)
//                ]
//                $0.addSegmentState = nil
//            },
//            .receive(.createInterval(.dismiss)),
//            .send(.editSegment(id: uuid())) {
//                $0.addSegmentState = AddTimerSegmentState(
//                    id: uuid(),
//                    name: "",
//                    sets: 2,
//                    workoutTime: 60,
//                    breakTime: 20,
//                    isEditing: true
//                )
//            },
//
//            .send(.addSegmentAction(action: .remove)) {
//                $0.segmentStates = []
//                $0.addSegmentState = nil
//            },
//            .receive(.createInterval(.dismiss))
//        )
//    }
}
