//
//  InstalledApp.swift
//  AppUninstaller
//
//  Created by David Rosenberg on 8/2/25.
//

import Foundation
import SwiftUI

struct InstalledApp: Comparable, Hashable, Identifiable {
    let id = UUID()
    let name: String
    let bundleID: String
    let version: String?
    let path: String
    var icon: NSImage?
    var publisher: String?
    var isAppStoreApp = false
    var isLocked = false
    
    var isSystemApp: Bool {
        path.hasPrefix("/System/")
    }
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedSame
    }
    
    #if DEBUG
        static let systemSettings = InstalledApp(
            name: "System Settings",
            bundleID: "com.apple.systempreferences",
            version: "15.0",
            path: "/System/Applications/System Settings.app",
            publisher: "Apple",
        )
    #endif
}
