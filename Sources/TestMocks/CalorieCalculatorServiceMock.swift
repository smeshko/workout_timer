import Foundation
import TestUtilities
import ServiceRegistry

public class CalorieCalculatorServiceMock: MockBase, CalorieCalculatorServiceProtocol {
    public var value: Int?

    public func calculate(duration: Double, met: Double, weight: Double) -> Int {
        track()
        return value!
    }
}
