import Foundation

public protocol EndpointProtocol {
    var path: String { get }
    var url: URL? { get }
    var method: HTTPMethod { get }
    var host: String { get }
    var body: Data? { get }
}

public enum HTTPMethod: String {
    case get = "GET"
}

/// An enum used to route the different types of requests.
public enum Endpoint: EndpointProtocol {
    case categories
    case workouts
    
    public var path: String {
        switch self {
        case .categories: return "/api/categories/public"
        case .workouts: return "/api/workouts"
        }
    }
    
    public var url: URL? {
        UrlBuilder(endpoint: self)
            .components()
            .queryItems()
            .build()
    }
    
    public var method: HTTPMethod {
        .get
    }
    
    public var host: String {
        "itsonev-workout-timer-staging.herokuapp.com"
    }

    public var body: Data? {
        nil
    }
}

/// A helper builder to construct the full api endpoint given a type of request.
private class UrlBuilder {
    private var endpoint: Endpoint
    private var urlComponents = URLComponents()
    
    init(endpoint: Endpoint) {
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
        urlComponents.queryItems = []
        return self
    }
    
    /// The full url for the requested endpoint.
    func build() -> URL? {
        return urlComponents.url
    }
}
