//
//  ConversationService.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 16/09/26.
//

import Foundation
import Supabase

public protocol ConversationServiceProtocol {
    func getConversationId(chatUserID: UUID) async throws -> UUID
}

final class ConversationService: ConversationServiceProtocol {
    func getConversationId(chatUserID: UUID) async throws -> UUID {
        let conversationID: UUID =
            try await supabase
            .rpc(
                "create_conversation",
                params: ["other_user_id": chatUserID]
            )
            .single()
            .execute()
            .value

        return conversationID
    }
}
