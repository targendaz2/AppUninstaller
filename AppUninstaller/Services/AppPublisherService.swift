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
            let name = await appStore.publisherName(forAppStoreID: appStoreID)
        {
            return name
        }

        if let signature = app.codeSignature {
            return codeSignature.publisherName(fromCodeSignature: signature)
        }
        return nil
    }
}

// MARK: - App Store
actor AppStorePublisherService {
    private struct AppStoreLookupResponse: Decodable {
        struct AppStoreAppInfo: Decodable {
            let artistName: String
            let sellerName: String
        }

        let resultCount: Int
        let results: [AppStoreAppInfo]
    }

    // Simple in-memory cache of App Store ID -> Publisher name
    private var cache: [Int: String] = [:]

    func publisherName(forAppStoreID id: Int) async -> String? {
        // Return cached value if available
        if let cached = cache[id] { return cached }

        var components = URLComponents(string: "https://itunes.apple.com/lookup")
        components?.queryItems = [URLQueryItem(name: "id", value: "\(id)")]
        guard let url = components?.url else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(AppStoreLookupResponse.self, from: data)
            guard let name = response.results.first?.sellerName else {
                return nil
            }
            // Cache and return
            cache[id] = name
            return name
        } catch {
            print("Could not retrieve publisher for App Store ID \(id)")
            return nil
        }
    }
}

// MARK: - Code Signature
struct CodeSignaturePublisherService {
    func publisherName(fromCodeSignature signature: String) -> String? {
        // Match lines like:
        //   Authority=Developer ID Application: Example Corp (ABCDE12345)
        //   Authority=Software Signing
        // Capture the name up to the first parenthesis or end of line
        let pattern = #"^\s*Authority=\s*(?:Developer ID Application:\s*)?([^\(\n]+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines]) else {
            return nil
        }
        let fullRange = NSRange(signature.startIndex..., in: signature)
        guard let match = regex.firstMatch(in: signature, options: [], range: fullRange),
              let nameRange = Range(match.range(at: 1), in: signature) else {
            return nil
        }
        let raw = String(signature[nameRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        if raw == "Software Signing" {
            return "Apple Inc."
        }
        return raw
    }
}
