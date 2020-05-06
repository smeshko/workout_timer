import SwiftUI
import ComposableArchitecture

struct ValueSlider: View {
  
  @GestureState private var dragState = CGSize.zero
  @GestureState private var longPressActive: Bool = false
  
  let store: Store<SliderState, SliderAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack {
        VStack(spacing: 4) {
          Text("\(viewStore.value)")
          Text("Sets")
          HStack(alignment: .bottom) {
            ForEach(0 ..< 31) {
              Rectangle()
                .frame(width: 2, height: $0 % 2 == 0 ? 15 : 10)
              Spacer()
            }
          }
        }
        .gesture(
          LongPressGesture()
            .updating(self.$longPressActive, body: { value, state, _ in
              state = true
            })
            .sequenced(before: DragGesture(minimumDistance: 0)
              .updating(self.$dragState, body: { value, state, _ in
                state = value.translation
                print(state)
              })
          )
        )

      }
    }
  }
}

struct ValueSlider_Previews: PreviewProvider {
  static var previews: some View {
    ValueSlider(
      store: Store<SliderState, SliderAction>(
        initialState: SliderState(),
        reducer: sliderReducer,
        environment: SliderEnvironment()
      )
    )
  }
}
