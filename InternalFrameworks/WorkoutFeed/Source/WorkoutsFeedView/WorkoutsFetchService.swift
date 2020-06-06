import ComposableArchitecture
import WorkoutCore
import WorkoutTimerAPI

public struct WorkoutsFetchService {
    
    var workouts: () -> Effect<[Workout], NetworkError>
    var categories: () -> Effect<[WorkoutCategory], NetworkError>
}

public extension WorkoutsFetchService {
    static let live = WorkoutsFetchService(
        workouts: {
            WebClient.live
                .sendRequest(to: Endpoint.workouts)
                .map { (dtos: [WorkoutListDto]) in
                    dtos.map { Workout(dto: $0) }
            }
        },
        categories: {
            WebClient.live
                .sendRequest(to: Endpoint.categories)
                .map { (dtos: [CategoryListDto]) in
                    dtos.map { WorkoutCategory(dto: $0) }
            }
        })
    
    static let mock = WorkoutsFetchService(
        workouts: {
            Effect<[Workout], NetworkError>(value: [
                Workout(id: "workout-1", name: "Mock workout", image: "image", sets: [])
            ])
        }, categories: {
            Effect<[WorkoutCategory], NetworkError>(value: [
                WorkoutCategory(id: "category-1", name: "Mock category", workouts: [
                    Workout(id: "workout-1", name: "Mock workout", image: "image", sets: [])
                ])
            ])
        }
    )
}
