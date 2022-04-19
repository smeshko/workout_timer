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


let viewCode = """
import SwiftUI

struct \(prefix)View<Coordinator: \(prefix)CoordinatorProtocol, ViewModel: \(prefix)ViewModelProtocol>: View where Coordinator.Route == Route {

    @ObservedObject private var viewModel: ViewModel
    private let coordinator: Coordinator

    init(viewModel: ViewModel, coordinator: Coordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
    }

    var body: some View {
        Text("Hello, \(prefix)")
    }
}
"""

let viewModelCode = """
import Foundation
import SwiftUI

protocol \(prefix)ViewModelProtocol: ObservableObject {
    var route: Route? { get set }
}

class \(prefix)ViewModel: \(prefix)ViewModelProtocol {
    private let service: \(prefix)ServiceProtocol

    @Published var route: Route?

    init(service: \(prefix)ServiceProtocol) {
        self.service = service
    }
}
"""

let coordinatorCode = """
import Foundation
import SwiftUI
import ServiceRegistry

protocol \(prefix)CoordinatorProtocol: Coordinator {}

enum Route: String, Identifiable {
    case destination

    var id: String { rawValue }
}

struct \(prefix)Coordinator: \(prefix)CoordinatorProtocol {

    private let services: ServiceRegistryProtocol

    init(services: ServiceRegistryProtocol) {
        self.services = services
    }

    func destination(for route: Route) -> some View {
        EmptyView()
    }
}
"""

let serviceCode = """
import Foundation

protocol \(prefix)ServiceProtocol {}

class \(prefix)Service: \(prefix)ServiceProtocol {}
"""

let moduleCode = """
import Foundation
import SwiftUI
import ServiceRegistry

public struct \(prefix)Module: Module {

    public var services: ServiceRegistryProtocol

    public init(services: ServiceRegistryProtocol) {
        self.services = services
    }

    public func createView() -> some View {
        let service = \(prefix)Service()
        let coordinator = \(prefix)Coordinator(services: services)
        let viewModel = \(prefix)ViewModel(service: service)
        return \(prefix)View(viewModel: viewModel, coordinator: coordinator)
    }
}
"""

let serviceTestsCode = """
import Foundation
import XCTest
import TestMocks
import TestUtilities
@testable import \(prefix)Feature

class \(prefix)ServiceTests: XCTestCase {
    private var service: \(prefix)Service!

    override func setUp() {
        super.setUp()
        service = \(prefix)Service()
    }
}
"""

let serviceMockCode = """
import Foundation
import TestUtilities
@testable import \(prefix)Feature

class \(prefix)ServiceMock: MockBase, \(prefix)ServiceProtocol {}
"""

let coordinatorMockCode = """
import Foundation
import TestUtilities
@testable import \(prefix)Feature
import SwiftUI

enum MockRoute: String, Identifiable {
    case test

    var id: String { rawValue }
}

class \(prefix)CoordinatorMock: MockBase, \(prefix)CoordinatorProtocol {
    func destination(for route: MockRoute) -> some View {
        EmptyView()
    }
}
"""

let viewModelTestsCode = """
import Foundation
import XCTest
import TestMocks
import TestUtilities
@testable import \(prefix)Feature

class \(prefix)ViewModelTests: XCTestCase {
    private var viewModel: \(prefix)ViewModel!
    private var service: \(prefix)ServiceMock!

    override func setUp() {
        super.setUp()
        service = \(prefix)ServiceMock()
        viewModel = \(prefix)ViewModel(service: service)
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


func createFeatureDirectory() throws {
    let sourcesPath = currentDirectory.appending("/Sources")
    let featureDirPath = sourcesPath.appending("/\(prefix)Feature")

    try manager.createDirectory(
        atPath: featureDirPath,
        withIntermediateDirectories: true,
        attributes: [:]
    )

    print("\(Color.green.rawValue)Created \(prefix)Feature at \(featureDirPath)")

    let viewPath = featureDirPath.appending("/\(prefix)View.swift")
    let viewUrl = URL(fileURLWithPath: viewPath)
    try viewCode.write(to: viewUrl, atomically: true, encoding: .utf8)

    let coordinatorPath = featureDirPath.appending("/\(prefix)Coordinator.swift")
    let coordinatorUrl = URL(fileURLWithPath: coordinatorPath)
    try coordinatorCode.write(to: coordinatorUrl, atomically: true, encoding: .utf8)

    let modulePath = featureDirPath.appending("/\(prefix)Module.swift")
    let moduleUrl = URL(fileURLWithPath: modulePath)
    try moduleCode.write(to: moduleUrl, atomically: true, encoding: .utf8)

    let viewModelPath = featureDirPath.appending("/\(prefix)ViewModel.swift")
    let viewModelUrl = URL(fileURLWithPath: viewModelPath)
    try viewModelCode.write(to: viewModelUrl, atomically: true, encoding: .utf8)

    let servicePath = featureDirPath.appending("/\(prefix)Service.swift")
    let serviceUrl = URL(fileURLWithPath: servicePath)
    try serviceCode.write(to: serviceUrl, atomically: true, encoding: .utf8)

    print("\(Color.green.rawValue)Generated view, view model and service files!\n")
}

func createTestDirectory() throws {
    let testsPath = currentDirectory.appending("/Tests")
    let testsDirPath = testsPath.appending("/\(prefix)FeatureTests")
    let mocksDirPath = testsDirPath.appending("/Mocks")

    try manager.createDirectory(
        atPath: testsDirPath,
        withIntermediateDirectories: true,
        attributes: [:]
    )

    try manager.createDirectory(
        atPath: mocksDirPath,
        withIntermediateDirectories: true,
        attributes: [:]
    )

    print("\(Color.green.rawValue)Created \(prefix)FeatureTests at \(testsDirPath)")

    let viewModelTestsPath = testsDirPath.appending("/\(prefix)ViewModelTests.swift")
    let viewModelTestsUrl = URL(fileURLWithPath: viewModelTestsPath)
    try viewModelTestsCode.write(to: viewModelTestsUrl, atomically: true, encoding: .utf8)

    let serviceTestsPath = testsDirPath.appending("/\(prefix)ServiceTests.swift")
    let serviceTestsUrl = URL(fileURLWithPath: serviceTestsPath)
    try serviceTestsCode.write(to: serviceTestsUrl, atomically: true, encoding: .utf8)

    let serviceMockPath = mocksDirPath.appending("/\(prefix)ServiceMock.swift")
    let serviceMockUrl = URL(fileURLWithPath: serviceMockPath)
    try serviceMockCode.write(to: serviceMockUrl, atomically: true, encoding: .utf8)

    let coordinatorMockPath = mocksDirPath.appending("/\(prefix)CoordinatorMock.swift")
    let coordinatorMockUrl = URL(fileURLWithPath: coordinatorMockPath)
    try coordinatorMockCode.write(to: coordinatorMockUrl, atomically: true, encoding: .utf8)

    print("\(Color.green.rawValue)Generated view model and service tests!\n")
}


func remindToUpdatePackage() {
    print("\(Color.red.rawValue)Don't forget to update the Package.swift file with the following content:\(Color.default.rawValue)\n")
    print("\(Color.yellow.rawValue)In products:\(Color.default.rawValue)")
    print(".library(name: \"\(prefix)Feature\", targets: [\"\(prefix)Feature\"]),\n")
    print("\(Color.yellow.rawValue)In targets:\(Color.default.rawValue)")
    print(
        """
.target(name: "\(prefix)Feature", dependencies: ["ServiceRegistry"]),
.testTarget(name: "\(prefix)FeatureTests", dependencies: ["\(prefix)Feature", "TestUtilities", "TestMocks"]),
"""
    )
}



do {
    try createFeatureDirectory()
    try createTestDirectory()
    remindToUpdatePackage()
} catch {
    print(error)
}
