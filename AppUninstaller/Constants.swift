//
//  Constants.swift
//  AppUninstaller
//
//  Created by David Rosenberg on 9/8/25.
//

import Foundation

let applicationFolders = [
    URL(fileURLWithPath: "/Applications"),
    URL(fileURLWithPath: "/System/Applications"),
]

enum ManagedPrefsKeys {
    static let lockedBundleIDs = "lockedBundleIDs"
}
