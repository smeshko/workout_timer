import Foundation
@testable import NetworkClient

public class NetworkSessionMock: NetworkSession {
    public var response: URLResponse = .init()
    public var data: Data = .init()
    public var shouldError: Bool = false

    public init() {}

    public func response(for url: URL) async throws -> (Data, URLResponse) {
        if shouldError {
            throw NetworkError.incorrectResponse
        } else {
            return (data, response)
        }
    }

    public func response(for request: URLRequest) async throws -> (Data, URLResponse) {
        if shouldError {
            throw NetworkError.incorrectResponse
        } else {
            return (data, response)
        }
    }
}
