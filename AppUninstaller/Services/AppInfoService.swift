//
//  Utils.swift
//  AppInfoProvider
//
//  Created by David Rosenberg on 9/15/25.
//

import Foundation
import Subprocess
import SwiftUI

class AppInfoService {
    public let path: URL
    private let bundle: Bundle
    
    public init?(path: URL) {
        guard let bundle = Bundle(url: path) else {
            return nil
        }
        self.path = path
        self.bundle = bundle
    }
    
    // MARK: generated values
    public var name: String {
        path.deletingPathExtension().lastPathComponent
    }
    
    public var bundleID: String? {
        bundle.bundleIdentifier
    }
    
    public var version: String? {
        bundle.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    public var icon: NSImage? {
        NSWorkspace.shared.icon(forFile: path.path)
    }
    
    // MARK: getter functions
    public func getAppStoreID() async -> Int? {
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
    
    public func getCodeSignature() async -> String? {
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
