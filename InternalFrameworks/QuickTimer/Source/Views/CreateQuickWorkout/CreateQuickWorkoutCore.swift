import Foundation
import SwiftUI
import WorkoutCore
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
    case selectColor(Color)
}

public struct ColorComponents: Equatable {
    let hue: Double
    let brightness: Double
    let saturation: Double
}

public struct CreateQuickWorkoutState: Equatable {
    var addTimerSegmentStates: IdentifiedArrayOf<AddTimerSegmentState> = []
    var workoutSegments: [QuickWorkoutSegment] = []
    var name: String = ""
    let preselectedTints: [TintColor] = Color.tints
    var selectedTint: TintColor? = nil
    var colorComponents = ColorComponents(hue: 0, brightness: 0, saturation: 0)
    var selectedColor: Color

    var isFormIncomplete: Bool {
        name.isEmpty || addTimerSegmentStates.filter(\.isAdded).isEmpty
    }

    public init() {
        selectedColor = Color.tints.first?.color ?? .appSuccess
        selectedTint = Color.tints.first
    }
}

public struct CreateQuickWorkoutEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var repository: QuickWorkoutsRepository
    var uuid: () -> UUID

    public init(uuid: @escaping () -> UUID, mainQueue: AnySchedulerOf<DispatchQueue>, repository: QuickWorkoutsRepository) {
        self.uuid = uuid
        self.mainQueue = mainQueue
        self.repository = repository
    }
}

public let createQuickWorkoutReducer =
    Reducer<CreateQuickWorkoutState, CreateQuickWorkoutAction, CreateQuickWorkoutEnvironment>.combine(
        addTimerSegmentReducer.forEach(
            state: \.addTimerSegmentStates,
            action: /CreateQuickWorkoutAction.addTimerSegmentAction(id:action:),
            environment: { AddTimerSegmentEnvironment(uuid: $0.uuid) }
        ),
        Reducer { state, action, environment in
            switch action {
            case .onAppear:
                guard state.addTimerSegmentStates.isEmpty else { break }
                state.addTimerSegmentStates.insert(defaultSegmentState(with: environment.uuid()), at: 0)

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
                    .createWorkout(QuickWorkout(state: state))
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(CreateQuickWorkoutAction.didSaveSuccessfully)

            case .selectColor(let color):
                let components = UIColor(color).components()
                state.selectedColor = color
                state.selectedTint = Color.tints[color]
                state.colorComponents = ColorComponents(hue: components.h, brightness: components.b, saturation: components.s)

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
        self.init(id: UUID(),
                  name: state.name,
                  color: WorkoutColor(components: state.colorComponents),
                  segments: state.addTimerSegmentStates.filter({ $0.isAdded }).map(QuickWorkoutSegment.init(state:))
        )
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

//private extension CreateQuickWorkoutState {
//    var color: Color {
//        Color(hue: colorComponents.hue, saturation: colorComponents.saturation, brightness: colorComponents.brightness)
//    }
//}
