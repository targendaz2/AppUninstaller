//
//  InstalledApp.swift
//  AppUninstaller
//
//  Created by David Rosenberg on 8/2/25.
//

import Foundation
import SwiftUI

struct InstalledApp: Identifiable, Hashable, Comparable {
    let name: String
    let bundleID: String
    let version: String?
    let url: URL
    var icon: NSImage?
    var publisher: String?
    var isAppStoreApp = false
    var isLocked = false
    
    var id: String { bundleID }
    var isSystemApp: Bool { url.path.hasPrefix("/System/") }
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.bundleID == rhs.bundleID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(bundleID)
    }
}

extension InstalledApp {
    #if DEBUG
        static let systemSettings = InstalledApp(
            name: "System Settings",
            bundleID: "com.apple.systempreferences",
            version: "15.0",
            url: URL(string: "/System/Applications/System Settings.app")!,
            publisher: "Apple",
        )
    #endif
}
