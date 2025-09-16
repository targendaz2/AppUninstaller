//
//  ContentView.swift
//  AppUninstaller
//
//  Created by David Rosenberg on 8/1/25.
//

import SwiftUI

let apps: [InstalledApp] = [
    InstalledApp(path: "/Applications/Visual Studio Code.app")
]

struct ContentView: View {
    var body: some View {
        VStack {
            HStack {
                apps[0].icon

                VStack {
                    Text(apps[0].name)
                    Text(apps[0].id.uuidString)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
