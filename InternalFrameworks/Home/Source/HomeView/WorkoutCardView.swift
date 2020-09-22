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
                .previewLayout(.fixed(width: 375, height: 180))
                .padding(20)
            
            WorkoutCardView(workout: mockWorkout1, layout: .narrow)
                .previewLayout(.fixed(width: 150, height: 180))
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
            ZStack {
                GeometryReader { geometry in
                    RemoteImage(key: workout.imageKey)
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: geometry.size.width,
                               maxHeight: geometry.size.height)

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
                            .font(.h3)
                            .foregroundColor(.appWhite)
                        
                        
                        LevelView(level: workout.level.rawValue, showLabel: false)
                    }
                    .padding(18)
                }
            }
        }
    }
}

private struct WideCardView: View {

    private let workout: Workout

    init(workout: Workout) {
        self.workout = workout
    }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                RemoteImage(key: workout.imageKey)
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: geometry.size.width,
                           maxHeight: 180)

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
                    .foregroundColor(.appGrey)
                    .cornerRadius(4)
                : nil
            )
    }
}
