//
//  MiChatLiteApp.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 14/09/26.
//

import SwiftUI

@main
struct MiChatLiteApp: App {
    @State private var authManager = AuthenticationManager()
    
    var body: some Scene {
        WindowGroup {
            AuthenticationRootView(authManager: authManager)
                .task {
                    await authManager.observeAuthState()
                }
        }
    }
}
