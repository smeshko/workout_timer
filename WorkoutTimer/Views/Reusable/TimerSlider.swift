import SwiftUI

struct TimerSlider: View {
    @Binding var value: Float
    
    private var foreground: Color = .accentColor
    private var background: Color = .gray

    init(value: Binding<Float>) {
        self._value = value
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(self.background)
                Rectangle()
                    .foregroundColor(self.foreground)
                    .frame(width: geometry.size.width * CGFloat(self.value / 100))
            }
            .cornerRadius(12)
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged({ value in
                    self.value = min(max(0, Float(value.location.x / geometry.size.width * 100)), 100)
                }))
        }
    }

    func sliderForeground(_ color: Color) -> TimerSlider {
        update(\.foreground, value: color)
    }

    func sliderBackground(_ color: Color) -> TimerSlider {
        update(\.background, value: color)
    }
}
