import SwiftUI
import WorkoutCore

struct ExerciseRowView: View {
  
  let set: ExerciseSet
  
  var body: some View {
    HStack(spacing: 0) {
      Image(uiImage: UIImage(data: set.image ?? Data()) ?? UIImage())
        .resizable()
        .frame(width: 96, height: 96)
        .aspectRatio(contentMode: .fit)
      
      Text("\(set.title ?? "")")
        .padding(.leading, 16)
      
      Spacer()
      
      Text(String(format: "%.0fs", set.duration))
        .padding(.trailing, 16)
    }
  }
}

struct ExerciseRowView_Previews: PreviewProvider {
  static var previews: some View {
    ExerciseRowView(set: ExerciseSet(exercise: .jumpingJacks, duration: 30))
  }
}
