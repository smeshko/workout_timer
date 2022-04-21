import Foundation
import TestUtilities
import ServiceRegistry
@testable import NetworkClient

public class NetworkServiceMock<T: Decodable>: MockBase, NetworkServiceProtocol {
    public var error: NetworkError?
    public var returnObject: T?
    public var returnData: Data?

    public func sendRequest<T>(to endpoint: EndpointProtocol, allowRetry: Bool) async throws -> T where T : Decodable {
        track()
        if let error = error {
            throw error
        } else if let object = returnObject {
            return object as! T
        } else {
            fatalError()
        }
    }

    public func fetchData(at endpoint: EndpointProtocol, allowRetry: Bool) async throws -> Data {
        track()
        if let error = error {
            throw error
        } else if let data = returnData {
            return data
        } else {
            fatalError()
        }
    }
}
