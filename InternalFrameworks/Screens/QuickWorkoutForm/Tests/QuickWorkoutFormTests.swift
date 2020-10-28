import XCTest
import DomainEntities
import SwiftUI
import CoreInterface
import ComposableArchitecture
import CorePersistence
@testable import QuickWorkoutForm

private let uuid = { UUID(uuidString: "c06e5e63-d74f-4291-8673-35ce994754dc")! }
private let randomTintGenerator: ([TintColor]) -> TintColor? = { _ in Color.tints.first }
private let randomTint = randomTintGenerator([])!
private let newWorkout = QuickWorkout(id: uuid(), name: "", color: .empty, segments: [])

class QuickWorkoutFormTests: XCTestCase {


    func testFlow() {
        let store = TestStore(
            initialState: CreateQuickWorkoutState(),
            reducer: createQuickWorkoutReducer,
            environment: CreateQuickWorkoutEnvironment(
                mainQueue: AnyScheduler(DispatchQueue.testScheduler),
                repository: .mock,
                uuid: uuid,
                randomElementGenerator: randomTintGenerator
            )
        )

        store.assert(
            .send(.onAppear) {
                $0.addTimerSegmentStates = [AddTimerSegmentState(id: uuid(), sets: 2, workoutTime: 60, breakTime: 20)]
                $0.selectedColor = randomTint.color
                $0.selectedTint = randomTint
            },
            .send(.updateName("My workout")) {
                $0.name = "My workout"
            },
            .send(.addTimerSegmentAction(id: uuid(), action: .addSegments)) {
                $0.addTimerSegmentStates = [
                    AddTimerSegmentState(id: uuid(), sets: 2, workoutTime: 60, breakTime: 20),
                    AddTimerSegmentState(id: uuid(), sets: 2, workoutTime: 60, breakTime: 20)
                ]
            },
            .send(.addTimerSegmentAction(id: uuid(), action: .removeSegments)) {
                $0.addTimerSegmentStates = []
            },
        )
    }
}
