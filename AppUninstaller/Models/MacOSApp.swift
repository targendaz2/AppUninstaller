//
//  MacOSApp.swift
//  AppUninstaller
//
//  Created by David Rosenberg on 9/6/25.
//

import Foundation
import SwiftUI

final class MacOSApp {
    let path: URL
    let bundleID: String
    let name: String
    let version: String?
    let icon: NSImage?
    let appStoreID: Int?
    let codeSignature: String?

    convenience init?(path: String) async {
        await self.init(path: URL(fileURLWithPath: path))
    }

    convenience init?(bundleID: String) async {
        guard let path = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
            return nil
        }
        await self.init(path: path)
    }

    init?(path: URL) async {
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
