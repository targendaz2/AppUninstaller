//
//  UninstallButton.swift
//  AppUninstaller
//
//  Created by David Rosenberg on 9/8/25.
//

import SwiftUI

struct UninstallButton: View {
    var disabled = false
    var action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button("Uninstall", systemImage: "trash.fill", role: .destructive, action: action)
            .disabled(disabled)
            .onHover {
                isHovering = $0 && disabled
            }
            .popover(isPresented: $isHovering) {
                Text("This app is restricted from uninstallation by your organization.")
                    .foregroundStyle(.red)
                    .padding()
            }
            .controlSize(.large)
    }
}

#Preview {
    UninstallButton(action: {})
}
