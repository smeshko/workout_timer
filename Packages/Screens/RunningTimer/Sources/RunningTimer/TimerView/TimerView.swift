import SwiftUI
import CoreInterface
import DomainEntities
import ComposableArchitecture

public struct TimerView: View {
    @ObservedObject private var viewStore: ViewStore<TimerViewState, TimerViewAction>
    private let store: Store<TimerViewState, TimerViewAction>

    public init(store: Store<TimerViewState, TimerViewAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        IfLetStore(store.scope(state: \.countdownState, action: TimerViewAction.countdownAction)) { store in
            CountdownView(store: store)
        } else: {
            NavigationView {
                ZStack {
                    NavigationLink(
                        isActive: viewStore.binding(get: { $0.finishedState != nil })) {
                            IfLetStore(
                                store.scope(state: \.finishedState, action: TimerViewAction.finishedAction),
                                then: {
                                    FinishedWorkoutView(store: $0)
                                        .navigationBarHidden(true)
                                }
                            )
                        } label: {
                            Color.clear
                        }

                    TimerWrapper(store: store)
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarHidden(true)
                }
            }
        }
    }
}

extension Color {
    var monochromatic: Color {
        let components = hsbComponents()
        return Color(hue: components.h, saturation: components.s, brightness: components.b + 0.3)
    }
}

private struct CustomCircularProgressViewStyle: ProgressViewStyle {
    let isRunning: Bool
    let tint: Color

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: CGFloat(configuration.fractionCompleted ?? 0))
                .stroke(tint, style: StrokeStyle(lineWidth: 16, lineCap: .round, lineJoin: .round))
                .rotationEffect(.degrees(270))

            Image(systemName: isRunning ? "pause.fill" : "play.fill")
                .font(.gigantic)
                .foregroundColor(.appWhite)
        }
        .contentShape(Circle())
    }
}

private struct BackgroundGradient: View {
    let workoutColor: Color
    let state: TimerViewState.WorkoutState
    
    var colors: [Color] {
        switch state {
        case .workout: return [workoutColor.monochromatic, workoutColor]
        case .rest: return [.appGreen.monochromatic, .appGreen]
        case .pause: return [.appDark]
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.appDark]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
                .opacity(state == .pause ? 1 : 0)
            
            LinearGradient(
                gradient: Gradient(colors: [.appGreen.monochromatic, .appGreen]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
                .opacity(state == .rest ? 1 : 0)

            LinearGradient(
                gradient: Gradient(colors: [workoutColor.monochromatic, workoutColor]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
                .opacity(state == .workout ? 1 : 0)
        }
        .animation(.default, value: state)
    }
}

private struct TimerWrapper: View {
    @ObservedObject private var viewStore: ViewStore<TimerViewState, TimerViewAction>
    private let store: Store<TimerViewState, TimerViewAction>

    public init(store: Store<TimerViewState, TimerViewAction>) {
        self.viewStore = ViewStore(store)
        self.store = store
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                Button(action: {
                    viewStore.send(.closeButtonTapped)
                }) {
                    Image(systemName: "xmark")
                        .font(.h2.bold())
                        .foregroundColor(.appWhite)
                }
            }
            
            Spacer()
            
            VStack {
                Text(viewStore.totalTimeLeft.formattedTimeLeft)
                    .font(.h1.monospacedDigit())
                    .foregroundColor(.appWhite)
                
                Text("Remaining")
                    .font(.h4)
                    .foregroundColor(.appWhite)
            }
            
            ProgressView(
                value: (viewStore.currentSection?.timeLeft ?? 0),
                total: (viewStore.currentSection?.duration ?? 0)
            )
                .progressViewStyle(CustomCircularProgressViewStyle(isRunning: viewStore.isRunning, tint: .white))
                .onTapGesture {
                    viewStore.send(viewStore.isRunning ? .pause : .resume)
                }
            
            Group {
                
                Spacer()
                
                Text(viewStore.currentSection?.timeLeft.formattedTimeLeft ?? "")
                    .font(.giganticMono)
                    .foregroundColor(.appWhite)
                
                Text(viewStore.currentSection?.name ?? "")
                    .font(.h1)
                    .foregroundColor(.appWhite)
                
                Spacer()
                
                VStack {
                    Text("\(viewStore.finishedSections + 1)/\(viewStore.timerSections.count)")
                        .font(.h2)
                        .foregroundColor(.appWhite)
                    Text("Intervals")
                        .font(.h3)
                        .foregroundColor(.appWhite)
                }
            }
            
            ProgressView(value: viewStore.totalTimeExpired, total: viewStore.timerSections.totalDuration)
                .tint(.white)
                .frame(maxWidth: .infinity, maxHeight: 4)
        }
        .padding(Spacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            BackgroundGradient(workoutColor: viewStore.workout.color.color, state: viewStore.workoutState)
                .ignoresSafeArea(.all)
        )
        .onAppear {
            viewStore.send(.timerBegin)
        }
        .alert(store.scope(state: \.alert), dismiss: .alertDismissed)
    }
}
