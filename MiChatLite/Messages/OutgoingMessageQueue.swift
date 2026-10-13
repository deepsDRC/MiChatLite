//
//  OutgoingMessageQueue.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 21/09/26.
//

import Foundation
import Synchronization

nonisolated final class OutgoingMessageQueue: OutgoingMessageQueueProtocol,
    Sendable
{
    private let messagesQueue = Mutex<[OutgoingMessage]>([])

    func enqueue(_ message: OutgoingMessage) {
        messagesQueue.withLock { queue in
            guard
                !queue.contains(where: {
                    $0.localMessageId == message.localMessageId
                })
            else {
                return
            }

            queue.append(message)
        }
    }

    func messageWith(localId: UUID) -> OutgoingMessage? {
        messagesQueue.withLock({ queue in
            queue.first {
                $0.localMessageId == localId
            }
        })
    }

    func pendingMessages() -> [OutgoingMessage] {
        messagesQueue.withLock({ queue in
            queue.filter {
                $0.messageLifeCycleStage == .pending
            }
        })
    }

    func updateMessage(
        messageId: UUID,
        stage: OutgoingMessageLifeCycleStage
    ) {

        messagesQueue.withLock({ queue in
            guard
                let index = queue.firstIndex(where: {
                    $0.localMessageId == messageId
                })
            else { return }

            let currentStage = queue[index].messageLifeCycleStage
            guard currentStage.canTransition(to: stage) else { return }
            queue[index].messageLifeCycleStage = stage
        })
    }

    func dequeue(messageId: UUID) {
        messagesQueue.withLock { queue in
            queue.removeAll { $0.localMessageId == messageId }
        }
    }
}
