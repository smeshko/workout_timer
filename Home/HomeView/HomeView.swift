import SwiftUI
import WorkoutCore

struct HomeView: View {
    
    let workouts = [
        WorkoutCategory(id: "1", name: "Boxing", workouts: [
            Workout(id: "1", name: "Boxing 1", image: "bodyweight-1", sets: []),
            Workout(id: "2", name: "Boxing 2", image: "bodyweight-3", sets: []),
            Workout(id: "3", name: "Boxing 3", image: "bodyweight-2", sets: [])
        ]),
        
        WorkoutCategory(id: "2", name: "Cardio", workouts: [
            Workout(id: "4", name: "Cardio 1", image: "bodyweight-1", sets: []),
            Workout(id: "5", name: "Cardio 2", image: "bodyweight-3", sets: []),
            Workout(id: "6", name: "Cardio 3", image: "bodyweight-2", sets: [])
        ])
    ]
    
    let featuredWorkouts = [
        Workout(id: "1", name: "Full Body Burner", image: "jumprope-1", sets: []),
        Workout(id: "2", name: "Jumprope Burner", image: "jumprope-2", sets: [])
    ]
    
    
    var body: some View {
//        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    Text("Featured Workouts")
                        .padding(.leading, 28)
                        .font(.h2)
                        .foregroundColor(.appTextPrimary)
                    TabView {
                        ForEach(featuredWorkouts, id: \.id) { _ in
                            WorkoutCardView()
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(width: UIScreen.main.bounds.width, height: 200)
                }
                
                ForEach(workouts, id: \.id) { category in
                    
                    VStack(alignment: .leading) {
                        Text(category.name)
                            .padding(.leading, 28)
                            .padding(.top, 18)
                            .font(.h2)
                            .foregroundColor(.appTextPrimary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(workouts, id: \.id) { _ in
                                    WorkoutCardView(layout: .narrow)
                                }
                            }
                        }
                        .padding(.leading, 28)
                    }
                }
            }

            .frame(maxHeight: .infinity)
            .navigationTitle("Home")
//        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
