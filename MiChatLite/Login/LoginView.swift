//
//  LoginView.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 14/09/26.
//

import SwiftUI

struct LoginView: View {

    @State private var authenticationVM = AuthenticationViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Welcome back")
                        .font(.title)
                        .foregroundStyle(.primary)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        TextField(
                            "Please enter email",
                            text: $authenticationVM.email
                        )
                        .font(.caption)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        SecureField(
                            "Please enter your password",
                            text: $authenticationVM.password
                        )
                        .font(.caption)
                        .textFieldStyle(.roundedBorder)
                    }

                    VStack(spacing: 4) {
                        LoginButton(authVM: authenticationVM)
                            .buttonStyle(.borderedProminent)
                            .disabled(authenticationVM.isLoading)

                        if let errorMessage = authenticationVM.errorMessage {
                            Text(errorMessage)
                                .font(.caption2)
                                .foregroundStyle(.red)
                                .padding(.horizontal)
                        }
                    }

                    VStack(spacing: 8) {
                        Text("Don't have an account yet?")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Button("Sign up") {
                            // Registration will be implemented later.
                        }
                    }
                }
                .padding()
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("MiChatLite")
        }
    }
}

struct LoginButton: View {
    var authVM: AuthenticationViewModel

    var body: some View {
        Button {
            Task {
                await authVM.authenticateUser()
            }
        } label: {
            if authVM.isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Text("Sign In")
                    .font(.callout)
            }
        }
    }
}

#Preview {
    LoginView()
}
