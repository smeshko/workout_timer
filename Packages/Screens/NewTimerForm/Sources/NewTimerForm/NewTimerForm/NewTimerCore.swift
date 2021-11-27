import DomainEntities
import ComposableArchitecture
import CoreInterface
import CorePersistence
import CoreLogic
import SwiftUI

public enum NewTimerFormAction: BindableAction {
    case binding(BindingAction<NewTimerFormState>)
    case addEmptySegment
    case moveSegment(IndexSet, Int)
    case deleteSegments(IndexSet)
    case segmentAction(id: UUID, action: SegmentAction)
    case save, cancel
    case didSaveSuccessfully(Result<QuickWorkout, PersistenceError>)
}

public struct NewTimerFormState: Equatable {
    @BindableState var name: String
    @BindableState var selectedColor: TintColor

    public var workout: QuickWorkout?
    var segmentStates: IdentifiedArrayOf<SegmentState> = []

    let preselectedTints: [TintColor] = TintColor.allTints
    let isEditing: Bool

    var isFormIncomplete: Bool {
        name.isEmpty || segmentStates.isEmpty
    }

    var colorComponents: ColorComponents {
        ColorComponents(color: selectedColor.color)
    }

    public init(workout: QuickWorkout? = nil) {
        self.name = workout?.name ?? ""
        self.workout = workout
        self.isEditing = workout != nil
        self.selectedColor = TintColor(color: workout?.color.color) ?? .default
        self.segmentStates = IdentifiedArray(
            uniqueElements: (workout?.segments.map { SegmentState(segment: $0, color: selectedColor.color) } ?? [])
        )
    }

}

public struct NewTimerFormEnvironment {
    let repository: QuickWorkoutsRepository

    public init(repository: QuickWorkoutsRepository) {
        self.repository = repository
    }
}

public extension SystemEnvironment where Environment == NewTimerFormEnvironment {
    static let preview = SystemEnvironment.mock(environment: NewTimerFormEnvironment(repository: .mock))
    static let live = SystemEnvironment.live(environment: NewTimerFormEnvironment(repository: .live))
}

public let newTimerFormReducer =
Reducer<NewTimerFormState, NewTimerFormAction, SystemEnvironment<NewTimerFormEnvironment>>.combine(
    Reducer { state, action, environment in
        switch action {

        case .addEmptySegment:
            state.segmentStates.append(
                SegmentState(
                    id: environment.uuid(), name: "Exercise " + "\(state.segmentStates.count + 1)",
                    sets: 1, rest: 30, work: 60, color: state.selectedColor.color
                )
            )

        case .moveSegment(let offsets, let newOffset):
            state.segmentStates.move(fromOffsets: offsets, toOffset: newOffset)

        case .deleteSegments(let indices):
            state.segmentStates.remove(atOffsets: indices)

        case .save:
            return environment.createOrUpdate(
                QuickWorkout(state: state, uuid: environment.uuid),
                isEditing: state.isEditing
            )

        case .cancel, .didSaveSuccessfully:
            break

        case .segmentAction, .binding:
            break
        }

        return .none
    },
    segmentReducer.forEach(
        state: \.segmentStates,
        action: /NewTimerFormAction.segmentAction,
        environment: { _ in SegmentEnvironment() }
    )

)
    .binding()

private extension SegmentState {
    init(segment: QuickWorkoutSegment, color: Color) {
        self.init(id: segment.id, name: segment.name, sets: segment.sets, rest: segment.pause, work: segment.work, color: color)
    }
}

private extension QuickWorkout {
    init(state: NewTimerFormState, uuid: () -> UUID) {
        self.init(
            id: state.workout?.id ?? uuid(),
            name: state.name,
            color: WorkoutColor(components: state.colorComponents),
            segments: state.segmentStates.enumerated().map(QuickWorkoutSegment.init(index:state:))
        )
    }
}

private extension QuickWorkoutSegment {
    init(index: Int, state: SegmentState) {
        self.init(
            id: state.id,
            name: state.name.isEmpty ? "Exercise \(index + 1)" : state.name,
            sets: state.sets, work: state.work, pause: state.rest
        )
    }
}

private extension SystemEnvironment where Environment == NewTimerFormEnvironment {
    func createOrUpdate(_ workout: QuickWorkout, isEditing: Bool) -> Effect<NewTimerFormAction, Never> {
        if isEditing {
            return environment.repository
                .updateWorkout(workout)
                .receive(on: mainQueue())
                .catchToEffect()
                .map(NewTimerFormAction.didSaveSuccessfully)
        } else {
            return environment.repository
                .createWorkout(workout)
                .receive(on: mainQueue())
                .catchToEffect()
                .map(NewTimerFormAction.didSaveSuccessfully)
        }
    }
}
