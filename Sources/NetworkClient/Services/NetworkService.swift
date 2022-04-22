import Foundation
import ServiceRegistry

public struct NetworkService: NetworkServiceProtocol {

    private let session: NetworkSession

    public init() {
        self.session = URLSession.shared
    }

    init(session: NetworkSession) {
        self.session = session
    }

    public func fetchData(at endpoint: EndpointProtocol, allowRetry: Bool) async throws -> Data {
        guard let request = URLRequest.from(endpoint: endpoint) else {
            throw NetworkError.wrongUrl
        }
        return try await session.response(for: request).0
    }

    public func sendRequest<T>(to endpoint: EndpointProtocol, allowRetry: Bool) async throws -> T where T : Decodable {
        guard let request = URLRequest.from(endpoint: endpoint) else {
            throw NetworkError.wrongUrl
        }
        let (data, _) = try await session.response(for: request)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
