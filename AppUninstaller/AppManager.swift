//
//  AppManager.swift
//  AppUninstaller
//
//  Created by David Rosenberg on 9/8/25.
//

import Foundation

@Observable
class AppManager {
    var installedApps: [InstalledApp] = []

    var lockedBundleIDs: [String] {
        let bundleIDsFromPrefs = UserDefaults.standard.array(
            forKey: ManagedPrefsKeys.lockedBundleIDs
        )
        return bundleIDsFromPrefs as? [String] ?? []
    }

    func getInstalledApps() async throws {
        var apps: [InstalledApp] = []
        let fileManager = FileManager.default

        for folder in applicationFolders {
            let appURLs = try fileManager.contentsOfDirectory(
                at: folder,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )

            for appURL in appURLs {
                if appURL.pathExtension == "app",
                    let app = await processApp(at: appURL)
                {
                    apps.append(app)
                }
            }
        }

        self.installedApps = apps.sorted()
    }

    private func processApp(at appURL: URL) async -> InstalledApp? {
        guard let app = await MacOSApp(path: appURL) else {
            return nil
        }
        
        let publisherService = AppPublisherService()

        let processedApp = InstalledApp(
            name: app.name,
            bundleID: app.bundleID,
            version: app.version,
            path: app.path.path(),
            icon: app.icon,
            publisher: await publisherService.publisherName(for: app),
            isAppStoreApp: app.appStoreID != nil,
            isLocked: self.lockedBundleIDs.contains(app.bundleID),
        )
        return processedApp
    }

    func canUninstall(app: InstalledApp) -> Bool {
        !app.isLocked && !app.isSystemApp
    }
}
