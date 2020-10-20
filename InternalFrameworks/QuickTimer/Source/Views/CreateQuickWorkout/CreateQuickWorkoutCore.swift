import Foundation
import ComposableArchitecture
import CorePersistence

public enum CreateQuickWorkoutAction: Equatable {
    case circuitPickerUpdatedValues(AddTimerSegmentAction)
    case addTimerSegmentAction(id: UUID, action: AddTimerSegmentAction)
    case updateName(String)
    case onAppear
}

public struct CreateQuickWorkoutState: Equatable {
    var addTimerSegments: IdentifiedArrayOf<AddTimerSegmentState> = []
    var name: String = ""

    public init() {}
}

public struct CreateQuickWorkoutEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var repository: QuickTimerRepository
    var uuid: () -> UUID

    public init(uuid: @escaping () -> UUID, mainQueue: AnySchedulerOf<DispatchQueue>, repository: QuickTimerRepository) {
        self.uuid = uuid
        self.mainQueue = mainQueue
        self.repository = repository
    }
}

public let createQuickWorkoutReducer =
    Reducer<CreateQuickWorkoutState, CreateQuickWorkoutAction, CreateQuickWorkoutEnvironment>.combine(
        addTimerSegmentReducer.forEach(
            state: \.addTimerSegments,
            action: /CreateQuickWorkoutAction.addTimerSegmentAction(id:action:),
            environment: { AddTimerSegmentEnvironment(uuid: $0.uuid) }
        ),
        Reducer { state, action, environment in
            switch action {
            case .onAppear:
                guard state.addTimerSegments.isEmpty else { break }
                state.addTimerSegments.append(defaultSegmentState(with: environment.uuid()))

            case .updateName(let name):
                state.name = name

            case .addTimerSegmentAction(let id, .updatedSegments(let action, let segments)):
                switch action {
                case .add:
                    state.addTimerSegments.append(defaultSegmentState(with: environment.uuid()))
                case .remove:
                    state.addTimerSegments.remove(id: id)
                }

            default: break
            }
            return .none
        }
    )

private func defaultSegmentState(with id: UUID) -> AddTimerSegmentState {
    AddTimerSegmentState(id: id, sets: 2, workoutTime: 60, breakTime: 20)
}
