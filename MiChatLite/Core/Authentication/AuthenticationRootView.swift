//
//  AuthenticationRootView.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 15/09/26.
//

import SwiftUI

struct AuthenticationRootView: View {
    let authManager: AuthenticationManager

    var body: some View {
        Group {
            if authManager.isCheckingSession {
                ProgressView()
                    .tint(.white)
            } else if authManager.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .environment(authManager)
    }
}
