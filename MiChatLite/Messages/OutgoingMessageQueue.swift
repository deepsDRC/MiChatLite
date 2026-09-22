//
//  OutgoingMessageQueue.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 21/09/26.
//

import Foundation

final class OutgoingMessageQueue: OutgoingMessageQueueProtocol {
    private var messagesQueue: [OutgoingMessage] = []

    private func isMessagePresentInQueue(_ messageId: UUID) -> Bool {
        messagesQueue.contains { $0.localMessageId == messageId }
    }

    func enqueue(_ message: OutgoingMessage) {
        if !isMessagePresentInQueue(message.localMessageId) {
            messagesQueue.append(message)
        }
    }

    func nextPendingMessage() -> OutgoingMessage? {
        messagesQueue.first { $0.messageLifeCycleStage == .pending }
    }

    func updateMessage(
        messageId: UUID,
        stage: OutgoingMessageLifeCycleStage
    ) {
        guard
            let index = messagesQueue.firstIndex(
                where: { $0.localMessageId == messageId }
            )
        else { return }

        let currentStage = messagesQueue[index].messageLifeCycleStage

        guard currentStage.canTransition(to: stage) else { return }
        messagesQueue[index].messageLifeCycleStage = stage
    }

    func dequeue(messageId: UUID) {
        messagesQueue.removeAll { $0.localMessageId == messageId }
    }
}
