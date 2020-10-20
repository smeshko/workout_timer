import SwiftUI
import CorePersistence
import ComposableArchitecture

struct QuickWorkoutCardView: View {

    let store: Store<QuickWorkoutCardState, QuickWorkoutCardAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {

                Text("\(viewStore.duration) mins")
                    .font(.h3)

                Text("\(viewStore.segmentsCount) segments")
                    .font(.bodySmall)

                Spacer()

                HStack {
                    Text(viewStore.workout.name)
                        .font(.h1)

                    Spacer()

                    if viewStore.canStart {
                        Button(action: {
                            viewStore.send(.tapStart)
                        }, label: {
                            Image(systemName: "play.fill")
                                .padding(12)
                                .foregroundColor(.appText)
                                .background(Color(.sRGB, red: 48/255, green: 99/255, blue: 142/255, opacity: 1))
                                .mask(Circle())

                        })
                    }
                }
            }
            .padding(18)
            .background(Color.appCardBackground)
            .cornerRadius(12)
        }
    }
}

struct QuickWorkoutCardView_Previews: PreviewProvider {
    static var previews: some View {

        let store = Store<QuickWorkoutCardState, QuickWorkoutCardAction>(
            initialState: QuickWorkoutCardState(workout: QuickWorkout(id: UUID(), name: "Quick Workout", segments: [
                QuickWorkoutSegment(id: UUID(), sets: 4, work: 20, pause: 10),
                QuickWorkoutSegment(id: UUID(), sets: 2, work: 60, pause: 10)
            ]), canStart: true),
            reducer: quickWorkoutCardReducer,
            environment: QuickWorkoutCardEnvironment()
        )

        return Group {
            QuickWorkoutCardView(store: store)
                .padding()
                .previewLayout(.fixed(width: 375, height: 180))
                .preferredColorScheme(.dark)
        }
    }
}

extension UIColor {
      func toHexString() -> String {
          var h:CGFloat = 0
          var s:CGFloat = 0
          var b:CGFloat = 0
          var a:CGFloat = 0

        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
//          getRed(&r, green: &g, blue: &b, alpha: &a)

//          let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0

//          return String(format:"#%06x", rgb)
        return ""
      }
  }
