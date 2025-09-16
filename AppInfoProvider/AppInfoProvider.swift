//
//  AppInfoProvider.swift
//  AppInfoProvider
//
//  Created by David Rosenberg on 9/6/25.
//

import Foundation
import SwiftUI

public class MacOSApp {
    public let path: URL
    public let bundleID: String
    public let name: String
    public let version: String?
    public let icon: NSImage?
    public let appStoreID: Int?
    public let codeSignature: String?
    private let bundle: Bundle

    // MARK: initializers
    public convenience init?(path: String) {
        self.init(path: URL(fileURLWithPath: path))
    }

    public convenience init?(bundleID: String) {
        guard let path = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
            return nil
        }
        self.init(path: path)
    }

    public init?(path: URL) {
        guard let bundle = Bundle(url: path),
            let bundleID = bundle.bundleIdentifier
        else {
            return nil
        }

        self.path = path
        self.bundleID = bundleID
        self.bundle = bundle
        self.name = path.deletingPathExtension().lastPathComponent
        self.version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String
        self.icon = NSWorkspace.shared.icon(forFile: path.path)
        self.appStoreID = Self.getAppStoreID(for: path)
        self.codeSignature = Self.getCodeSignature(for: path)
    }

    // MARK: complex property getters

    private static func getAppStoreID(for path: URL) -> Int? {
        let process = Process()
        process.executableURL = URL(filePath: "/usr/bin/mdls")
        process.arguments = ["--name", "kMDItemAppStoreAdamID", path.path]

        let pipe = Pipe()
        process.standardOutput = pipe

        try? process.run()
        if let data = try? pipe.fileHandleForReading.readToEnd(),
            let output = String(data: data, encoding: .utf8)
        {
            let components = output.components(separatedBy: "=")
            if components.count > 1 {
                let idString = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
                return Int(idString)
            }
        }
        return nil
    }

    private static func getCodeSignature(for path: URL) -> String? {
        guard let decodedPath = path.path().removingPercentEncoding else {
            return nil
        }

        let process = Process()
        process.executableURL = URL(filePath: "/usr/bin/codesign")
        process.arguments = ["-dvv", decodedPath]

        let pipe = Pipe()
        process.standardError = pipe

        try? process.run()
        if let data = try? pipe.fileHandleForReading.readToEnd(),
            let output = String(data: data, encoding: .utf8)
        {
            return output
        }
        return nil
    }
}
