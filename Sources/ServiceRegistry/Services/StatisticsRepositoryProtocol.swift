import Foundation
import DomainEntities

public protocol StatisticsRepositoryProtocol {
    func fetchAll() async throws -> [Statistic]
    func finish(_ workout: FinishedWorkout, calories: Int) async throws -> Statistic
}
