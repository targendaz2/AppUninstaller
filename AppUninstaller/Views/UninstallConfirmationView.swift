//
//  UninstallConfirmationView.swift
//  AppUninstaller
//
//  Created by David Rosenberg on 9/8/25.
//

import SwiftUI

struct UninstallConfirmationView: View {
    let appName: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundStyle(.orange)

            Text("Confirm Uninstallation")
                .font(.title)
                .fontWeight(.bold)

            Text(
                "Are you sure you want to uninstall \"\(appName)\"? This will remove the application and its associated files."
            )
            .multilineTextAlignment(.center)
            .padding(.horizontal)

            HStack {
                Button("Cancel", role: .cancel, action: onCancel)
                Button("Uninstall", role: .destructive, action: onConfirm)
            }
        }
        .padding(30)
    }
}

#Preview {
    UninstallConfirmationView(appName: "Visual Studio Code", onConfirm: {}, onCancel: {})
}
