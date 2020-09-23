import SwiftUI

extension Color {
    private static let bundle = Bundle(identifier: "com.tsonevInc.mobile.ios.WorkoutCore")

    public static let appDark = Color("dark", bundle: bundle)
    public static let appWhite = Color("white", bundle: bundle)
    public static let appPrimary = Color("primary", bundle: bundle)
    public static let appSecondary = Color("secondary", bundle: bundle)
    public static let appSuccess = Color("success", bundle: bundle)
    public static let appError: Color = Color("error", bundle: bundle)
    public static let appGrey: Color = Color("grey", bundle: bundle)
    public static let appLightGrey: Color = Color("lightGrey", bundle: bundle)

}
