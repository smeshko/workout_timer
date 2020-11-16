import Foundation
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
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let repository: QuickWorkoutsRepository
    let uuid: () -> UUID
    let randomElementGenerator: ([T]) -> T?

    public init(mainQueue: AnySchedulerOf<DispatchQueue>,
                repository: QuickWorkoutsRepository,
                uuid: @escaping () -> UUID = UUID.init,
                randomElementGenerator: @escaping (_ elements: [T]) -> T? = { $0.randomElement() }) {
        self.mainQueue = mainQueue
        self.repository = repository
        self.uuid = uuid
        self.randomElementGenerator = randomElementGenerator
    }
}

public let createQuickWorkoutReducer =
    Reducer<CreateQuickWorkoutState, CreateQuickWorkoutAction, CreateQuickWorkoutEnvironment<TintColor>>.combine(
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

private extension CreateQuickWorkoutEnvironment {
    func createOrUpdate(_ workout: QuickWorkout, isEditing: Bool) -> Effect<CreateQuickWorkoutAction, Never> {
        if isEditing {
            return repository
                .updateWorkout(workout)
                .receive(on: mainQueue)
                .catchToEffect()
                .map(CreateQuickWorkoutAction.didSaveSuccessfully)
        } else {
            return repository
                .createWorkout(workout)
                .receive(on: mainQueue)
                .catchToEffect()
                .map(CreateQuickWorkoutAction.didSaveSuccessfully)
        }
    }
}
