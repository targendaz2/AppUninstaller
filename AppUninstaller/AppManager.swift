//
//  AppManager.swift
//  AppUninstaller
//
//  Created by David Rosenberg on 9/8/25.
//

import AppInfoProvider
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

        let processedApp = InstalledApp(
            name: app.name,
            bundleID: app.bundleID,
            version: app.version,
            path: app.path.path(),
            icon: app.icon,
            publisher: getAppPublisher(for: app),
            isAppStoreApp: app.appStoreID != nil,
            isLocked: self.lockedBundleIDs.contains(app.bundleID),
        )
        return processedApp
    }

    func canUninstall(app: InstalledApp) -> Bool {
        !app.isLocked && !app.isSystemApp
    }
}

// MARK: - app publisher retrieval
extension AppManager {
    private func getAppPublisher(for app: MacOSApp) -> String? {
        if let appStoreID = app.appStoreID {
            return getAppPublisher(appStoreID: appStoreID)
        } else if let codeSignature = app.codeSignature {
            return getAppPublisher(codeSignature: codeSignature)
        }
        return nil
    }

    private func getAppPublisher(appStoreID: Int) -> String? {
        guard let apiURL = URL(string: "https://itunes.apple.com/lookup?id=\(appStoreID)") else {
            print("Invalid URL for App Store ID \(appStoreID)")
            return nil
        }

        let semaphore = DispatchSemaphore(value: 0)
        var publisherName: String?
        var requestError: Error?

        let task = URLSession.shared.dataTask(with: apiURL) { data, response, error in
            requestError = error
            guard let data = data else {
                print("No data received for App Store ID \(appStoreID)")
                semaphore.signal()
                return
            }

            if let json = try? JSONSerialization.jsonObject(with: data, options: [])
                as? [String: Any],
                let results = json["results"] as? [[String: Any]],
                let name = results.first?["artistName"] as? String
            {
                publisherName = name
            } else {
                print("Could not parse publisher from JSON for App Store ID \(appStoreID)")
            }
            semaphore.signal()
        }

        task.resume()
        _ = semaphore.wait(timeout: .now() + 10.0)

        if let error = requestError {
            print("Network request failed: \(error.localizedDescription)")
            return nil
        }
        return publisherName
    }

    private func getAppPublisher(codeSignature: String) -> String? {
        let lines = codeSignature.components(separatedBy: .newlines)
        for line in lines {
            if line.trimmingCharacters(in: .whitespaces).hasPrefix("Authority=") {
                let parts = line.split(separator: "=", maxSplits: 1)
                if parts.count > 1 {
                    let authority = String(parts[1]).trimmingCharacters(in: .whitespaces)
                    if let range = authority.range(of: "Developer ID Applications: ") {
                        let subString = authority[range.upperBound...]
                        if let parenRange = subString.range(of: " (") {
                            let developerName = subString[..<parenRange.lowerBound]
                            return String(developerName)
                        }
                    } else if let parenRange = authority.range(of: " (") {
                        let developerName = authority[..<parenRange.lowerBound]
                        return String(developerName)
                    }

                    if authority == "Software Signing" {
                        return "Apple"
                    }
                    return authority
                }
            }
        }
        return nil
    }
}
