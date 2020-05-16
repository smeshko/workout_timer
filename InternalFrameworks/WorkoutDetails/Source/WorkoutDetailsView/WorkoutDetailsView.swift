import SwiftUI
import WorkoutCore
import ComposableArchitecture

public struct WorkoutDetailsView: View {
  let store: Store<WorkoutDetailsState, WorkoutDetailsAction>
  
  public init(workout: Workout) {
    store = Store<WorkoutDetailsState, WorkoutDetailsAction>(
      initialState: WorkoutDetailsState(workout: workout),
      reducer: workoutDetailsReducer,
      environment: WorkoutDetailsEnvironment()
    )
  }
  
  public var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        ZStack {
          Image(uiImage: UIImage(data: viewStore.workout.image ?? Data()) ?? UIImage())
            .resizable()
            .aspectRatio(contentMode: .fit)
          
          VStack(spacing: 64) {
            Text(viewStore.workout.name ?? "")
              .font(.system(size: 24, weight: .bold))
            
            Button(action: {}) {
              Text("Start")
                .padding(32)
                .background(Color.white)
                .clipShape(Circle())
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            }
          }
        }
        ForEach(viewStore.workout.sets, id: \.title) { set in
          Text("\(set.title ?? "") for \(set.duration)s")
        }
        Spacer()
      }
      .navigationBarTitle("", displayMode: .inline)
    }
  }
}

struct WorkoutDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    WorkoutDetailsView(workout: Workout(id: ""))
  }
}
