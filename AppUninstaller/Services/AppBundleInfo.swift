//
//  Utils.swift
//  AppInfoProvider
//
//  Created by David Rosenberg on 9/15/25.
//

import AppKit
import CoreServices
import Foundation
import Subprocess

struct AppBundleInfo {
    let url: URL
    private let bundle: Bundle
    
    init?(url: URL) {
        guard let bundle = Bundle(url: url) else { return nil }
        self.url = url
        self.bundle = bundle
    }
    
    // MARK: - Computed properties
    var name: String { url.deletingPathExtension().lastPathComponent }
    var bundleID: String? { bundle.bundleIdentifier }
    var version: String? { bundle.infoDictionary?["CFBundleShortVersionString"] as? String }
    var icon: NSImage? { NSWorkspace.shared.icon(forFile: url.path) }
    
    // MARK: - Loading functions
    public func loadAppStoreID() async -> Int? {
        guard let item = MDItemCreateWithURL(kCFAllocatorDefault, url as CFURL),
              let value = MDItemCopyAttribute(item, "kMDItemAppStoreAdamID" as CFString)
        else {
            return nil
        }
        
        switch value {
            case let value as NSNumber:
                return value.intValue
            case let value as String:
                return Int(value) ?? nil
            default:
                return nil
        }
    }
    
    public func loadCodeSignature() async -> String? {
        let result = try? await run(
            .path("/usr/bin/codesign"),
            arguments: ["-dvv", url.path(percentEncoded: false)],
            output: .discarded,
            error: .string(limit: 4096)
        )
        
        return result?.standardError
    }
}
