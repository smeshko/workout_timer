import SwiftUI
import WorkoutCore

struct ExerciseRowView: View {
    
    let set: ExerciseSet
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 0) {
                if !set.isRecovery {
                    RemoteImage(key: set.image)
                        .frame(width: 96, height: 96)
                        .aspectRatio(contentMode: .fit)
                }
                
                Text("\(set.name)")
                    .padding(.leading, 16)
                    .padding(.vertical, set.isRecovery ? 16 : 0)
                
                
                Spacer()
                
                Text(set.duration.formattedTimeLeft)
                    .padding(.trailing, 16)
            }
            
            Divider()
        }
    }
}

struct ExerciseRowView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseRowView(set: ExerciseSet(id: "setid", exercise: mockExercise1, duration: 30))
    }
}

private extension ExerciseSet {
    var isRecovery: Bool {
        self.name == Exercise.recovery.name
    }
}
