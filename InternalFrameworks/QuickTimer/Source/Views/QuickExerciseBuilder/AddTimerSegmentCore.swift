import ComposableArchitecture
import WorkoutCore
import Foundation
import CorePersistence

public enum AddTimerSegmentAction: Equatable {
    public enum UpdateSegmentsAction: Equatable {
        case add
        case remove
    }

    case changeSetsCount(PickerAction)
    case changeBreakTime(PickerAction)
    case changeWorkoutTime(PickerAction)
    
    case updatedSegments(UpdateSegmentsAction, [QuickTimerSet])
    case addSegments
    case removeSegments
}

public struct AddTimerSegmentState: Equatable, Identifiable {

    public var id: UUID
    var setsState = PickerState()
    var workoutTimeState = PickerState()
    var breakTimeState = PickerState()
    var isAdded: Bool = false
    var segments: [QuickTimerSet] = []
    
    fileprivate var sets: Int { Int(setsState.value) ?? 0 }
    fileprivate var workoutTime: Int { Int(workoutTimeState.value) ?? 0 }
    fileprivate var breakTime: Int { Int(breakTimeState.value) ?? 0 }
    
    public init(id: UUID) {
        self.id = id
    }
    public init(id: UUID, sets: Int, workoutTime: Int, breakTime: Int, isAdded: Bool = false) {
        self.id = id
        setsState = PickerState(value: sets)
        workoutTimeState = PickerState(value: workoutTime)
        breakTimeState = PickerState(value: breakTime)
        self.isAdded = isAdded
    }
}

public struct AddTimerSegmentEnvironment {
    var uuid: () -> UUID
    
    init(uuid: @escaping () -> UUID) {
        self.uuid = uuid
    }
}

public let addTimerSegmentReducer =
    Reducer<AddTimerSegmentState, AddTimerSegmentAction, AddTimerSegmentEnvironment>.combine(
        Reducer { state, action, environment in
            
            switch action {
            case .changeSetsCount(.valueUpdated(let value)):
                state.setsState.value = value

            case .changeBreakTime(.valueUpdated(let value)):
                state.breakTimeState.value = value

            case .changeWorkoutTime(.valueUpdated(let value)):
                state.workoutTimeState.value = value

            case .updatedSegments: break

            case .removeSegments:
                state.isAdded = false
                let copiedSegments = state.segments
                state.segments = []
                return Effect(value: .updatedSegments(.remove, copiedSegments))

            case .addSegments:
                state.isAdded = true
                state.createSegments(uuid: environment.uuid)
                return Effect(value: .updatedSegments(.add, state.segments))
            }
            
            return .none
        },
        pickerReducer.pullback(
            state: \.setsState,
            action: /AddTimerSegmentAction.changeSetsCount,
            environment: { _ in PickerEnvironment() }
        ),
        pickerReducer.pullback(
            state: \.workoutTimeState,
            action: /AddTimerSegmentAction.changeWorkoutTime,
            environment: { _ in PickerEnvironment() }
        ),
        pickerReducer.pullback(
            state: \.breakTimeState,
            action: /AddTimerSegmentAction.changeBreakTime,
            environment: { _ in PickerEnvironment() }
        )
)

private extension AddTimerSegmentState {
    
    mutating func createSegments(uuid: () -> UUID) {
        segments = (0 ..< sets).enumerated().map { index, _ in
            QuickTimerSet(id: uuid,
                          work: TimeInterval(workoutTime),
                          pause: TimeInterval(breakTime))
        }
    }
    
}

extension Int {
    func isLastIndex(inCount count: Int) -> Bool {
        self == count - 1
    }
}
