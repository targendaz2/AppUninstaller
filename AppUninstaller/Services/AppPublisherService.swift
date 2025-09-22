//
//  AppPublisherService.swift
//  AppUninstaller
//
//  Created by David Rosenberg on 9/21/25.
//

import Foundation

struct AppPublisherService {
    let appStore = AppStorePublisherService()
    let codeSignature = CodeSignaturePublisherService()
    
    func publisherName(for app: MacOSApp) async -> String? {
        if let appStoreID = app.appStoreID,
           let name = await appStore.publisherName(forAppStoreID: appStoreID) {
            return name
        }
        
        if let signature = app.codeSignature {
            return codeSignature.publisherName(fromCodeSignature: signature)
        }
        return nil
    }
}

// MARK: - App Store
struct AppStorePublisherService {
    func publisherName(forAppStoreID id: Int) async -> String? {
        var urlComponents = URLComponents(string: "https://itunes.apple.com/lookup")!
        urlComponents.queryItems = [
            URLQueryItem(name: "id", value: "\(id)")
        ]
        let apiURL = urlComponents.url!
        
        do {
            let (data, _) = try await URLSession.shared.data(from: apiURL)
            if let json = try? JSONSerialization.jsonObject(with: data, options: [])
                as? [String: Any],
               let results = json["results"] as? [[String: Any]],
               let name = results.first?["artistName"] as? String
            {
                return name
            } else {
                print("Could not parse publisher for App Store ID \(id)")
                return nil
            }
        } catch {
            print("Network request failed: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - Code Signature
struct CodeSignaturePublisherService {
    func publisherName(fromCodeSignature signature: String) -> String? {
        let results = signature
            .components(separatedBy: .newlines)
            .compactMap { line -> String? in
                guard line.trimmingCharacters(in: .whitespaces).hasPrefix("Authority=") else {
                    return nil
                }
                
                let line = line
                    .deletingPrefix("Authority=")
                    .deletingPrefix("Developer ID Application:")
                    .components(separatedBy: "(")[0]
                    .trimmingCharacters(in: .whitespaces)
                
                if line == "Software Signing" {
                    return "Apple"
                }
                return line
            }
        return results.first
    }
}
