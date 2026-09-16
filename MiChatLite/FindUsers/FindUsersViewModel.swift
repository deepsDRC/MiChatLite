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
    func getConversationId(for user: Profile) async
}

@Observable
final class FindUsersViewModel: FindUsersViewModelProtocol {

    var isLoading: Bool = false
    var errorMessage: String?
    let findUserService: FindUsersServiceProtocol
    let conversationService: ConversationServiceProtocol
    var searchText: String
    var userProfiles: [Profile]
    var conversationId: UUID?

    init(
        errorMessage: String? = nil,
        searchText: String = "",
        userProfiles: [Profile] = [],
        findUserService: FindUsersServiceProtocol = FindUsersService(),
        conversationService: ConversationServiceProtocol = ConversationService()
    ) {
        self.errorMessage = errorMessage
        self.searchText = searchText
        self.userProfiles = userProfiles
        self.findUserService = findUserService
        self.conversationService = conversationService
    }

    func fetchUserProfiles() async {
        isLoading = true
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

    func getConversationId(for user: Profile) async {
        do {
            self.conversationId = try await conversationService.getConversationId(chatUserID: user.id)
            print("Conversation ID is:\(self.conversationId?.uuidString ?? "nil")")

        } catch {
            print(error.localizedDescription)
        }
    }
}
