import SwiftUI
import ComposableArchitecture
import WorkoutCore

public struct WorkoutsFeedView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    let store: Store<WorkoutsFeedState, WorkoutsFeedAction>
    
    public init(store: Store<WorkoutsFeedState, WorkoutsFeedAction>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            WithViewStore(store) { viewStore in
                Group {
                    if self.horizontalSizeClass == .regular {
                        ListWorkoutsView(viewStore: viewStore)

                    } else {
                        SegmentedWorkoutsView(
                            categoryViewStore: ViewStore(self.store.scope(state: \.selectedCategory, action: WorkoutsFeedAction.workoutCategoryChanged)),
                            viewStore: viewStore
                        )
                    }
                }
                .overlay(ActivityIndicator(isAnimating: viewStore.binding(get: \.isLoading, send: WorkoutsFeedAction.loadingIndicatorStoppedLoading)))
                .onAppear {
                    viewStore.send(.beginNavigation)
                }
            }
            .navigationBarTitle("Workouts")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(.primary)
    }
}

private struct SegmentedWorkoutsView: View {
    
    let categoryViewStore: ViewStore<WorkoutCategory, WorkoutCategory>
    let viewStore: ViewStore<WorkoutsFeedState, WorkoutsFeedAction>
    
    var body: some View {
        VStack {
            Picker("Types", selection: categoryViewStore.binding(send: { $0 })) {
                ForEach(viewStore.categories, id: \.id) { category in
                    Text(category.name).tag(category)
                }
            }
            .padding([.leading, .trailing])
            .labelsHidden()
            .pickerStyle(SegmentedPickerStyle())
            
            WorkoutsListView(workouts: viewStore.selectedCategory.workouts)
            Spacer()
        }
    }
}

private struct ListWorkoutsView: View {
    
    let viewStore: ViewStore<WorkoutsFeedState, WorkoutsFeedAction>

    var body: some View {
        ScrollView {
            ForEach(viewStore.categories, id: \.id) { category in
                VStack(alignment: .leading, spacing: 8) {
                    Text(category.name)
                        .padding()
                        .font(.system(size: 16, weight: .semibold))
                    WorkoutsListView(workouts: category.workouts)
                }
            }
        }
        .edgesIgnoringSafeArea(.leading)
    }
}

struct WorkoutsFeedView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutsFeedView(
            store: Store<WorkoutsFeedState, WorkoutsFeedAction>(
                initialState: WorkoutsFeedState(),
                reducer: workoutsFeedReducer,
                environment: WorkoutsFeedEnvironment(
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler()
                )
            )
        )
    }
}
