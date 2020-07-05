import SwiftUI

extension Color {
    private static let bundle = Bundle(identifier: "com.tsonevInc.mobile.ios.WorkoutCore")
    
    public static let brand1: Color = Color("brand1", bundle: bundle)
    public static let brand2: Color = Color("brand2", bundle: bundle)
    public static let brand3: Color = Color("brand3", bundle: bundle)
    public static let brand4: Color = Color("brand4", bundle: bundle)
    public static let brand5: Color = Color("brand5", bundle: bundle)
    
    public static let appPrimary: Color = Color("primary", bundle: bundle)
    public static let appSecondary: Color = Color("secondary", bundle: bundle)
    public static let appBackground: Color = Color("background", bundle: bundle)
    public static let appSuccess: Color = Color("success", bundle: bundle)
    public static let appError: Color = Color("error", bundle: bundle)
    public static let appTextPrimary: Color = Color("textPrimary", bundle: bundle)
    public static let appTextSecondary: Color = Color("textSecondary", bundle: bundle)
    public static let appWhite: Color = Color("white", bundle: bundle)
    public static let appBlack: Color = Color("black", bundle: bundle)

}
