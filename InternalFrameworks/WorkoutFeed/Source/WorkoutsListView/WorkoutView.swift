import SwiftUI
import WorkoutCore
import ComposableArchitecture
import WorkoutDetails

struct WorkoutView: View {
    private struct Constants {
        static let regularImageWidth: CGFloat = 375
    }
    
    let workout: Workout
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                RemoteImage(key: workout.imageKey)
                    .aspectRatio(contentMode: .fit)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(self.workout.name)
                        .font(.system(size: 24, weight: .bold))
                    Text(self.workout.duration)
                        .font(.system(size: 32, weight: .heavy))
                    Spacer()
                    Text("\(self.workout.count) exercises")
                        .font(.system(size: 16, weight: .semibold))
                }
                .padding()
            }
            .frame(width: self.imageWidth(in: geometry), height: 240)
        }
    }
    
    func imageWidth(in geometry: GeometryProxy) -> CGFloat {
        if horizontalSizeClass == .compact {
            return geometry.size.width
        } else {
            return Constants.regularImageWidth
        }
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        
        return WorkoutView(workout: mockWorkout1)
            .environment(\.colorScheme, .dark)
            .previewLayout(.fixed(width: 375, height: 240))
    }
}

private extension Workout {
    var duration: String {
        let total = sets
            .map { $0.duration }
            .reduce(0, +)
        
        let minutes = Int(ceil(total / 60))
        
        return "\(minutes)m"
    }
    
    var count: String {
        "\(sets.filter { $0.type != .rest }.count)"
    }
}
