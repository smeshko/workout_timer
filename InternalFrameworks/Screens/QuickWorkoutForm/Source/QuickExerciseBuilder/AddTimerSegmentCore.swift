import ComposableArchitecture
import CoreLogic
import Foundation
import CorePersistence

public enum AddTimerSegmentAction: Equatable {
    case changeSetsCount(PickerAction)
    case changeBreakTime(PickerAction)
    case changeWorkoutTime(PickerAction)

    case addSegments
    case removeSegments
}

struct AddTimerSegmentState: Equatable, Identifiable {

    public var id: UUID
    var setsState = PickerState()
    var workoutTimeState = PickerState()
    var breakTimeState = PickerState()
    var isAdded: Bool = false
    
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

struct AddTimerSegmentEnvironment {
    var uuid: () -> UUID
    
    init(uuid: @escaping () -> UUID) {
        self.uuid = uuid
    }
}

let addTimerSegmentReducer =
    Reducer<AddTimerSegmentState, AddTimerSegmentAction, AddTimerSegmentEnvironment>.combine(
        Reducer { state, action, environment in
            
            switch action {
            case .changeSetsCount(.valueUpdated(let value)):
                state.setsState.value = value

            case .changeBreakTime(.valueUpdated(let value)):
                state.breakTimeState.value = value

            case .changeWorkoutTime(.valueUpdated(let value)):
                state.workoutTimeState.value = value

            case .removeSegments:
                state.isAdded = false

            case .addSegments:
                state.isAdded = true
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
