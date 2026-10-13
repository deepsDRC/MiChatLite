//
//  MessageLifeCycleManager.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 22/09/26.
//

import Foundation

protocol MessageLifeCycleManagerProtocol {
    func send(_ message: OutgoingMessage) async
}

actor MessageLifeCycleManager: MessageLifeCycleManagerProtocol {
    let outgoingMessageQueue: OutgoingMessageQueueProtocol
    let messageService: MessageServiceProtocol

    private let maxConcurrentSends: Int
    private var activeConversationIDs: Set<UUID> = []
    private var activeSendCount: Int = 0

    init(
        outgoingMessageQueue: OutgoingMessageQueueProtocol,
        messageService: MessageServiceProtocol,
        maxConcurrentSends: Int = 3
    ) {
        self.outgoingMessageQueue = outgoingMessageQueue
        self.messageService = messageService
        self.maxConcurrentSends = maxConcurrentSends
    }


    private func nextEligibleMessage() -> OutgoingMessage? {
        guard activeSendCount < maxConcurrentSends else {
            return nil
        }

        return outgoingMessageQueue.pendingMessages().first {
            !activeConversationIDs.contains($0.conversationId)
        }
    }

    func retry(_ message: OutgoingMessage) async {
        // First step: change the status from failed to pending
        outgoingMessageQueue.updateMessage(messageId: message.localMessageId, stage: .pending)
        // Second step: send the pending message
        schedulePendingMessages()
    }

    func send(_ message: OutgoingMessage) async {
        outgoingMessageQueue.enqueue(message)

        schedulePendingMessages()
    }

    private func schedulePendingMessages() {
        while activeSendCount < maxConcurrentSends {
            guard  let nextEligibleMessage = nextEligibleMessage() else {
                break
            }

            activeConversationIDs.insert(nextEligibleMessage.conversationId)
            activeSendCount += 1
            outgoingMessageQueue.updateMessage(messageId: nextEligibleMessage.localMessageId, stage: .sending)

            Task {
                await process(nextEligibleMessage)
            }
        }
    }

    private func process(_ message: OutgoingMessage) async {
        defer {
            removeActiveConversation(with: message.conversationId)
            schedulePendingMessages()
        }

        do {
            let _ = try await messageService.sendMessage(with: message.conversationId, message: message.message)

            outgoingMessageQueue.updateMessage(messageId: message.localMessageId, stage: .sent)
            outgoingMessageQueue.dequeue(messageId: message.localMessageId)
        } catch {
            outgoingMessageQueue.updateMessage(messageId: message.localMessageId, stage: .failed)
        }
    }

    private func removeActiveConversation(with _conversationId: UUID) {
        activeConversationIDs.remove(_conversationId)
        activeSendCount -= 1
    }
}
