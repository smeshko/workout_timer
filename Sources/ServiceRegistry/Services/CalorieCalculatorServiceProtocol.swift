import Foundation

public protocol CalorieCalculatorServiceProtocol {
    func calculate(duration: Double, met: Double, weight: Double) -> Int
}
