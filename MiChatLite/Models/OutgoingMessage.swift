//
//  OutgoingMessage.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 21/09/26.
//

import Foundation

enum OutgoingMessageLifeCycleStage {
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

struct OutgoingMessage {

    let localMessageId: UUID
    let conversationId: UUID
    let senderId: UUID
    let message: String
    let createdAt: Date
    let messageLifeCycleStage: OutgoingMessageLifeCycleStage
}
