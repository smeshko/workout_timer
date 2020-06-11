import ComposableArchitecture
import Combine
import Foundation

public enum NetworkError: Error {
    case wrongUrl
    case failedConnection
    case incorrectResponse
    case requestFailed
    case parsingFailed
}

public struct WebClient {
    
    public func getImageData(at key: String) -> Effect<Data, NetworkError> {
        guard let url = Endpoint.image(key).url else {
            return Effect<Data, NetworkError>.init(error: NetworkError.wrongUrl)
        }
        
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .map {
                $0.data
            }
            .mapError { _ in NetworkError.failedConnection }
            .eraseToEffect()
    }
    
    public func sendRequest<T>(to endpoint: EndpointProtocol) -> Effect<T, NetworkError> where T : Decodable {
        guard !isMocked else {
            print(endpoint.url?.absoluteString ?? "")
            return .none
        }
        
        guard let url = endpoint.url else {
            return Effect<T, NetworkError>.init(error: NetworkError.wrongUrl)
        }
        
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .mapError { _ in NetworkError.failedConnection }
            .flatMap { data, _ -> Effect<T, NetworkError> in
                data.decode()
            }
        .eraseToEffect()

    }
    
    private let isMocked: Bool
    
    public static let live = WebClient(isMocked: false)
    public static let mock = WebClient(isMocked: true)
    
    private init(isMocked: Bool) {
        self.isMocked = isMocked
    }
}
