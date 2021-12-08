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
                .stroke(Color.appGrey.opacity(0.2), style: StrokeStyle(lineWidth: 16))

            Circle()
                .trim(from: 0.0, to: CGFloat(configuration.fractionCompleted ?? 0))
                .stroke(tint, style: StrokeStyle(lineWidth: 16, lineCap: .round, lineJoin: .round))
                .rotationEffect(.degrees(270))
            
            Image(systemName: isRunning ? "pause.fill" : "play.fill")
                .styling(font: .gigantic, color: .appWhite)
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
        VStack(spacing: Spacing.s) {
            ZStack(alignment: .trailing) {
                HStack {
                    Spacer()
                    
                    VStack {
                        Text(viewStore.totalTimeLeft.formattedTimeLeft)
                            .styling(font: .h1.monospacedDigit(), color: .appWhite)
                        
                        Text("Remaining")
                            .styling(font: .h4, color: .appWhite)
                    }
                    
                    Spacer()
                }
                
                HStack {
                    
                    Button {
                        viewStore.send(.toggleSound)
                    } label: {
                        Image(systemName: viewStore.isSoundEnabled ? "bell.fill" : "bell.slash.fill")
                            .styling(font: .h2.bold(), color: .appWhite)
                    }

                    Spacer()
                
                    Button(action: {
                        viewStore.send(.closeButtonTapped)
                    }) {
                        Image(systemName: "xmark")
                            .styling(font: .h2.bold(), color: .appWhite)
                    }
                }
            }
            
            Spacer()
            
            ProgressView(value: (viewStore.currentSection?.timeLeft ?? 0), total: (viewStore.currentSection?.duration ?? 0))
                .progressViewStyle(CustomCircularProgressViewStyle(isRunning: viewStore.isRunning, tint: .white))
                .padding(.horizontal, Spacing.s)
            
            Spacer()
            
            VStack(spacing: Spacing.xxs) {
                Text(viewStore.currentSection?.timeLeft.formattedTimeLeft ?? "")
                    .styling(font: .gigantic.monospacedDigit(), color: .appWhite)
                
                Text(viewStore.currentSection?.name ?? "")
                    .styling(font: .h1, color: .appWhite)
            }
            
            Button {
                viewStore.send(.next)
            } label: {
                Text("Skip")
                    .styling(font: .h4, color: .appWhite)
            }
            .disabled(viewStore.nextSection == nil)
            .padding(.vertical, Spacing.m)
            .padding(.horizontal, Spacing.xl)
            .background(Capsule().foregroundColor(.appGrey).opacity(0.1))
            
            VStack(spacing: Spacing.xxs) {
                Text("\(viewStore.finishedWorkSections + 1)/\(viewStore.totalWorkSections)")
                    .styling(font: .h3, color: .appWhite)

                Text("Intervals")
                    .styling(font: .h4, color: .appWhite)
            }
            
            ProgressView(value: viewStore.totalTimeExpired, total: viewStore.timerSections.totalDuration)
                .background(Color.appGrey.opacity(0.1))
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
        .onTapGesture {
            viewStore.send(viewStore.isRunning ? .pause : .resume)
        }
        .alert(store.scope(state: \.alert), dismiss: .alertDismissed)
    }
}
