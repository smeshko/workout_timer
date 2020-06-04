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
                    dtos.map { Workout(id: $0.id, name: $0.name, image: "") }
            }
        },
        categories: {
            WebClient.live
                .sendRequest(to: Endpoint.categories)
                .map { (dtos: [CategoryListDto]) in
                    dtos.map { WorkoutCategory(id: $0.id, name: $0.name, workouts: $0.workouts?.map { Workout(id: $0.id, name: $0.name, image: "") } ?? [] )}
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
