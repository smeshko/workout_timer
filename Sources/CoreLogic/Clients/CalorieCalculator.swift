public struct CalorieCalculator {
    public var calories: (Double, Double, Double) -> Int
}

public extension CalorieCalculator {
    static var live: CalorieCalculator {
        CalorieCalculator(calories: { duration, met, weight in
            Int(((duration / 60) * met * 3.5 * weight) / 200)
        })
    }

    static var mock: CalorieCalculator {
        CalorieCalculator(calories: { duration, met, weight in
            Int(((duration / 60) * met * 3.5 * weight) / 200)
        })
    }
}
