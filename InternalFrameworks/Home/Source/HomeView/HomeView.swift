import SwiftUI
import WorkoutCore
import ComposableArchitecture

public struct HomeView: View {

    let store: Store<HomeState, HomeAction>

    public init(store: Store<HomeState, HomeAction>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    Text("Featured Workouts")
                        .padding(.top, 18)
                        .padding(.leading, 28)
                        .font(.h2)
                        .foregroundColor(.appTextPrimary)
                    TabView {
                        ForEach(viewStore.featuredWorkouts, id: \.id) { workout in
                            WorkoutCardView(workout: workout)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(width: UIScreen.main.bounds.width, height: 200)
                }

                ForEach(viewStore.categories, id: \.id) { category in

                    VStack(alignment: .leading) {
                        Text(category.name)
                            .padding(.leading, 28)
                            .padding(.top, 18)
                            .font(.h2)
                            .foregroundColor(.appTextPrimary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(category.workouts, id: \.id) { workout in
                                    WorkoutCardView(workout: workout, layout: .narrow)
                                }
                            }
                        }
                        .padding(.leading, 28)
                    }
                }
            }
            .frame(maxHeight: .infinity)
            .onAppear {
                viewStore.send(.beginNavigation)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Home")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Text("Hello")
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Image(systemName: "heart")
                    Text("A title")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}



