//
//  ContentView+ViewModel.swift
//  AppUninstaller
//
//  Created by David Rosenberg on 9/8/25.
//

import Foundation
import Observation

extension ContentView {
    @MainActor
    @Observable
    final class ViewModel {
        let appManager = InstalledAppsStore()
        var selectedApp: InstalledApp? = nil
        var showingUninstallConfirmation = false
        var uninstallSuccess = false
        var searchTerm = ""
    }
}

