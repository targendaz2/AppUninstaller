//
//  AppPublisherService.swift
//  AppUninstaller
//
//  Created by David Rosenberg on 9/21/25.
//

import Alamofire
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
struct AppStorePublisherService {
    private struct AppStoreLookupResponse: Decodable {
        struct AppStoreAppInfo: Decodable {
            let artistName: String
            let sellerName: String
        }

        let resultCount: Int
        let results: [AppStoreAppInfo]
    }
    
    func publisherName(forAppStoreID id: Int) async -> String? {
        let response = await AF.request(
            "https://itunes.apple.com/lookup",
            parameters: ["id": "\(id)"]
        )
        .validate()
        .serializingDecodable(AppStoreLookupResponse.self)
        .response
        
        guard let appInfo = try? response.result.get().results.first else {
            print("Could not retrieve publisher for App Store ID \(id)")
            return nil
        }
        
        return appInfo.sellerName
    }
}

// MARK: - Code Signature
struct CodeSignaturePublisherService {
    func publisherName(fromCodeSignature signature: String) -> String? {
        let results =
            signature
            .components(separatedBy: .newlines)
            .compactMap { line -> String? in
                guard line.trimmingCharacters(in: .whitespaces).hasPrefix("Authority=") else {
                    return nil
                }

                let line =
                    line
                    .deletingPrefix("Authority=")
                    .deletingPrefix("Developer ID Application:")
                    .components(separatedBy: "(")[0]
                    .trimmingCharacters(in: .whitespaces)

                if line == "Software Signing" {
                    return "Apple Inc."
                }
                return line
            }
        return results.first
    }
}
