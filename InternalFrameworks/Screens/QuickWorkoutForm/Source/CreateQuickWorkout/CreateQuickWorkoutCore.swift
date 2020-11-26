import Foundation
import CoreLogic
import SwiftUI
import ComposableArchitecture
import CorePersistence
import DomainEntities
import CoreInterface

public enum CreateQuickWorkoutAction: Equatable {
    case circuitPickerUpdatedValues(AddTimerSegmentAction)
    case addTimerSegmentAction(id: UUID, action: AddTimerSegmentAction)
    case updateName(String)
    case cancel
    case save
    case onAppear
    case didSaveSuccessfully(Result<QuickWorkout, PersistenceError>)
    case selectColor(Color)
}

public struct CreateQuickWorkoutState: Equatable {
    var addTimerSegmentStates: IdentifiedArrayOf<AddTimerSegmentState> = []
    var workout: QuickWorkout?
    var name: String
    let preselectedTints: [TintColor] = TintColor.allTints
    var selectedTint: TintColor? = nil
    var selectedColor: Color = .black
    let isEditing: Bool

    var isFormIncomplete: Bool {
        name.isEmpty || addTimerSegmentStates.filter(\.isAdded).isEmpty
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
    static let preview = SystemEnvironment.live(environment: CreateQuickWorkoutEnvironment(repository: .mock))
    static let live = SystemEnvironment.live(environment: CreateQuickWorkoutEnvironment(repository: .live))
}

public let createQuickWorkoutReducer =
    Reducer<CreateQuickWorkoutState, CreateQuickWorkoutAction, SystemEnvironment<CreateQuickWorkoutEnvironment<TintColor>>>.combine(
        addTimerSegmentReducer.forEach(
            state: \.addTimerSegmentStates,
            action: /CreateQuickWorkoutAction.addTimerSegmentAction(id:action:),
            environment: { AddTimerSegmentEnvironment(uuid: $0.uuid) }
        ),
        Reducer { state, action, environment in
            switch action {

            case .onAppear:
                state.addTimerSegmentStates = IdentifiedArray(state.workout?.segments.map(AddTimerSegmentState.init(segment:)) ?? [])
                state.addTimerSegmentStates.append(defaultSegmentState(with: environment.uuid()))

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

            case .addTimerSegmentAction(let id, let action):
                switch action {
                case .addSegments:
                    state.addTimerSegmentStates.append(defaultSegmentState(with: environment.uuid()))

                case .removeSegments:
                    state.addTimerSegmentStates.remove(id: id)

                default:
                    break
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

private func defaultSegmentState(with id: UUID) -> AddTimerSegmentState {
    AddTimerSegmentState(id: id, sets: 2, workoutTime: 60, breakTime: 20)
}

private extension QuickWorkoutSegment {
    init(state: AddTimerSegmentState) {
        self.init(id: UUID(), sets: state.setsState.value, work: state.workoutTimeState.value, pause: state.breakTimeState.value)
    }
}

private extension QuickWorkout {
    init(state: CreateQuickWorkoutState, uuid: () -> UUID) {
        self.init(id: state.workout?.id ?? uuid(),
                  name: state.name,
                  color: WorkoutColor(components: state.colorComponents),
                  segments: state.addTimerSegmentStates.filter({ $0.isAdded }).map(QuickWorkoutSegment.init(state:))
        )
    }
}

private extension AddTimerSegmentState {
    init(segment: QuickWorkoutSegment) {
        self.init(id: segment.id, sets: segment.sets, workoutTime: segment.work, breakTime: segment.pause, isAdded: true)
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
