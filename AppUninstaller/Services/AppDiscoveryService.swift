//
//  AppDiscoveryService.swift
//  AppUninstaller
//
//  Created by David Rosenberg on 9/21/25.
//

import Foundation

/// Discovers installed applications on the system and returns domain models.
///
/// Implementations should do filesystem scanning and transform results into
/// `InstalledApp` values. Keep heavy I/O off the main actor.
protocol AppDiscoveryService {
    /// Returns a list of discovered apps. Implementations may throw for
    /// filesystem errors.
    func discoverInstalledApps() async throws -> [InstalledApp]
}

/// Default implementation that scans known application folders.
///
/// NOTE: Wire this up in `AppManager` via dependency injection.
struct DefaultAppDiscoveryService: AppDiscoveryService {
    /// The application folders to scan. Inject for testing if needed.
    var applicationFolders: [URL]

    init(applicationFolders: [URL] = DefaultAppDiscoveryService.defaultApplicationFolders) {
        self.applicationFolders = applicationFolders
    }

    func discoverInstalledApps() async throws -> [InstalledApp] {
        // TODO: Move logic from AppManager.getInstalledApps/processApp here.
        // For now, return an empty list so wiring can proceed incrementally.
        return []
    }
}

extension DefaultAppDiscoveryService {
    /// Common macOS application directories.
    static var defaultApplicationFolders: [URL] {
        [
            URL(fileURLWithPath: "/Applications", isDirectory: true),
            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(
                "Applications",
                isDirectory: true
            ),
        ]
    }
}
