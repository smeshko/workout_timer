import Foundation
import WorkoutCore
import ComposableArchitecture

enum LoadingState {
    case loading
    case done
    case error
}

public enum WorkoutsFeedError: Error, Equatable {
    case failedLoadingWorkouts
}

public enum WorkoutsFeedAction: Equatable {
    case workoutCategoryChanged(WorkoutCategory)
    case categoriesLoaded(Result<[WorkoutCategory], WorkoutsFeedError>)
    case loadingIndicatorStoppedLoading(Bool)
    case beginNavigation
}

public struct WorkoutsFeedState: Equatable {
    var selectedCategory: WorkoutCategory = WorkoutCategory(id: "", name: "")
    var categories: [WorkoutCategory] = []
    var loadingState: LoadingState = .done
    var isLoading: Bool { loadingState == .loading }
    
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

public let workoutsFeedReducer = Reducer<WorkoutsFeedState, WorkoutsFeedAction, WorkoutsFeedEnvironment> { state, action, environment in
    
    switch action {
        
    case .beginNavigation:
        if state.categories.isEmpty {
            state.loadingState = .loading
            return environment.loadCategories(mainQueue: environment.mainQueue)
        }
        
    case .loadingIndicatorStoppedLoading:
        break
        
    case .workoutCategoryChanged(let category):
        state.selectedCategory = category
        
    case .categoriesLoaded(.success(let categories)):
        state.loadingState = .done
        state.categories = categories
        return Effect(value: WorkoutsFeedAction.workoutCategoryChanged(categories.first!))
        
    case .categoriesLoaded(.failure(let error)):
        break
    }
    
    return .none
}

private extension WorkoutsFeedEnvironment {
    func loadCategories(mainQueue: AnySchedulerOf<DispatchQueue>) -> Effect<WorkoutsFeedAction, Never> {
        service.categories()
            .receive(on: mainQueue)
            .mapError { _ in WorkoutsFeedError.failedLoadingWorkouts }
            .catchToEffect()
            .map(WorkoutsFeedAction.categoriesLoaded)
    }
}
