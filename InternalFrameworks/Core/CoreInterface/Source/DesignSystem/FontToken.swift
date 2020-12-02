import SwiftUI

extension Font {
    /// 30 bold
    public static let h1 = Font.system(size: 30, weight: .bold)
    /// 30 bold mono
    public static let h1Mono = Font.system(size: 30, weight: .bold, design: .monospaced)
    /// 22 bold
    public static let h2 = Font.system(size: 22, weight: .bold)
    /// 16 bold
    public static let h3 = Font.system(size: 16, weight: .bold)
    /// 14 bold
    public static let h4 = Font.system(size: 14, weight: .bold)
    /// 14 medium
    public static let display = Font.system(size: 14, weight: .medium)
    /// 14 regular
    public static let bodyLarge = Font.system(size: 14, weight: .regular)
    /// 12 regular
    public static let bodySmall = Font.system(size: 12, weight: .regular)
    /// 12 bold
    public static let label = Font.system(size: 12, weight: .bold)
    /// 54 bold
    public static let gigantic = Font.system(size: 54, weight: .bold)
    /// 54 bold mono
    public static let giganticMono = Font.system(size: 54, weight: .bold, design: .monospaced)
    /// 72 heavy mono
    public static let timer = Font.system(size: 72, weight: .heavy, design: .monospaced)
}
