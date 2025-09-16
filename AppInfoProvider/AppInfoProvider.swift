//
//  AppInfoProvider.swift
//  AppInfoProvider
//
//  Created by David Rosenberg on 9/6/25.
//

import Foundation
import Subprocess
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
    public convenience init?(path: String) async {
        await self.init(path: URL(fileURLWithPath: path))
    }

    public convenience init?(bundleID: String) async {
        guard let path = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
            return nil
        }
        await self.init(path: path)
    }

    public init?(path: URL) async {
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
        self.appStoreID = await Self.getAppStoreID(for: path)
        self.codeSignature = await Self.getCodeSignature(for: path)
    }

    // MARK: complex property getters

    private static func getAppStoreID(for path: URL) async -> Int? {
        let result = try? await run(
            .path("/usr/bin/mdls"),
            arguments: ["--name", "kMDItemAppStoreAdamID", path.path],
            output: .string(limit: 4096)
        )

        guard let components = result?.standardOutput?.components(separatedBy: "=") else {
            return nil
        }

        if components.count > 1 {
            let idString = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
            return Int(idString)
        }

        return nil
    }

    private static func getCodeSignature(for path: URL) async -> String? {
        guard let decodedPath = path.path().removingPercentEncoding else {
            return nil
        }

        let result = try? await run(
            .path("/usr/bin/codesign"),
            arguments: ["-dvv", decodedPath],
            output: .discarded,
            error: .string(limit: 4096)
        )

        return result?.standardError
    }
}
