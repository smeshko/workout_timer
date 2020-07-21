import Foundation
import WorkoutTimerAPI

public struct Exercise: Identifiable, Codable, Equatable, Hashable {
    public let id: String
    public let name: String
    public let imageKey: String
    public let thumbnailKey: String
    public let muscles: [String]
    public let steps: [String]
    public let level: Level

    public init(id: String, name: String, imageKey: String, muscles: [String] = [], steps: [String] = [], level: Level = .beginner) {
        self.id = id
        self.name = name
        self.imageKey = imageKey
        self.thumbnailKey = imageKey
        self.muscles = muscles
        self.steps = steps
        self.level = level
    }
    
    public init(dto: ExerciseGetDto) {
        self.id = dto.id
        self.name = dto.name
        self.imageKey = dto.imageKey
        self.thumbnailKey = dto.thumbnailKey
        self.muscles = dto.muscles
        self.steps = dto.steps
        self.level = Level(rawValue: dto.level) ?? .beginner
    }

    public init(dto: ExerciseListDto) {
        self.id = dto.id
        self.name = dto.name
        self.imageKey = dto.imageKey
        self.thumbnailKey = dto.thumbnailKey
        self.level = Level(rawValue: dto.level) ?? .beginner
        self.muscles = []
        self.steps = []
    }
}
