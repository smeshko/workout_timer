import Foundation
import ServiceRegistry

/// A helper builder to construct the full api endpoint given a type of request.
class UrlBuilder {
    private var endpoint: EndpointProtocol
    private var urlComponents = URLComponents()

    init(endpoint: EndpointProtocol) {
        self.endpoint = endpoint
    }

    /// Sets the basic url components, e.g. host, path, scheme
    func components() -> Self {
        urlComponents.scheme = "https"
        urlComponents.host = endpoint.host
        urlComponents.path = endpoint.path

        return self
    }

    func queryItems() -> Self {
        urlComponents.queryItems = endpoint.queryParameters?
            .map { URLQueryItem(name: $0.key, value: $0.value) }
        urlComponents.percentEncodedQueryItems = endpoint.percentEncodedQueryParameters?
            .map { URLQueryItem(name: $0.key, value: $0.value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)) }
            .appending(contentsOf: urlComponents.queryItems)
        return self
    }

    /// The full url for the requested endpoint.
    func build() -> URL? {
        if let postfix = endpoint.postfix, let urlString = urlComponents.url?.absoluteString {
            return URL(string: urlString + postfix)
        }
        return urlComponents.url
    }
}

private extension Array {
    func appending(contentsOf array: [Element]?) -> [Element] {
        var copy = self
        copy.append(contentsOf: array ?? [])
        return copy
    }
}
