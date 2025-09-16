//
//  ContentView+ViewModel.swift
//  AppUninstaller
//
//  Created by David Rosenberg on 9/8/25.
//

import Foundation
import Observation

extension ContentView {
    @Observable
    final class ViewModel {
        let appManager = AppManager()
        var selectedApp: InstalledApp? = nil
        var showingUninstallConfirmation = false
        var uninstallSuccess = false
        var searchTerm = ""
    }
}
