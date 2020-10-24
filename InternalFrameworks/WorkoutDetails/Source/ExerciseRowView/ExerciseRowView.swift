import SwiftUI
import WorkoutCore
import CoreInterface

struct ExerciseRowView: View {
    
    let set: ExerciseSet
    
    var body: some View {
        HStack {
            RemoteImage(key: set.imageKey)
                .frame(width: 68, height: 68)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(12)
            
            Text(set.duration.formattedTimeLeft)
                .padding(.leading, 18)
                .foregroundColor(.appGrey)
                .font(.h3)
            
            Text("\(set.name)")
                .padding(.leading, 18)
                .foregroundColor(.appText)
                .font(.h3)
            
            Spacer()
        }
    }
}

struct ExerciseRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ExerciseRowView(set: ExerciseSet(id: "setid", exercise: mockExercise1, duration: 30))
                .padding()
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
            
            ExerciseRowView(set: ExerciseSet(id: "setid", exercise: mockExercise1, duration: 30))
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
}

private extension ExerciseSet {
    var isRecovery: Bool {
        type == .rest
    }
}
