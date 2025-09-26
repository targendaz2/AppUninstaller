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
        guard let appInfo = AppBundleInfo(url: path),
            let bundleID = appInfo.bundleID
        else {
            return nil
        }

        self.path = path
        self.bundleID = bundleID
        self.name = appInfo.name
        self.version = appInfo.version
        self.icon = appInfo.icon
        self.appStoreID = await appInfo.loadAppStoreID()
        self.codeSignature = await appInfo.loadCodeSignature()
    }
}
