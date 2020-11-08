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

public struct ColorComponents: Equatable {
    let hue: Double
    let brightness: Double
    let saturation: Double
}

public struct CreateQuickWorkoutState: Equatable {
    var addTimerSegmentStates: IdentifiedArrayOf<AddTimerSegmentState> = []
    var workoutSegments: [QuickWorkoutSegment]
    var name: String
    let preselectedTints: [TintColor] = Color.tints
    var selectedTint: TintColor? = nil
    var selectedColor: Color = .black

    var isFormIncomplete: Bool {
        name.isEmpty || addTimerSegmentStates.filter(\.isAdded).isEmpty
    }

    var colorComponents: ColorComponents {
        let components = UIColor(selectedColor).components()
        return ColorComponents(hue: components.h, brightness: components.b, saturation: components.s)
    }

    public init(workoutSegments: [QuickWorkoutSegment] = [], name: String = "") {
        self.name = name
        self.workoutSegments = workoutSegments
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
                state.addTimerSegmentStates = IdentifiedArray(state.workoutSegments.map(AddTimerSegmentState.init(segment:)))
                state.addTimerSegmentStates.insert(defaultSegmentState(with: environment.uuid()), at: 0)

                let randomTint = environment.randomElementGenerator(Color.tints)
                state.selectedColor = randomTint?.color ?? .appSuccess
                state.selectedTint = randomTint

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
                return environment
                    .repository
                    .createWorkout(QuickWorkout(state: state, uuid: environment.uuid))
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(CreateQuickWorkoutAction.didSaveSuccessfully)

            case .selectColor(let color):
                state.selectedColor = color
                state.selectedTint = Color.tints[color]

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
        self.init(id: uuid(),
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

private extension WorkoutColor {
    convenience init(components: ColorComponents) {
        self.init(hue: components.hue, saturation: components.saturation, brightness: components.brightness)
    }
}

private extension Array where Element == TintColor {
    subscript(_ color: Color) -> TintColor? {
        first { $0.color == color }
    }
}

private extension UIColor {
    func components() -> (h: Double, s: Double, b: Double) {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getHue(&h, saturation: &s, brightness: &b, alpha: &a)

        return (Double(h), Double(s), Double(b))
    }
}
