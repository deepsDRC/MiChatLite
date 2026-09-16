//
//  FindUsersViewModel.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 16/09/26.
//

import Foundation
import Observation

protocol FindUsersViewModelProtocol {
    func fetchUserProfiles() async
}

@Observable
final class FindUsersViewModel: FindUsersViewModelProtocol {

    var isLoading: Bool = false
    var errorMessage: String?
    let findUserService: FindUsersServiceProtocol
    var searchText: String
    var userProfiles: [Profile]

    init(
        errorMessage: String? = nil,
        searchText: String = "",
        userProfiles: [Profile] = [],
        findUserService: FindUsersServiceProtocol = FindUsersService()
    ) {
        self.errorMessage = errorMessage
        self.searchText = searchText
        self.userProfiles = userProfiles
        self.findUserService = findUserService
    }

    func fetchUserProfiles() async {
        isLoading = true
        userProfiles.removeAll()
        errorMessage = nil

        defer {
            isLoading = false
        }
        do {
            userProfiles = try await findUserService.fetchUserProfiles(
                for: searchText
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
