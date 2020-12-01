import DomainEntities
import Foundation

public struct TimerSection: Equatable {
    enum SectionType {
        case work, pause
    }

    let id: UUID
    let duration: TimeInterval
    let type: SectionType
    let name: String

    static func create(from segment: QuickWorkoutSegment) -> [TimerSection] {
        var sections: [TimerSection] = []

        (0 ..< segment.sets).forEach { index in
            sections.append(TimerSection(id: UUID(), duration: TimeInterval(segment.work), type: .work, name: segment.name))
            sections.append(TimerSection(id: UUID(), duration: TimeInterval(segment.pause), type: .pause, name: "Rest"))
        }

        return sections
    }
}
