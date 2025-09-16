//
//  ContentView.swift
//  AppUninstaller
//
//  Created by David Rosenberg on 8/1/25.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = ViewModel()

    var body: some View {
        NavigationView {
            AppList(selectedApp: $viewModel.selectedApp)
                .environment(viewModel.appManager)
                .listStyle(.sidebar)
                .frame(minWidth: 200)

            VStack {
                if let selectedApp = viewModel.selectedApp {
                    AppDetailView(app: selectedApp)
                        .environment(viewModel.appManager)
                        .padding()

                    UninstallButton(disabled: !viewModel.appManager.canUninstall(app: selectedApp))
                    {
                        viewModel.showingUninstallConfirmation = true
                    }
                    .padding(.bottom)
                } else {
                    Text("Select an app to view details and uninstall.")
                        .foregroundStyle(.gray)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("App Uninstaller")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    Task {
                        try? await viewModel.appManager.getInstalledApps()
                    }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
        }
        .sheet(isPresented: $viewModel.showingUninstallConfirmation) {
            UninstallConfirmationView(
                appName: viewModel.selectedApp?.name ?? "Unknown App",
                onConfirm: {},
                onCancel: {
                    viewModel.showingUninstallConfirmation = false
                }
            )
        }
        .task {
            try? await viewModel.appManager.getInstalledApps()
        }
    }
}

#Preview {
    ContentView()
}
