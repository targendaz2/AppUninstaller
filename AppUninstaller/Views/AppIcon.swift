//
//  AppIcon.swift
//  AppUninstaller
//
//  Created by David Rosenberg on 9/8/25.
//

import SwiftUI

struct AppIcon: View {
    enum Size: CGFloat {
        case small = 32
        case medium = 64
    }
    
    let icon: NSImage?
    let size: Size
    
    var body: some View {
        Group {
            if let icon = icon {
                Image(nsImage: icon)
                    .resizable()
            } else {
                Image(systemName: "app.fill")
                    .resizable()
            }
        }
        .frame(width: size.rawValue, height: size.rawValue)
    }
}

#Preview {
    AppIcon(icon: nil, size: .small)
}
