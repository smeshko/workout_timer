import Foundation

public struct Token: Codable, Equatable {
    let value: String
    let expirationDate: Date
    let id: UUID

    var isValid: Bool {
        expirationDate > Date()
    }

    public init(remoteToken: RemoteToken) {
        self.init(
            value: remoteToken.accessToken,
            expirationDate: Date() + TimeInterval(remoteToken.expiresIn),
            id: UUID()
        )
    }

    init(value: String, expirationDate: Date, id: UUID) {
        self.value = value
        self.expirationDate = expirationDate
        self.id = id
    }

    public func encode() -> Data? {
        try? JSONEncoder().encode(self)
    }

    static func decode(_ data: Data) -> Token? {
        try? JSONDecoder().decode(Token.self, from: data)
    }
}
