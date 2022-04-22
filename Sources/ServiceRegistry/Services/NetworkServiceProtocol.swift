import Foundation
import OrderedCollections

public enum NetworkError: Error {
    case wrongUrl
    case incorrectResponse
    case invalidToken
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

public protocol EndpointProtocol {
    var path: String { get }
    var url: URL? { get }
    var method: HTTPMethod { get }
    var host: String { get }
    var body: Data? { get }
    var headers: [String: String] { get }
    var postfix: String? { get }
    var queryParameters: OrderedDictionary<String, String>? { get }
    var percentEncodedQueryParameters: OrderedDictionary<String, String>? { get }
}

public protocol NetworkServiceProtocol {
    func sendRequest<T>(to endpoint: EndpointProtocol, allowRetry: Bool) async throws -> T where T : Decodable
    func fetchData(at endpoint: EndpointProtocol, allowRetry: Bool) async throws -> Data
}
