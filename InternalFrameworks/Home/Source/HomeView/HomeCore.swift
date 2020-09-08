import Foundation
import WorkoutCore
import ComposableArchitecture

enum LoadingState {
    case loading
    case done
    case error
}

public enum HomeError: Error, Equatable {
    case failedLoadingWorkouts
}

public enum HomeAction: Equatable {
    case workoutCategoryChanged(WorkoutCategory)
    case categoriesLoaded(Result<[WorkoutCategory], HomeError>)
    case featuredLoaded(Result<[Workout], HomeError>)
    case loadingIndicatorStoppedLoading(Bool)
    case beginNavigation
}

public struct HomeState: Equatable {
    var selectedCategory: WorkoutCategory = WorkoutCategory(id: "", name: "")
    var categories: [WorkoutCategory] = []
    var featuredWorkouts: [Workout] = []
    var loadingState: LoadingState = .done
    var isLoading: Bool { loadingState == .loading }
    
    public init() {}
}

public struct HomeEnvironment {
    let service: WorkoutsFetchService
    let mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init(service: WorkoutsFetchService = .live, mainQueue: AnySchedulerOf<DispatchQueue>) {
        self.service = service
        self.mainQueue = mainQueue
    }
}

public let homeReducer = Reducer<HomeState, HomeAction, HomeEnvironment> { state, action, environment in
    
    switch action {
        
    case .beginNavigation:
        if state.categories.isEmpty || state.featuredWorkouts.isEmpty {
            state.loadingState = .loading
            return Effect
                .concatenate(environment.loadCategories(mainQueue: environment.mainQueue),
                             environment.loadFeatured(mainQueue: environment.mainQueue))
        }
        
    case .loadingIndicatorStoppedLoading:
        break
        
    case .workoutCategoryChanged(let category):
        state.selectedCategory = category
        
    case .categoriesLoaded(.success(let categories)):
        state.loadingState = .done
        state.categories = categories
        return Effect(value: HomeAction.workoutCategoryChanged(categories.first!))

    case .featuredLoaded(.success(let workouts)):
        state.loadingState = .done
        state.featuredWorkouts = workouts

    case .categoriesLoaded(.failure(let error)), .featuredLoaded(.failure(let error)):
        break
    }
    
    return .none
}

private extension HomeEnvironment {
    func loadCategories(mainQueue: AnySchedulerOf<DispatchQueue>) -> Effect<HomeAction, Never> {
        service.categories()
            .receive(on: mainQueue)
            .mapError { _ in HomeError.failedLoadingWorkouts }
            .catchToEffect()
            .map(HomeAction.categoriesLoaded)
    }

    func loadFeatured(mainQueue: AnySchedulerOf<DispatchQueue>) -> Effect<HomeAction, Never> {
        service.featured()
            .receive(on: mainQueue)
            .mapError { _ in HomeError.failedLoadingWorkouts }
            .catchToEffect()
            .map(HomeAction.featuredLoaded)
    }
}
