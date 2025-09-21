//
//  AppPublisherService.swift
//  AppUninstaller
//
//  Created by Assistant on 9/21/25.
//

import Foundation

/// Provides a human-readable publisher (developer/vendor) name for an app.
protocol AppPublisherService {
    /// Returns a publisher name for the given app if one can be determined.
    func publisherName(for app: MacOSApp) async -> String?
}

/// Facade that tries App Store metadata first, then code signature.
struct DefaultAppPublisherService: AppPublisherService {
    var appStore: AppStorePublisherService
    var codeSignature: CodeSignaturePublisherService

    init(
        appStore: AppStorePublisherService = DefaultAppStorePublisherService(),
        codeSignature: CodeSignaturePublisherService = DefaultCodeSignaturePublisherService()
    ) {
        self.appStore = appStore
        self.codeSignature = codeSignature
    }

    func publisherName(for app: MacOSApp) async -> String? {
        if let appStoreID = app.appStoreID {
            if let name = await appStore.publisherName(forAppStoreID: appStoreID) {
                return name
            }
        }
        if let signature = app.codeSignature {
            return codeSignature.publisherName(fromCodeSignature: signature)
        }
        return nil
    }
}

// MARK: - App Store
protocol AppStorePublisherService {
    func publisherName(forAppStoreID id: Int) async -> String?
}

struct DefaultAppStorePublisherService: AppStorePublisherService {
    func publisherName(forAppStoreID id: Int) async -> String? {
        // TODO: Move URLSession lookup logic from AppManager.getAppPublisher(appStoreID:)
        // For now, return nil to allow incremental adoption.
        return nil
    }
}

// MARK: - Code Signature
protocol CodeSignaturePublisherService {
    func publisherName(fromCodeSignature signature: String) -> String?
}

struct DefaultCodeSignaturePublisherService: CodeSignaturePublisherService {
    func publisherName(fromCodeSignature signature: String) -> String? {
        // TODO: Move Authority parsing logic from AppManager.getAppPublisher(codeSignature:)
        // For now, return nil to allow incremental adoption.
        return nil
    }
}
