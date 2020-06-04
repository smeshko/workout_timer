import SwiftUI
import WorkoutCore
import WorkoutDetails

struct WorkoutsListView: View {
    private let workouts: [Workout]
    
    init(workouts: [Workout]) {
        self.workouts = workouts
    }
    
    var body: some View {
        VStack {
            if workouts.isEmpty {
                Text("Sorry, no workouts")
            } else {
                ScrollView {
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
