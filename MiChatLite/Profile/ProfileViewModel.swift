//
//  ProfileViewModel.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 15/09/26.
//

import Foundation
import Observation

protocol ProfileViewModelProtocol {
    func fetchProfile() async
}

@Observable
final class ProfileViewModel: ProfileViewModelProtocol {

    var isLoading: Bool
    let profileService: ProfileServiceProtocol
    let userId: UUID
    var userProfile: Profile?
    var errorMessage: String?

    init(isLoading: Bool = false,
         errorMessage: String? = nil,
         profileService: ProfileServiceProtocol = ProfileService(),
         userId: UUID
    ) {
        self.isLoading = isLoading
        self.errorMessage = errorMessage
        self.profileService = profileService
        self.userId = userId
    }

    func fetchProfile() async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            userProfile = try await profileService.fetchUserProfile(for: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
