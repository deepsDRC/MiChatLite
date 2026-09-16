//
//  MessageService.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 16/09/26.
//

import Foundation
import Supabase

protocol MessageServiceProtocol {
    func fetchMessages(for conversationId: UUID) async throws -> [Message]
}

final class MessageService: MessageServiceProtocol {
    func fetchMessages(for conversationId: UUID) async throws -> [Message] {
        let messages: [Message] =
            try await supabase
            .from("messages")
            .select()
            .eq("conversation_id", value: conversationId)
            .order("created_at", ascending: true)
            .execute()
            .value

        return messages
    }
}
