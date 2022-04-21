import Foundation
import ServiceRegistry
import OrderedCollections

public class EndpointMock: EndpointProtocol {
    public init() {}

    public var path: String = ""
    public var method: HTTPMethod = .get
    public var host: String = ""
    public var body: Data? = nil
    public var headers: [String : String] = ["header" : "value"]
    public var postfix: String? = nil
    public var queryParameters: OrderedDictionary<String, String>? = nil
    public var percentEncodedQueryParameters: OrderedDictionary<String, String>? = nil
    public var url: URL? = URL(string: "example.com")
}
