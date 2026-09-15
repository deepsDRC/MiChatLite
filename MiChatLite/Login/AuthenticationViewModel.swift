//
//  AuthenticationViewModel.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 14/09/26.
//

import Foundation
import Observation
import Supabase

protocol UserAuthService {
    func authenticateUser() async
}

enum AuthenticationError: LocalizedError {
    case incorrectCredentials
    case unknownError

    var errorDescription: String? {
        switch self {
        case .incorrectCredentials:
            "Email or password is incorrect."
        case .unknownError:
            "Some unknown error occurred"
        }
    }
}

@Observable
final class AuthenticationViewModel: UserAuthService {
    var email: String = ""
    var password: String = ""
    var isLoading = false
    var errorMessage: String?

    func authenticateUser() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            try await supabase.auth.signIn(email: email, password: password)
            print("Login success")
        } catch (let err as AuthError) {
            switch err.errorCode {
            case .invalidCredentials:
                errorMessage =
                    AuthenticationError.incorrectCredentials
                    .localizedDescription
            default:
                errorMessage =
                    AuthenticationError.unknownError.localizedDescription
            }
        } catch {
            errorMessage = AuthenticationError.unknownError.localizedDescription
        }
    }
}
