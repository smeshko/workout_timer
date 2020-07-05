import SwiftUI
import WorkoutCore

struct WorkoutCardView: View {
    
    enum Layout {
        case narrow
        case wide
    }
    
    let layout: Layout
    
    init(layout: Layout = .wide) {
        self.layout = layout
    }
    
    var body: some View {
        Group {
            if layout == .wide {
                WideCardView()
            } else {
                NarrowCardView()
            }
        }
        .cornerRadius(12)
    }
}

struct WorkoutCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WorkoutCardView(layout: .wide)
                .previewLayout(.sizeThatFits)
                .padding(20)
            
            WorkoutCardView(layout: .narrow)
                .previewLayout(.sizeThatFits)
                .padding(20)

        }
    }
}

private struct NarrowCardView: View {
    var body: some View {
        ZStack {
            Image(uiImage: UIImage(namedSharedAsset: "bodyweight-2"))
                .resizable()
                .aspectRatio(contentMode: .fill)
            
            VStack(alignment: .leading) {
                
                HStack(spacing: 5) {
                    Image(systemName: "clock")
                        .font(.label)
                        .foregroundColor(.appWhite)
                    
                    Text("50 MIN")
                        .font(.label)
                        .tracking(1)
                        .foregroundColor(.appWhite)
                                        
                    WorkoutPriceView(isFree: true, showBackground: false)
                }
                
                Spacer()
                
                Text("Fat Burner")
                    .font(.h2)
                    .foregroundColor(.appWhite)
                    
                
                LevelView(level: 1, showLabel: false)
            }
            .padding(18)
        }
        .frame(width: 150, height: 180)
    }
}

private struct WideCardView: View {
    var body: some View {
        ZStack {
            Image(uiImage: UIImage(namedSharedAsset: "bodyweight-1"))
                .resizable()
                .aspectRatio(contentMode: .fill)
            VStack(alignment: .leading) {
                
                WorkoutPriceView(isFree: true, showBackground: true)
                
                Spacer()
                
                Text("Whole Body Workout")
                    .font(.h2)
                    .foregroundColor(.appWhite)
                
                HStack {
                    LevelView(level: 2, showLabel: true)
                    
                    Spacer()
                    HStack(spacing: 5) {
                        Image(systemName: "clock")
                            .font(.label)
                            .foregroundColor(.appWhite)
                        
                        Text("50 MIN")
                            .font(.label)
                            .tracking(1)
                            .foregroundColor(.appWhite)
                    }
                }
            }
            .padding(18)
        }
        .frame(width: 320, height: 180)
    }
}

private struct LevelView: View {
    
    let level: Int
    let showLabel: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            
            if showLabel {
                Text("LEVEL")
                    .font(.label)
                    .tracking(1)
                    .foregroundColor(.appWhite)
            }
            
            HStack(spacing: 4) {
                Circle()
                    .frame(width: 5, height: 5)
                    .foregroundColor(.appSecondary)
                Circle()
                    .frame(width: 5, height: 5)
                    .foregroundColor(level > 1 ? .appSecondary : .appTextSecondary)
                Circle()
                    .frame(width: 5, height: 5)
                    .foregroundColor(level > 2 ? .appTextSecondary : .appTextSecondary)
            }
        }
    }
}

private struct WorkoutPriceView: View {
    
    let isFree: Bool
    let showBackground: Bool
    
    var body: some View {
        Text(isFree ? "Free" : "Paid")
            .font(.bodySmall)
            .foregroundColor(.appWhite)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(showBackground ?
                Rectangle()
                    .foregroundColor(.appTextSecondary)
                    .cornerRadius(4)
                : nil
            )
    }
}
