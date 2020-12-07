import Foundation
import CoreLogic
import SwiftUI
import ComposableArchitecture
import CorePersistence
import DomainEntities
import CoreInterface

public enum CreateQuickWorkoutAction: Equatable {
    case circuitPickerUpdatedValues(AddTimerSegmentAction)
    case addSegmentAction(action: AddTimerSegmentAction)
    case segmentAction(id: UUID, action: SegmentAction)

    case updateName(String)
    case editSegment(id: UUID)
    case newSegmentButtonTapped
    case cancel
    case save
    case onAppear
    case didSaveSuccessfully(Result<QuickWorkout, PersistenceError>)
    case selectColor(Color)
}

public struct CreateQuickWorkoutState: Equatable {

    var segmentStates: IdentifiedArrayOf<SegmentState> = []
    var addSegmentState: AddTimerSegmentState?
    var workout: QuickWorkout?
    var name: String
    let preselectedTints: [TintColor] = TintColor.allTints
    var selectedTint: TintColor? = nil
    var selectedColor: Color = .black
    let isEditing: Bool

    var isFormIncomplete: Bool {
        name.isEmpty || segmentStates.isEmpty
    }

    var colorComponents: ColorComponents {
        ColorComponents(color: selectedColor)
    }

    public init(workout: QuickWorkout? = nil) {
        self.name = workout?.name ?? ""
        self.workout = workout
        self.isEditing = workout != nil
    }
}

public struct CreateQuickWorkoutEnvironment<T> {
    let repository: QuickWorkoutsRepository
    let randomElementGenerator: ([T]) -> T?

    public init(repository: QuickWorkoutsRepository,
                randomElementGenerator: @escaping (_ elements: [T]) -> T? = { $0.randomElement() }) {
        self.repository = repository
        self.randomElementGenerator = randomElementGenerator
    }
}

public extension SystemEnvironment where Environment == CreateQuickWorkoutEnvironment<TintColor> {
    static let preview = SystemEnvironment.mock(environment: CreateQuickWorkoutEnvironment(repository: .mock))
    static let live = SystemEnvironment.live(environment: CreateQuickWorkoutEnvironment(repository: .live))
}

public let createQuickWorkoutReducer =
    Reducer<CreateQuickWorkoutState, CreateQuickWorkoutAction, SystemEnvironment<CreateQuickWorkoutEnvironment<TintColor>>>.combine(
        addTimerSegmentReducer.optional().pullback(
            state: \.addSegmentState,
            action: /CreateQuickWorkoutAction.addSegmentAction,
            environment: { AddTimerSegmentEnvironment(uuid: $0.uuid) }
        ),
        segmentReducer.forEach(
            state: \.segmentStates,
            action: /CreateQuickWorkoutAction.segmentAction,
            environment: { _ in SegmentEnvironment() }
        ),
        Reducer { state, action, environment in
            switch action {

            case .onAppear:
                state.segmentStates = IdentifiedArray(state.workout?.segments.map(SegmentState.init(segment:)) ?? [])

                if state.isEditing {
                    state.selectedColor = state.workout?.color.color ?? .appSuccess
                    state.selectedTint = TintColor.allTints[state.selectedColor]
                } else {
                    let randomTint = environment.randomElementGenerator(TintColor.allTints)
                    state.selectedColor = randomTint?.color ?? .appSuccess
                    state.selectedTint = randomTint
                }

            case .updateName(let name):
                state.name = name

            case .addSegmentAction(let action):
                switch action {
                case .add:
                    guard let addSegmentState = state.addSegmentState else { return .none }
                    state.segmentStates.append(SegmentState(addSegmentState: addSegmentState))
                    state.addSegmentState = nil

                case .remove:
                    guard let id = state.addSegmentState?.id else { return .none }
                    if state.segmentStates[id: id] != nil {
                        state.segmentStates.remove(id: id)
                    }
                    state.addSegmentState = nil

                case .cancel:
                    state.addSegmentState = nil

                case .done:
                    guard let id = state.addSegmentState?.id,
                          let addSegmentState = state.addSegmentState else { return .none }
                    if let index = state.segmentStates.firstIndex(where: { $0.id == id }) {
                        state.segmentStates.remove(at: index)
                        state.segmentStates.insert(SegmentState(addSegmentState: addSegmentState), at: index)
                    }
                    state.addSegmentState = nil

                default:
                    break
                }

            case .newSegmentButtonTapped:
                state.addSegmentState = AddTimerSegmentState(id: environment.uuid(), name: "", sets: 2, workoutTime: 60, breakTime: 20)

            case .editSegment(let id):
                if let segmentState = state.segmentStates[id: id] {
                    state.addSegmentState = AddTimerSegmentState(state: segmentState)
                }
                
            case .save:
                return environment.createOrUpdate(
                    QuickWorkout(state: state, uuid: environment.uuid),
                    isEditing: state.isEditing
                )

            case .selectColor(let color):
                state.selectedColor = color
                state.selectedTint = TintColor.allTints[color]

            default: break
            }
            return .none
        }
    )

private extension QuickWorkoutSegment {
    init(index: Int, state: SegmentState) {
        self.init(id: state.id,
                  name: state.name.isEmpty ? "Interval \(index + 1)" : state.name,
                  sets: state.sets, work: state.work, pause: state.rest)
    }
}

private extension QuickWorkout {
    init(state: CreateQuickWorkoutState, uuid: () -> UUID) {
        self.init(id: state.workout?.id ?? uuid(),
                  name: state.name,
                  color: WorkoutColor(components: state.colorComponents),
                  segments: state.segmentStates.enumerated().map(QuickWorkoutSegment.init(index:state:))
        )
    }
}

private extension SegmentState {
    init(segment: QuickWorkoutSegment) {
        self.init(id: segment.id, name: segment.name, sets: segment.sets, rest: segment.pause, work: segment.work)
    }

    init(addSegmentState: AddTimerSegmentState) {
        self.init(id: addSegmentState.id,
                  name: addSegmentState.name,
                  sets: addSegmentState.setsState.value,
                  rest: addSegmentState.breakTimeState.value,
                  work: addSegmentState.workoutTimeState.value)
    }
}

private extension AddTimerSegmentState {
    init(segment: QuickWorkoutSegment) {
        self.init(id: segment.id, name: segment.name, sets: segment.sets, workoutTime: segment.work, breakTime: segment.pause)
    }

    init(state: SegmentState) {
        self.init(id: state.id, name: state.name, sets: state.sets, workoutTime: state.work, breakTime: state.rest, isEditing: true)
    }
}

private extension SystemEnvironment where Environment == CreateQuickWorkoutEnvironment<TintColor> {
    func createOrUpdate(_ workout: QuickWorkout, isEditing: Bool) -> Effect<CreateQuickWorkoutAction, Never> {
        if isEditing {
            return environment.repository
                .updateWorkout(workout)
                .receive(on: mainQueue())
                .catchToEffect()
                .map(CreateQuickWorkoutAction.didSaveSuccessfully)
        } else {
            return environment.repository
                .createWorkout(workout)
                .receive(on: mainQueue())
                .catchToEffect()
                .map(CreateQuickWorkoutAction.didSaveSuccessfully)
        }
    }
}
