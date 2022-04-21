import Foundation
import XCTest
import TestMocks
@testable import NetworkClient

class NetworkServiceTests: XCTestCase {
    private var session: NetworkSessionMock!
    private var service: NetworkService!

    override func setUp() {
        super.setUp()

        session = NetworkSessionMock()
        service = NetworkService(session: session)
    }

    func testSendingRequest_shouldSucceed() async throws {
        let expected = "hello"
        let data = try! JSONEncoder().encode(expected)
        session.data = data

        let result: String = try await service.sendRequest(to: EndpointMock(), allowRetry: false)
        XCTAssertEqual(result, expected)
    }

    func testSendingFailingRequest_shouldFail() async throws {
        session.shouldError = true

        do {
            let _: String = try await service.sendRequest(to: EndpointMock(), allowRetry: false)
        } catch {
            XCTAssertTrue(true)
        }
    }
}
