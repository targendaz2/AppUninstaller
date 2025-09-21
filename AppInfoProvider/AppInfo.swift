//
//  Utils.swift
//  AppInfoProvider
//
//  Created by David Rosenberg on 9/15/25.
//

import Foundation
import Subprocess
import SwiftUI

func getAppName(for path: URL) -> String {
    path.deletingPathExtension().lastPathComponent
}

func getAppVersion(for bundle: Bundle) -> String? {
    bundle.infoDictionary?["CFBundleShortVersionString"] as? String
}

func getAppIcon(for path: URL) -> NSImage? {
    NSWorkspace.shared.icon(forFile: path.path)
}

func getAppStoreID(for path: URL) async -> Int? {
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

func getCodeSignature(for path: URL) async -> String? {
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
