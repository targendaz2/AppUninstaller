//
//  AppListItem.swift
//  AppUninstaller
//
//  Created by David Rosenberg on 9/8/25.
//

import SwiftUI

struct AppListItem: View {
    @Environment(InstalledAppsStore.self) private var appManager
    let app: InstalledApp

    var body: some View {
        HStack {
            AppIcon(icon: app.icon, size: .small)

            VStack(alignment: .leading) {
                Text(app.name)
                    .font(.headline)

                if let publisher = app.publisher {
                    Text(publisher)
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }

            Spacer()

            if !appManager.canUninstall(app: app) {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.red)
                    .help("This app is restricted from uninstallation by your organization.")
            }
        }
    }
}

#Preview {
    AppListItem(app: .systemSettings)
        .environment(InstalledAppsStore())
        .padding()
}
