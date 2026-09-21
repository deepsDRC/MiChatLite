//
//  MessageService.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 16/09/26.
//

import Foundation
import Supabase

enum MessageSendError: Error {
    case network(Error)
    case unauthorized(Error)
    case notMember(Error)
    case unknown(Error)
}

protocol MessageServiceProtocol {
    func fetchMessages(for conversationId: UUID) async throws -> [Message]
    func sendMessage(with conversationId: UUID, message: String) async throws
        -> Message
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

    func sendMessage(with conversationId: UUID, message: String) async throws
        -> Message
    {
        do {
            let messageReceived: Message =
                try await supabase
                .rpc(
                    "send_message",
                    params: [
                        "p_conversation_id": conversationId.uuidString,
                        "p_message": message,
                    ]
                )
                .single()
                .execute()
                .value

            return messageReceived
        } catch {
            throw mapMessageSendError(error)
        }
    }

    func mapMessageSendError(_ error: Error) -> MessageSendError {
        guard let postgrestError = error as? PostgrestError,
              let errorCode = postgrestError.code
        else {
            return MessageSendError.unknown(error)
        }

        if errorCode == "P0001" && postgrestError.message == "User is not a member of this conversation" {
            return .notMember(error)
        }

        return .unknown(error)
    }
}
