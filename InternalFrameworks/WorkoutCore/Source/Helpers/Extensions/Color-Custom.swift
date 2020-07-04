import SwiftUI

extension Color {
    private static let bundle = Bundle(identifier: "com.tsonevInc.mobile.ios.WorkoutCore")
    
    public static let brand1: Color = Color("brand1", bundle: bundle)
    public static let brand2: Color = Color("brand2", bundle: bundle)
    public static let brand3: Color = Color("brand3", bundle: bundle)
    public static let brand4: Color = Color("brand4", bundle: bundle)
    public static let brand5: Color = Color("brand5", bundle: bundle)
    
    public static let primary: Color = Color("brand1", bundle: bundle)
    public static let secondary: Color = Color("brand2", bundle: bundle)
    public static let background: Color = Color("brand3", bundle: bundle)
    public static let success: Color = Color("brand4", bundle: bundle)
    public static let error: Color = Color("brand5", bundle: bundle)
    public static let textPrimary: Color = Color("brand1", bundle: bundle)
    public static let textSecondary: Color = Color("brand2", bundle: bundle)
}
