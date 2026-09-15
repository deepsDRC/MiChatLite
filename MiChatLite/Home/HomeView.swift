//
//  HomeView.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 15/09/26.
//

import SwiftUI

struct HomeView: View {
    let authManager: AuthenticationManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Welcome to MiChatLite")
                    .font(.title)
                    .navigationTitle("Home")

//                SignOutButton(authManager: authManager)
//                    .font(.callout)
//                    .buttonStyle(.borderedProminent)
//                    .disabled(authManager.isSigningOut)
//
//                if let errorMessage = authManager.errorMessage {
//                    Text(errorMessage)
//                        .font(.caption)
//                        .foregroundStyle(.red)
//                }
            }
            .padding()
        }
    }
}

//struct SignOutButton: View {
//    let authManager: AuthenticationManager
//
//    var body: some View {
//        Button {
//            Task {
//                await authManager.signOut()
//            }
//        } label: {
//            if authManager.isSigningOut {
//                ProgressView()
//                    .tint(.white)
//            } else {
//                Text("Sign Out")
//                    .font(.callout)
//            }
//        }
//    }
//}

#Preview {
    HomeView(authManager: AuthenticationManager())
}
