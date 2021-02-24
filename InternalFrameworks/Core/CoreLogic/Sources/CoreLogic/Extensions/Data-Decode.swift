import Foundation
import ComposableArchitecture

extension Data {
    func decode<T: Decodable>() -> Effect<T, NetworkError> {
        let decoder = JSONDecoder()
        
        return Effect<Data, NetworkError>(value: self)
            .decode(type: T.self, decoder: decoder)
            .mapError { _ in NetworkError.parsingFailed }
            .eraseToEffect()
    }
}
