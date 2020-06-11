import SwiftUI
import WorkoutCore
import WorkoutDetails
import ComposableArchitecture

struct WorkoutsListView: View {
    private let workouts: [Workout]
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?

    init(workouts: [Workout]) {
        self.workouts = workouts
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if workouts.isEmpty {
                Text("Sorry, no workouts")
            } else {
//                ScrollView(self.horizontalSizeClass == .compact ? .vertical : .horizontal) {
                SizeClassAdaptingView(.vertical, .horizontal) {
                    ForEach(workouts) { workout in
                        NavigationLink(destination: WorkoutDetailsView(workout: workout)) {
                            WorkoutView(workout: workout)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    Spacer()
                }
            }
        }
    }
}

struct WorkoutsListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutsListView(workouts: [
            Workout(id: "", name: "Recommended Routine", image: "", sets: [])
        ])
    }
}
