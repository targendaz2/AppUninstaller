//
//  AppDetailView.swift
//  AppUninstaller
//
//  Created by David Rosenberg on 9/8/25.
//

import SwiftUI

struct AppDetailView: View {
    @Environment(AppManager.self) private var appManager
    let app: InstalledApp
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AppIcon(icon: app.icon, size: .medium)
                .cornerRadius(10)
            
            Text(app.name)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(app.publisher ?? "Unknown Publisher")
                .font(.title3)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.head)
            
            Text("Version: \(app.version ?? "Unknown")")
                .font(.title3)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.head)
            
            Spacer()
        }
    }
}

#Preview {
    AppDetailView(app: .systemSettings)
        .environment(AppManager())
}
