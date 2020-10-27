#!/usr/bin/env swift
import Foundation 

let configUrl = getConfigURL()

let shouldShowHelp = CommandLine.arguments.count == 1 || CommandLine.arguments.contains(Constants.helpArgument)
let enableLogging = CommandLine.arguments.contains(Constants.loggingArgument)
let shouldBumpBuildVersion = CommandLine.arguments.contains(Constants.buildArgument)
let shouldBumpMinorVersion = CommandLine.arguments.contains(Constants.minorArgument)
let shouldBumpMajorVersion = CommandLine.arguments.contains(Constants.majorArgument)
let shouldBumpHotfixVersion = CommandLine.arguments.contains(Constants.hotfixArgument)
let shouldBumpMarketingVersion = shouldBumpMinorVersion || shouldBumpMajorVersion || shouldBumpHotfixVersion

if shouldShowHelp {
    showHelp()
} else {
    bumpVersion()
}

func showHelp() {
    print("""
        Arguments: 
        \(Constants.buildArgument): bumps build version
        \(Constants.minorArgument): bumps minor version
        \(Constants.majorArgument): bumps major version
        \(Constants.hotfixArgument): bumps hotfix version
        \(Constants.loggingArgument): enable logging
    """)
}

func getConfigURL() -> URL {
    let currentDir = FileManager.default.currentDirectoryPath
    if enableLogging {
        print("running script from: \(currentDir)")
    }

    let configPath = currentDir + Constants.configPath
    if enableLogging {
        print("config file path: \(configPath)")
    }

    return URL(fileURLWithPath: configPath)
}

func bumpBuildVersion(at url: URL) throws {
    let lines = try getFileLines(at: url)

    guard let build = lines.first, 
          let currentVersionString = build.components(separatedBy: Constants.buildVersionSeparator).last, 
          let currentVersion = Int(currentVersionString) else {
              throw ScriptError.buildCannotBeRead
          }

    let newVersion = currentVersion + 1
    print("Changing build version from \(currentVersion) to \(newVersion)")

    let handle = try FileHandle(forWritingTo: url) 

    guard let newVersionString = (Constants.buildVersionSeparator + "\(newVersion)").data(using: .utf8) else {
        throw ScriptError.newBuildVersionCannotBeBuilt
    }
    
    handle.write(newVersionString)
    handle.closeFile()
}

func bumpMarketingVersion(at url: URL, minor: Bool, major: Bool, hotfix: Bool) throws {
    let lines = try getFileLines(at: url)

    guard let build = lines.first,
          let marketing = lines.last,
          let currentVersionString = marketing.components(separatedBy: Constants.marketingVersionSeparator).last else {
              throw ScriptError.marketingCannotBeRead
          }
    
    let versionNumbers = currentVersionString.split(separator: ".")
    
    guard var majorNumber = Int(versionNumbers[0]), var minorNumber = Int(versionNumbers[1]), var hotfixNumber = Int(versionNumbers[2]) else {
        throw ScriptError.marketingCannotBeRead
    }

    if minor {
        minorNumber += 1
    }
    if major {
        majorNumber += 1
    }
    if hotfix {
        hotfixNumber += 1
    }

    let combinedNewVersion = "\(majorNumber).\(minorNumber).\(hotfixNumber)"
    let newVersionString = (Constants.marketingVersionSeparator + combinedNewVersion)
    let handle = try FileHandle(forWritingTo: url) 

    guard let result = [build, newVersionString].joined(separator: "\n").data(using: .utf8) else {
        throw ScriptError.newMarketingVersionCannotBeBuilt
    }

    print("Changing marketing version from \(currentVersionString) to \(combinedNewVersion)")
    handle.write(result)
    handle.closeFile()
}

func bumpVersion() {
    do {
        if shouldBumpBuildVersion {
            try bumpBuildVersion(at: configUrl)
        }

        if shouldBumpMarketingVersion {
            try bumpMarketingVersion(at: configUrl, minor: shouldBumpMinorVersion, major: shouldBumpMajorVersion, hotfix: shouldBumpHotfixVersion)
        }

        if enableLogging {
            print(try String(contentsOf: configUrl, encoding: .utf8))
        }

    } catch (let error) {
        print(error.localizedDescription)
    }
}

func getFileLines(at url: URL) throws -> [String] {
    let fileContents = try String(contentsOf: url, encoding: .utf8)
    if enableLogging {
        print("config file contents:\n\(fileContents)")
    }
        
    let lines = fileContents.components(separatedBy: .newlines)
    if enableLogging {
        print(lines)
    }
    return lines
}

enum ScriptError: Error {
    case buildCannotBeRead
    case marketingCannotBeRead
    case errorReadingFile
    case newBuildVersionCannotBeBuilt
    case newMarketingVersionCannotBeBuilt
}

struct Constants {
    static let configPath = "/QuickWorkout/Product/Common.xcconfig"

    static let marketingVersionSeparator = "APP_MARKETING_VERSION = "
    static let buildVersionSeparator = "APP_BUILD_NUMBER = "
    
    static let buildArgument = "-b"
    static let minorArgument = "-m"
    static let majorArgument = "-j"
    static let hotfixArgument = "-o"
    static let loggingArgument = "-l"
    static let helpArgument = "-h"
}
