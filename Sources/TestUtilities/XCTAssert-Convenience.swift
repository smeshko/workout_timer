import XCTest

public func XCTSucceed() {
    XCTAssertTrue(true)
}

public func XCTAssertFunctionCalled(_ base: MockBase, _ function: String) {
    if base.functions.contains(function) {
        XCTSucceed()
    } else {
        XCTFail("expected function \(function) to be called, but got \(base.functions)")
    }
}

public func XCTAssertFunctionsCalled(_ base: MockBase, _ functions: [String]) {
    if base.functions.allSatisfy(functions.contains) {
        XCTSucceed()
    } else {
        XCTFail("expected functions \(functions.joined(separator: ", ")) to be called, but got \(base.functions)")
    }
}
