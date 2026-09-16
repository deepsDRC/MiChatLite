//
//  MessageViewModel.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 16/09/26.
//

import Observation
import Foundation

protocol MessageViewModelProtocol {
    func fetchMessages(for conversationId: UUID) async
}

@Observable final class MessageViewModel: MessageViewModelProtocol {
    var isLoading: Bool = false
    let messageService: MessageServiceProtocol
    var errorMessage: String? = nil
    var messages: [Message] = []

    init(messageService: MessageServiceProtocol = MessageService()) {
        self.messageService = messageService
    }

    func fetchMessages(for conversationId: UUID) async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            self.messages = try await messageService.fetchMessages(for: conversationId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
