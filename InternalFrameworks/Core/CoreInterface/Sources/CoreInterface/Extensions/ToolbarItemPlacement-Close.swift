import SwiftUI

public extension ToolbarItemPlacement {
    static var close: ToolbarItemPlacement {
        #if os(iOS)
        return .navigationBarTrailing
        #else
        return .automatic
        #endif
    }
}
