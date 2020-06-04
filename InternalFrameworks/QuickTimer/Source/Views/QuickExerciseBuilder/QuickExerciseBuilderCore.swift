import ComposableArchitecture
import WorkoutCore
import Foundation

public enum QuickExerciseBuilderAction: Equatable {
    case changeSetsCount(PickerAction)
    case changeBreakTime(PickerAction)
    case changeWorkoutTime(PickerAction)
    
    case updatedSegments([Segment])
    case setNavigation
}

public struct QuickExerciseBuilderState: Equatable {
    
    var setsState = PickerState()
    var workoutTimeState = PickerState()
    var breakTimeState = PickerState()
    var segments: [Segment] = []
    
    fileprivate var sets: Int { setsState.value }
    fileprivate var workoutTime: Int { workoutTimeState.value }
    fileprivate var breakTime: Int { breakTimeState.value }
    
    public init() {}
    public init(sets: Int, workoutTime: Int, breakTime: Int) {
        setsState = PickerState(value: sets)
        workoutTimeState = PickerState(value: workoutTime)
        breakTimeState = PickerState(value: breakTime)
    }
}

public struct QuickExerciseBuilderEnvironment {
    var uuid: () -> UUID
    
    init(uuid: @escaping () -> UUID) {
        self.uuid = uuid
    }
}

public let quickExerciseBuilderReducer =
    Reducer<QuickExerciseBuilderState, QuickExerciseBuilderAction, QuickExerciseBuilderEnvironment>.combine(
        Reducer { state, action, environment in
            
            switch action {
            case .setNavigation:
                state.createSegments(uuid: environment.uuid)
                return Effect(value: .updatedSegments(state.segments))
                
            case .changeSetsCount(let action):
                switch action {
                case .valueUpdated(let value):
                    state.setsState.value = value
                    state.createSegments(uuid: environment.uuid)
                    return Effect(value: .updatedSegments(state.segments))
                    
                case .togglePickerVisibility:
                    state.breakTimeState.hidePickerIfNeeded()
                    state.workoutTimeState.hidePickerIfNeeded()
                }
                
            case .changeBreakTime(let action):
                switch action {
                case .valueUpdated(let value):
                    state.breakTimeState.value = value
                    state.createSegments(uuid: environment.uuid)
                    return Effect(value: .updatedSegments(state.segments))
                    
                case .togglePickerVisibility:
                    state.setsState.hidePickerIfNeeded()
                    state.workoutTimeState.hidePickerIfNeeded()
                }
                
            case .changeWorkoutTime(let action):
                switch action {
                case .valueUpdated(let value):
                    state.workoutTimeState.value = value
                    state.createSegments(uuid: environment.uuid)
                    return Effect(value: .updatedSegments(state.segments))
                    
                case .togglePickerVisibility:
                    state.setsState.hidePickerIfNeeded()
                    state.breakTimeState.hidePickerIfNeeded()
                }
                
            case .updatedSegments: break
            }
            
            return .none
        },
        pickerReducer.pullback(
            state: \.setsState,
            action: /QuickExerciseBuilderAction.changeSetsCount,
            environment: { _ in PickerEnvironment() }
        ),
        pickerReducer.pullback(
            state: \.workoutTimeState,
            action: /QuickExerciseBuilderAction.changeWorkoutTime,
            environment: { _ in PickerEnvironment() }
        ),
        pickerReducer.pullback(
            state: \.breakTimeState,
            action: /QuickExerciseBuilderAction.changeBreakTime,
            environment: { _ in PickerEnvironment() }
        )
)

private extension QuickExerciseBuilderState {
    
    mutating func createSegments(uuid: () -> UUID) {
        segments = []
        
        (0 ..< sets).enumerated().forEach { index, _ in
            segments.append(Segment(id: uuid(), duration: workoutTime, category: .workout))
            if index != sets - 1 {
                segments.append(Segment(id: uuid(), duration: breakTime, category: .pause))
            }
        }
    }
    
}

private extension PickerState {
    mutating func hidePickerIfNeeded() {
        if isShowingPicker { isShowingPicker = false }
    }
}
