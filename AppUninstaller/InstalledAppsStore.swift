//
//  AppManager.swift
//  AppUninstaller
//
//  Created by David Rosenberg on 9/8/25.
//

import Foundation

@MainActor
@Observable
class InstalledAppsStore {
    let discoveryService: AppDiscoveryService
    let publisherService: AppPublisherService
    var installedApps: [InstalledApp] = []

    init(
        discoveryService: AppDiscoveryService = DefaultAppDiscoveryService(),
        publisherService: AppPublisherService = AppPublisherService()
    ) {
        self.discoveryService = discoveryService
        self.publisherService = publisherService
    }

    var lockedBundleIDs: [String] {
        let bundleIDsFromPrefs = UserDefaults.standard.array(
            forKey: ManagedPrefsKeys.lockedBundleIDs
        )
        return bundleIDsFromPrefs as? [String] ?? []
    }

    func getInstalledApps() async {
        // Capture values up front to avoid MainActor hops inside child tasks
        let locked = self.lockedBundleIDs
        let folders = applicationFolders

        // Discover and process apps off the main actor
        let appsArrays: [[InstalledApp]] = await withTaskGroup(of: [InstalledApp].self) { group in
            for folder in folders {
                group.addTask {
                    var results: [InstalledApp] = []
                    let fileManager = FileManager.default

                    let appURLs =
                        (try? fileManager.contentsOfDirectory(
                            at: folder,
                            includingPropertiesForKeys: nil,
                            options: [.skipsHiddenFiles]
                        )) ?? []

                    for appURL in appURLs where appURL.pathExtension == "app" {
                        if let app = await self.processApp(
                            at: appURL,
                            lockedBundleIDs: locked
                        ) {
                            results.append(app)
                        }
                    }

                    return results
                }
            }

            var collected: [[InstalledApp]] = []
            for await partial in group {
                collected.append(partial)
            }
            return collected
        }

        // Flatten, sort, and assign on the MainActor
        let apps = appsArrays.flatMap { $0 }.sorted()
        self.installedApps = apps
    }

    private func processApp(at appURL: URL, lockedBundleIDs: [String]) async -> InstalledApp?
    {
        guard let app = await MacOSApp(path: appURL) else {
            return nil
        }

        let publisher = await publisherService.publisherName(for: app)

        let processedApp = InstalledApp(
            name: app.name,
            bundleID: app.bundleID,
            version: app.version,
            url: app.path,
            icon: app.icon,
            publisher: publisher,
            isAppStoreApp: app.appStoreID != nil,
            isLocked: lockedBundleIDs.contains(app.bundleID)
        )
        return processedApp
    }

    func canUninstall(app: InstalledApp) -> Bool {
        !app.isLocked && !app.isSystemApp
    }
}
