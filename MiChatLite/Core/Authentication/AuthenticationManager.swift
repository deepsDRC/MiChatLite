//
//  AuthenticationManager.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 15/09/26.
//

import Foundation
import Observation
import Supabase

protocol AuthSessionService {
    func observeAuthState() async
}

@Observable
final class AuthenticationManager: AuthSessionService {
    var isAuthenticated: Bool
    var isCheckingSession: Bool
    var currentUser: User?

    init(
        isAuthenticated: Bool = false,
        isCheckingSession: Bool = true,
        currentUser: User? = nil
    ) {
        self.isAuthenticated = isAuthenticated
        self.isCheckingSession = isCheckingSession
        self.currentUser = currentUser
    }

    func observeAuthState() async {
        for await state in supabase.auth.authStateChanges {
            switch state.event {

            case .initialSession:
                if let session = state.session {
                    currentUser = session.user
                    isAuthenticated = true
                } else {
                    currentUser = nil
                    isAuthenticated = false
                }

                isCheckingSession = false

            case .signedIn, .tokenRefreshed:
                if let session = state.session {
                    currentUser = session.user
                    isAuthenticated = true
                }

            case .signedOut:
                currentUser = nil
                isAuthenticated = false

            default:
                break
            }
        }
    }
}
