import SwiftUI
import WorkoutCore

struct WorkoutCardView: View {
    
    enum Layout {
        case narrow
        case wide
    }
    
    private let layout: Layout
    private let workout: Workout
    
    init(workout: Workout, layout: Layout = .wide) {
        self.workout = workout
        self.layout = layout
    }
    
    var body: some View {
        if layout == .wide {
            WideCardView(workout: workout)
                .cornerRadius(12)
        } else {
            NarrowCardView(workout: workout)
                .cornerRadius(12)
        }
    }
}

struct WorkoutCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WorkoutCardView(workout: mockWorkout1, layout: .wide)
                .previewLayout(.sizeThatFits)
                .padding(20)
            
            WorkoutCardView(workout: mockWorkout1, layout: .narrow)
                .previewLayout(.sizeThatFits)
                .padding(20)

        }
    }
}

private struct NarrowCardView: View {
    private let workout: Workout

    init(workout: Workout) {
        self.workout = workout
    }


    var body: some View {
        VStack(alignment: .leading) {
            GeometryReader { geo in
                ZStack {
                    RemoteImage(key: workout.imageKey)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                    
                    VStack(alignment: .leading) {
                        
                        HStack(spacing: 5) {
                            Image(systemName: "clock")
                                .font(.label)
                                .foregroundColor(.appWhite)
                            
                            Text("\(workout.duration) MIN")
                                .font(.label)
                                .tracking(1)
                                .foregroundColor(.appWhite)
                        }
                        
                        Spacer()
                        
                        Text(workout.name)
                            .font(.h2)
                            .foregroundColor(.appWhite)
                        
                        
                        LevelView(level: workout.level.rawValue, showLabel: false)
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                    .padding(18)
                }
            }
        }
        .frame(width: 150, height: 180)
    }
}

private struct WideCardView: View {

    private let workout: Workout

    init(workout: Workout) {
        self.workout = workout
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RemoteImage(key: workout.imageKey)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: 180)

                VStack(alignment: .leading) {

                    Spacer()

                    Text(workout.name)
                        .font(.h2)
                        .foregroundColor(.appWhite)

                    HStack {
                        LevelView(level: workout.level.rawValue, showLabel: true)

                        Spacer()
                        HStack(spacing: 5) {
                            Image(systemName: "clock")
                                .font(.label)
                                .foregroundColor(.appWhite)

                            Text("\(workout.duration) MIN")
                                .font(.label)
                                .tracking(1)
                                .foregroundColor(.appWhite)
                        }
                    }
                }
                .padding(18)
            }
            .frame(width: geometry.size.width, height: 180)
        }
    }
}

private struct LevelView: View {
    
    let level: Int
    let showLabel: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            
            if showLabel {
                Text("LEVEL")
                    .font(.label)
                    .tracking(1)
                    .foregroundColor(.appWhite)
            }
            
            HStack(spacing: 4) {
                Circle()
                    .frame(width: 5, height: 5)
                    .foregroundColor(.appSecondary)
                Circle()
                    .frame(width: 5, height: 5)
                    .foregroundColor(level > 1 ? .appSecondary : .appTextSecondary)
                Circle()
                    .frame(width: 5, height: 5)
                    .foregroundColor(level > 2 ? .appTextSecondary : .appTextSecondary)
            }
        }
    }
}

private struct WorkoutPriceView: View {
    
    let isFree: Bool
    let showBackground: Bool
    
    var body: some View {
        Text(isFree ? "Free" : "Paid")
            .font(.bodySmall)
            .foregroundColor(.appWhite)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(showBackground ?
                Rectangle()
                    .foregroundColor(.appTextSecondary)
                    .cornerRadius(4)
                : nil
            )
    }
}

private extension Workout {
    var duration: Int {
        let total = sets
            .map { $0.duration }
            .reduce(0, +)

        return Int(ceil(total / 60))
    }
}
