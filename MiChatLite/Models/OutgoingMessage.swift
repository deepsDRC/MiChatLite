//
//  OutgoingMessage.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 21/09/26.
//

import Foundation

nonisolated protocol OutgoingMessageQueueProtocol: Sendable {
    func enqueue(_ message: OutgoingMessage)

    func pendingMessages() -> [OutgoingMessage]

    func updateMessage(
        messageId: UUID,
        stage: OutgoingMessageLifeCycleStage
    )
    
    func dequeue(messageId: UUID)
}

nonisolated enum OutgoingMessageLifeCycleStage {
    case pending
    case sending
    case sent
    case failed

    func canTransition(to nextStage: OutgoingMessageLifeCycleStage) -> Bool {
        switch self {
        case .pending:
            return nextStage == .sending
        case .sending:
            return nextStage == .sent || nextStage == .failed
        case .sent:
            return false
        case .failed:
            return nextStage == .pending
        }
    }
}

nonisolated struct OutgoingMessage: Equatable, Sendable {

    let localMessageId: UUID
    let conversationId: UUID
    let senderId: UUID
    let message: String
    let createdAt: Date
    var messageLifeCycleStage: OutgoingMessageLifeCycleStage
}
