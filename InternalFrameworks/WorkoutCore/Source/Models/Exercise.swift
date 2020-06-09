import Foundation
import WorkoutTimerAPI

public struct Exercise: Identifiable, Codable, Equatable, Hashable {
    public let id: String
    public let name: String
    public let image: String
    
    public init(id: String, name: String, image: String) {
        self.id = id
        self.name = name
        self.image = image
    }
    
    public init(dto: ExerciseGetDto) {
        self.id = dto.id
        self.name = dto.name
        self.image = dto.imageKey
    }
}

public extension Exercise {
    static let recovery = Exercise(id: "recovery", name: "Recovery", image: "")
}
