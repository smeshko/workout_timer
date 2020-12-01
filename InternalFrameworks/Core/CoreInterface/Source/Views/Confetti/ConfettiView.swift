import SwiftUI
import ComposableArchitecture

public struct Confetti: View {
    private let colors: [Color]
    private let count: Int

    public init(colors: [Color] = TintColor.allTints.map { $0.color },
                count: Int = 100) {
        self.colors = colors
        self.count = count
    }

    public var body: some View {
        ZStack {
            ForEach(0...count - 1, id: \.self) { number in
                ConfettiContainer(
                    store: Store<ConfettiState, Never>(
                        initialState: ConfettiState(
                            color: colors.randomElement() ?? .black,
                            openingAngle: .degrees(0),
                            closingAngle: .degrees(360),
                            radius: 200
                        ),
                        reducer: confettiReducer,
                        environment: ConfettiEnvironment()
                    )
                )
                .id(number)
            }
        }
    }
}

private struct ConfettiContainer: View {
    @State private var location: CGPoint = CGPoint(x: 0, y: 0)
    @State private var opacity: Double = 1.0

    private let store: Store<ConfettiState, Never>
    @ObservedObject private var viewStore: ViewStore<ConfettiState, Never>

    init(store: Store<ConfettiState, Never>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        SingleConfetti(color: viewStore.color)
            .offset(x: location.x, y: location.y)
            .opacity(opacity)
            .onAppear() {
                withAnimation(Animation.timingCurve(0.61, 1, 0.88, 1, duration: viewStore.explosionAnimationDuration)) {

                    let randomAngle: CGFloat

                    if viewStore.openingAngle.degrees <= viewStore.closingAngle.degrees {
                        randomAngle = CGFloat.random(in: CGFloat(viewStore.openingAngle.degrees)...CGFloat(viewStore.closingAngle.degrees))
                    } else {
                        randomAngle = CGFloat.random(in: CGFloat(viewStore.openingAngle.degrees)...CGFloat(viewStore.closingAngle.degrees + 360)).truncatingRemainder(dividingBy: 360)
                    }

                    let distance = CGFloat.random(in: 0.5...1) * viewStore.radius

                    location.x = distance * cos(degreesToRadians(randomAngle))
                    location.y = -distance * sin(degreesToRadians(randomAngle))
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + viewStore.explosionAnimationDuration) {
                    withAnimation(Animation.timingCurve(0.12, 0, 0.39, 0, duration: viewStore.rainAnimationDuration)) {
                        location.y += 600
                        opacity = 0
                    }
                }
            }
    }

    private func degreesToRadians(_ number: CGFloat) -> CGFloat {
        return number * CGFloat.pi / 180
    }
}

private struct SingleConfetti: View {
    @State private var animate = false
    @State private var xSpeed = Double.random(in: 0.7...2)
    @State private var zSpeed = Double.random(in: 1...2)
    @State private var anchor = CGFloat.random(in: 0...1).rounded()

    let color: Color

    var body: some View {
        Circle()
            .foregroundColor(color)
            .frame(width: 20, height: 20, alignment: .center)
            .onAppear {
                animate = true
            }
            .rotation3DEffect(
                .degrees(animate ? 360 : 0),
                axis: (x: 1, y: 0, z: 0)
            )
            .animation(
                Animation
                    .linear(duration: xSpeed)
                    .repeatForever(autoreverses: false), value: animate
            )
            .rotation3DEffect(
                .degrees(animate ? 360 : 0),
                axis: (x: 0, y: 0, z: 1),
                anchor: UnitPoint(x: anchor, y: anchor)
            )
            .animation(
                Animation
                    .linear(duration: zSpeed)
                    .repeatForever(autoreverses: false), value: animate
            )
    }
}
