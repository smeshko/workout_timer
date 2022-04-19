import Foundation
import XCTest

open class MockBase {
    private(set) public var functions: [String] = []

    public init() {}

    public func clearCalledFunctions() {
        functions = []
    }

    public func track(_ function: String = #function) {
        functions.append(function)
    }
}
