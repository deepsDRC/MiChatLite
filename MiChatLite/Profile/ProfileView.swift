//
//  ProfileView.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 15/09/26.
//

import Supabase
import SwiftUI

struct ProfileView: View {
    let authManager: AuthenticationManager
    @State private var profileVM: ProfileViewModel

    init(authManager: AuthenticationManager) {
        self.authManager = authManager
        guard let userID = authManager.currentUser?.id else {
            fatalError("ProfileView requires an authenticated user")
        }

        print("Profile user ID:", userID)
        _profileVM = State(initialValue: ProfileViewModel(userId: userID))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                if profileVM.isLoading {
                    ProgressView()
                        .tint(.accentColor)
                } else if let errorMessage = profileVM.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)

                        Text(errorMessage)
                            .font(.callout)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)

                        Button("Retry") {
                            Task {
                                await profileVM.fetchProfile()
                            }
                        }
                        .buttonStyle(.bordered)
                    }

                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)

                    if let userDisplayName = profileVM.userProfile?.displayName
                    {
                        Text(userDisplayName)
                            .font(.title)
                            .foregroundStyle(.primary)
                    }

                    if let userName = profileVM.userProfile?.username {
                        Text("@\(userName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 16) {
                        if let email = authManager.currentUser?.email {
                            HStack(spacing: 12) {
                                Image(systemName: "envelope")
                                    .frame(width: 24)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Email")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                    Text(email)
                                        .font(.caption)
                                        .foregroundStyle(.primary)
                                }
                            }
                        }

                        if let userName = profileVM.userProfile?.username {
                            HStack(spacing: 12) {
                                Image(systemName: "person.circle")

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Username")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                    Text(userName)
                                        .font(.caption)
                                        .foregroundStyle(.primary)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Divider()

                    SignOutButton(authManager: authManager)
                        .font(.callout)
                        .buttonStyle(.bordered)
                        .tint(.red)
                        .disabled(authManager.isSigningOut)

                    if let errorMessage = profileVM.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .task {
            await profileVM.fetchProfile()
        }
    }
}

struct SignOutButton: View {
    let authManager: AuthenticationManager

    var body: some View {
        Button {
            Task {
                await authManager.signOut()
            }
        } label: {
            if authManager.isSigningOut {
                ProgressView()
                    .tint(.white)
            } else {
                HStack(alignment: .center, spacing: 4) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")

                    Text("Sign Out")
                        .font(.callout)
                }
            }
        }
    }
}
