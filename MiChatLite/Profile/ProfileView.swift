//
//  ProfileView.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 15/09/26.
//

import Supabase
import SwiftUI

struct ProfileView: View {
    @Environment(AuthenticationManager.self)
    private var authManager

    var body: some View {
        if let userID = authManager.currentUser?.id {
            ProfileContentView(
                authManager: authManager,
                userID: userID
            )
        }
    }
}

struct ProfileContentView: View {
    @State private var profileVM: ProfileViewModel
    let authManager: AuthenticationManager
    let userID: UUID

    init(authManager: AuthenticationManager, userID: UUID) {
        self.authManager = authManager
        self.userID = userID

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

                    CommonButton(
                        buttonImage: "rectangle.portrait.and.arrow.right",
                        title: "Sign Out",
                        conditionFlag: authManager.isSigningOut
                    ) {
                        Task {
                            await authManager.signOut()
                        }
                    }

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
