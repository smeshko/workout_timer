import Foundation

public struct RemoteToken: Codable {
    let accessToken: String
    let expiresIn: Int

    public let refreshToken: String?
    let refreshTokenExpiresIn: Int?

    let tokenType: String
    let scope: String

    public static var decoder: JSONDecoder {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }
}
