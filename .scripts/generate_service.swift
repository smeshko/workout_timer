#!/usr/bin/env swift

import Foundation

enum CommanLineError: Error {
    case missingArgument
    case wrongDirectory
}

let manager = FileManager()
if !manager.changeCurrentDirectoryPath("/Users/ivot/Developer/iOS/TimerWizz") {
    throw CommanLineError.wrongDirectory
}
let currentDirectory = manager.currentDirectoryPath
var prefix: String = CommandLine.arguments[1]

let serviceCode = """
import Foundation
import ServiceRegistry

public class \(prefix)Service: \(prefix)ServiceProtocol {

}
"""

let serviceProtocolCode = """
import Foundation

public protocol \(prefix)ServiceProtocol {

}
"""

let serviceMockCode = """
import Foundation
import TestUtilities
import ServiceRegistry

public class \(prefix)ServiceMock: MockBase, \(prefix)ServiceProtocol {

}
"""

let serviceTestsCode = """
import XCTest
import TestUtilities
@testable import NetworkClient

class NetworkServiceTests: XCTestCase {

    private let service = NetworkService()

    func testHappyPath() async {
        XCTFail()
    }
}
"""

enum Color: String {
    case black = "\u{001B}[0;30m"
    case red = "\u{001B}[0;31m"
    case green = "\u{001B}[0;32m"
    case yellow = "\u{001B}[0;33m"
    case blue = "\u{001B}[0;34m"
    case magenta = "\u{001B}[0;35m"
    case cyan = "\u{001B}[0;36m"
    case white = "\u{001B}[0;37m"
    case `default` = "\u{001B}[0;0m"
}

func createServiceDirectory() throws {
    let sourcesPath = currentDirectory.appending("/Sources")
    let serviceDirPath = sourcesPath.appending("/\(prefix)Client")

    try manager.createDirectory(
        atPath: serviceDirPath,
        withIntermediateDirectories: true,
        attributes: [:]
    )

    print("\(Color.green.rawValue)Created \(prefix)Client at \(serviceDirPath)\n")

    let servicePath = serviceDirPath.appending("/\(prefix)Service.swift")
    let serviceUrl = URL(fileURLWithPath: servicePath)
    try serviceCode.write(to: serviceUrl, atomically: true, encoding: .utf8)

    print("\(Color.green.rawValue)Generated service file!\n")
}

func createServiceTests() throws {
    let sourcesPath = currentDirectory.appending("/Tests")
    let serviceDirPath = sourcesPath.appending("/\(prefix)ClientTests")

    try manager.createDirectory(
        atPath: serviceDirPath,
        withIntermediateDirectories: true,
        attributes: [:]
    )

    let servicePath = serviceDirPath.appending("/\(prefix)ServiceTests.swift")
    let serviceUrl = URL(fileURLWithPath: servicePath)
    try serviceTestsCode.write(to: serviceUrl, atomically: true, encoding: .utf8)

    print("\(Color.green.rawValue)Generated service tests file!\n")
}

func createServiceMock() throws {
    let mocksDirectoryPath = currentDirectory.appending("/Sources/TestMocks")

    try manager.createDirectory(
        atPath: mocksDirectoryPath,
        withIntermediateDirectories: true,
        attributes: [:]
    )

    let mocksPath = mocksDirectoryPath.appending("/\(prefix)ServiceMock.swift")
    let mocksUrl = URL(fileURLWithPath: mocksPath)
    try serviceCode.write(to: mocksUrl, atomically: true, encoding: .utf8)

    print("\(Color.green.rawValue)Generated service mock file!\n")
}

func createServiceProtocol() throws {
    let protocolsDirectoryPath = currentDirectory.appending("/Sources/ServiceRegistry/Services")

    try manager.createDirectory(
        atPath: protocolsDirectoryPath,
        withIntermediateDirectories: true,
        attributes: [:]
    )

    let protocolsPath = protocolsDirectoryPath.appending("/\(prefix)ServiceProtocol.swift")
    let protocolsUrl = URL(fileURLWithPath: protocolsPath)
    try serviceProtocolCode.write(to: protocolsUrl, atomically: true, encoding: .utf8)

    print("\(Color.green.rawValue)Generated service protocol file!\n")
}

func remindToUpdatePackage() {
    print("\(Color.red.rawValue)Don't forget to update the Package.swift file with the following content:\(Color.default.rawValue)\n")
    print("\(Color.yellow.rawValue)In products:\(Color.default.rawValue)")
    print(".library(name: \"\(prefix)Client\", targets: [\"\(prefix)Client\"]),\n")
    print("\(Color.yellow.rawValue)In targets:\(Color.default.rawValue)")
    print(
        """
.target(name: "\(prefix)Client", dependencies: ["ServiceRegistry"]),
.testTarget(name: "\(prefix)ClientTests", dependencies: ["\(prefix)Client", "TestUtilities", "TestMocks"]),
"""
    )
}


do {
    try createServiceDirectory()
    try createServiceTests()
    try createServiceMock()
    try createServiceProtocol()
    remindToUpdatePackage()
} catch {
    print(error)
}
