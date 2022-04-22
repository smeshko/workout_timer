import Foundation
import TestUtilities
import ServiceRegistry

public class SoundServiceMock: MockBase, SoundServiceProtocol {
    public func play(_ sound: Sound) async {
        track()
    }
}
