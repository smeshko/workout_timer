import SwiftUI
import CoreInterface
import DomainEntities
import ComposableArchitecture

struct WorkoutPreview: View {
    let store: Store<TimerCardState, TimerCardAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Text(viewStore.workout.name)
                        .font(.h1)
                        .foregroundColor(.appWhite)

                    Spacer()

                    Text("mins".localized(viewStore.duration))
                        .font(.h2)
                        .foregroundColor(.appWhite)
                }

                ScrollView(.vertical) {
                    ForEach(viewStore.workout.segments) { segment in
                        VStack(alignment: .leading) {
                            Text("\(segment.sets)x \(segment.name)")
                                .font(.h2)
                                .foregroundColor(.appWhite)


                            HStack {
                                VStack(spacing: Spacing.s) {
                                    Image(systemName: "suit.heart.fill")
                                    Text("\(segment.work)s")
                                }
                                .cardBackground(foreground: viewStore.workout.color.monochromatic)

                                VStack(spacing: Spacing.s) {
                                    Image(systemName: "pause.fill")
                                    Text("\(segment.pause)s")
                                }
                                .cardBackground(foreground: viewStore.workout.color.monochromatic)
                            }
                        }
                    }
                }
                .padding(.top, Spacing.s)
            }
            .padding(.horizontal, Spacing.xxl)
            .padding(.top, Spacing.xxl)
            .fullWidth()
            .fullHeight()
            .frame(alignment: .topLeading)
            .background(viewStore.workout.color.color)
        }
    }
}

private extension View {
    func cardBackground(foreground: Color) -> some View {
        font(.h3)
            .foregroundColor(.appWhite)
            .padding(Spacing.l)
            .fullWidth()
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.m)
                    .foregroundColor(foreground)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 5, y: 5)
            )
    }
}

private extension WorkoutColor {
    var monochromatic: Color {
        Color(hue: hue, saturation: saturation, brightness: brightness + 0.1)
    }
}
