import Foundation

public extension Workout {
    var duration: Int {
        let total = sets
            .map { $0.duration }
            .reduce(0, +)

        return Int(ceil(total / 60))
    }

    var warmup: [ExerciseSet] {
        sets.filter { $0.type == .warmup }
    }

    var cooldown: [ExerciseSet] {
        sets.filter { $0.type == .cooldown }
    }

    var main: [ExerciseSet] {
        sets.filter { $0.type == .workout }
    }

    var modules: [String: [ExerciseSet]] {
        var modules: [String: [ExerciseSet]] = [:]
        if !warmup.isEmpty {
            modules["Warmup"] = warmup
        }

        if !main.isEmpty {
            modules["Work"] = main
        }

        if !cooldown.isEmpty {
            modules["Cooldown"] = cooldown
        }
        return modules
    }

    var exerciseCount: Int {
        sets.filter { $0.type != .rest }.count
    }
}
