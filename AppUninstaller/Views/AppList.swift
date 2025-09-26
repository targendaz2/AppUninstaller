//
//  AppList.swift
//  AppUninstaller
//
//  Created by David Rosenberg on 9/8/25.
//

import SwiftUI

struct AppList: View {
    @Environment(InstalledAppsStore.self) private var appManager
    @Binding var selectedApp: InstalledApp?

    var body: some View {
        List(appManager.installedApps, selection: $selectedApp) { app in
            AppListItem(app: app)
                .tag(app)
        }
    }
}

#Preview {
    AppList(selectedApp: .constant(nil))
        .environment(InstalledAppsStore())
}
