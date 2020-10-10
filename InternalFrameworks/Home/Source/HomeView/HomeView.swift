import SwiftUI
import WorkoutCore
import WorkoutDetails
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
                        .foregroundColor(.appWhite)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewStore.featuredWorkouts, id: \.id) { workout in
                                NavigationLink(destination: WorkoutDetailsView(workout: workout)) {
                                    WorkoutCardView(workout: workout)
                                        .frame(width: UIScreen.main.bounds.width, height: 180)
                                        .tag(workout)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 28)
                    }
                    .frame(width: UIScreen.main.bounds.width, height: 200)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                }

                ForEach(viewStore.categories, id: \.id) { category in

                    VStack(alignment: .leading) {
                        Text(category.name)
                            .padding(.leading, 28)
                            .padding(.top, 18)
                            .font(.h2)
                            .foregroundColor(.appWhite)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(category.workouts, id: \.id) { workout in
                                    NavigationLink(destination: WorkoutDetailsView(workout: workout)) {
                                        WorkoutCardView(workout: workout, layout: .narrow)
                                            .frame(width: 150, height: 180)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.leading, 28)
                    }
                }

                Spacer()
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
        HomeView(
            store: Store<HomeState, HomeAction>(
                initialState: HomeState(),
                reducer: homeReducer,
                environment: HomeEnvironment(mainQueue: DispatchQueue.main.eraseToAnyScheduler())
            )
        )
    }
}
