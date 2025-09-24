//
//  Utils.swift
//  AppInfoProvider
//
//  Created by David Rosenberg on 9/15/25.
//

import CoreServices
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
        guard let item = MDItemCreateWithURL(kCFAllocatorDefault, path as CFURL),
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
