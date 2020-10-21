import Foundation
import ComposableArchitecture
import CorePersistence

public enum CreateQuickWorkoutAction: Equatable {
    case circuitPickerUpdatedValues(AddTimerSegmentAction)
    case addTimerSegmentAction(id: UUID, action: AddTimerSegmentAction)
    case updateName(String)
    case onAppear
    case cancel
    case save
    case didSaveSuccessfully(Result<QuickWorkout, PersistenceError>)
    case updateColorComponents(ColorComponents)
}

public struct ColorComponents: Equatable {
    let hue: Double
    let brightness: Double
    let saturation: Double
}

public struct CreateQuickWorkoutState: Equatable {
    var addTimerSegments: IdentifiedArrayOf<AddTimerSegmentState> = []
    var name: String = ""

    var isFormIncomplete: Bool {
        name.isEmpty || addTimerSegments.filter(\.isAdded).isEmpty
    }

    var colorComponents = ColorComponents(hue: 0, brightness: 0, saturation: 0)
    var complementComponents: ColorComponents {
        ColorComponents(hue: colorComponents.hue, brightness: colorComponents.brightness - 0.1, saturation: colorComponents.saturation - 0.2)
    }

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
                state.addTimerSegments.insert(defaultSegmentState(with: environment.uuid()), at: 0)

            case .updateName(let name):
                state.name = name

            case .addTimerSegmentAction(let id, .updatedSegments(let action, let segments)):
                switch action {
                case .add:
                    state.addTimerSegments.insert(defaultSegmentState(with: environment.uuid()), at: 0)
                case .remove:
                    state.addTimerSegments.remove(id: id)
                }

            case .save:
                return environment
                    .repository
                    .createWorkout(QuickWorkout(state: state))
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(CreateQuickWorkoutAction.didSaveSuccessfully)

            case .updateColorComponents(let components):
                state.colorComponents = components

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
        self.init(id: UUID(), sets: Int(state.setsState.value) ?? 0, work: Int(state.workoutTimeState.value) ?? 0, pause: Int(state.breakTimeState.value) ?? 0)
    }
}

private extension QuickWorkout {
    init(state: CreateQuickWorkoutState) {
        self.init(id: UUID(), name: state.name, color: WorkoutColor(components: state.colorComponents), segments: state.addTimerSegments.map(QuickWorkoutSegment.init(state:)))
    }
}

private extension WorkoutColor {
    convenience init(components: ColorComponents) {
        self.init(hue: components.hue, saturation: components.saturation, brightness: components.brightness)
    }
}
