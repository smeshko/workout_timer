import Foundation
import ServiceRegistry

public class CalorieCalculatorService: CalorieCalculatorServiceProtocol {

    public func calculate(duration: Double, met: Double, weight: Double) -> Int {
        Int(((duration / 60) * met * 3.5 * weight) / 200)
    }
}
