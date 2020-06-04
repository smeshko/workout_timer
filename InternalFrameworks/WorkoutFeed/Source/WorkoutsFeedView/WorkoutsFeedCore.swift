import Foundation
import WorkoutCore
import ComposableArchitecture

public enum WorkoutsFeedError: Error, Equatable {
    case failedLoadingWorkouts
}

public enum WorkoutsFeedAction: Equatable {
    case workoutCategoryChanged(WorkoutCategory)
//    case workoutCategoryChanged(String)
    case categoriesLoaded(Result<[WorkoutCategory], WorkoutsFeedError>)
    case beginNavigation
    
    case workoutsListAction(WorkoutsListAction)
//    case jumpropeWorkoutsAction(WorkoutsListAction)
}

public struct WorkoutsFeedState: Equatable {
    
//    public enum WorkoutType: String, CaseIterable, Hashable {
//        case jumpRope = "Jump rope"
//        case bodyweight = "Bodyweight"
//        case custom = "Custom"
//    }
    
//    var workoutTypes = WorkoutType.allCases
    var selectedCategory: WorkoutCategory = WorkoutCategory(id: "", name: "")
    
//    var bodyweightWorkoutsState = WorkoutsListState()
//    var jumpropeWorkoutsState = WorkoutsListState()
    
    var workoutsState = WorkoutsListState()
    
    var categories: [WorkoutCategory] = []
    
    public init() {}
}

public struct WorkoutsFeedEnvironment {
    let service: WorkoutsFetchService
    let mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init(service: WorkoutsFetchService = .live, mainQueue: AnySchedulerOf<DispatchQueue>) {
        self.service = service
        self.mainQueue = mainQueue
    }
}

public let workoutsFeedReducer = Reducer<WorkoutsFeedState, WorkoutsFeedAction, WorkoutsFeedEnvironment>.combine(
    Reducer { state, action, environment in
    
    switch action {
        
    case .beginNavigation:
        if state.categories.isEmpty {
            return environment.loadCategories(mainQueue: environment.mainQueue)
        }
        
    case .workoutCategoryChanged(let category):
//        guard let category = state.categories.first(where: { $0.name == category }) else { break }
        state.selectedCategory = category
        state.workoutsState.workouts = category.workouts
//        state.selectedWorkoutType = type
//        if state.isSelectedTypeEmpty {
//            return environment.loadWorkouts(type, mainQueue: environment.mainQueue)
//        }
        
    case .categoriesLoaded(.success(let categories)):
        state.categories = categories
        return Effect(value: WorkoutsFeedAction.workoutCategoryChanged(categories.first!))
//        switch state.selectedWorkoutType {
//        case .bodyweight:
//            state.bodyweightWorkoutsState.workouts = workouts
//        case .jumpRope:
//            state.jumpropeWorkoutsState.workouts = workouts
//        default: break
//        }
        
    case .categoriesLoaded(.failure(let error)):
        break
        
    case .workoutsListAction(let listAction):
        break
    }
    
    
    return .none
},
    workoutsListReducer.pullback(
        state: \.workoutsState,
        action: /WorkoutsFeedAction.workoutsListAction,
        environment: { _ in WorkoutsListEnvironment() }
    )
)

private extension WorkoutsFeedEnvironment {
    func loadCategories(mainQueue: AnySchedulerOf<DispatchQueue>) -> Effect<WorkoutsFeedAction, Never> {
        service.categories()
            .receive(on: mainQueue)
            .mapError { _ in WorkoutsFeedError.failedLoadingWorkouts }
            .catchToEffect()
            .map(WorkoutsFeedAction.categoriesLoaded)
    }
}

//private extension WorkoutsFeedState.WorkoutType {
//    var filename: String {
//        switch self {
//        case .bodyweight: return "bodyweight"
//        case .jumpRope: return "jumprope"
//        case .custom: return "custom"
//        }
//    }
//}
//
//extension WorkoutsFeedState {
//    var isSelectedTypeEmpty: Bool {
//        switch selectedWorkoutType {
//        case .bodyweight:
//            return bodyweightWorkoutsState.workouts.isEmpty
//        case .jumpRope:
//            return jumpropeWorkoutsState.workouts.isEmpty
//        default: return false
//        }
//    }
//}
