//
//  OutgoingMessageQueueTests.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 22/09/26.
//

import XCTest
@testable import MiChatLite

final class OutgoingMessageQueueTests: XCTestCase {

    func testQueuePendingOrder() {
        let messageA = OutgoingMessage(localMessageId: UUID(),
                                       conversationId: UUID(),
                                       senderId: UUID(),
                                       message: "Test Message A",
                                       createdAt: Date(),
                                       messageLifeCycleStage: .pending)

        let messageB = OutgoingMessage(localMessageId: UUID(),
                                       conversationId: UUID(),
                                       senderId: UUID(),
                                       message: "Test Message B",
                                       createdAt: Date(),
                                       messageLifeCycleStage: .pending)

        let messageC = OutgoingMessage(localMessageId: UUID(),
                                       conversationId: UUID(),
                                       senderId: UUID(),
                                       message: "Test Message C",
                                       createdAt: Date(),
                                       messageLifeCycleStage: .pending)

        let queue = OutgoingMessageQueue()
        queue.enqueue(messageA)
        queue.enqueue(messageB)
        queue.enqueue(messageC)

        XCTAssertEqual(queue.pendingMessages(), [messageA, messageB, messageC])

        queue.updateMessage(messageId: messageA.localMessageId, stage: .sending)

        XCTAssertEqual(queue.pendingMessages(), [messageB, messageC])

        queue.updateMessage(messageId: messageB.localMessageId, stage: .sending)

        XCTAssertEqual(queue.pendingMessages(), [messageC])

        queue.updateMessage(messageId: messageC.localMessageId, stage: .sending)

        XCTAssertTrue(queue.pendingMessages().isEmpty)
    }

    func testSuccessfulMessageIsDequeued() {
        let message = OutgoingMessage(localMessageId: UUID(),
                                       conversationId: UUID(),
                                       senderId: UUID(),
                                       message: "Test Message",
                                       createdAt: Date(),
                                       messageLifeCycleStage: .pending)

        let queue = OutgoingMessageQueue()
        queue.enqueue(message)

        XCTAssertEqual(queue.pendingMessages(), [message])

        queue.updateMessage(messageId: message.localMessageId, stage: .sending)
        queue.updateMessage(messageId: message.localMessageId, stage: .sent)
        queue.dequeue(messageId: message.localMessageId)

        XCTAssertTrue(queue.pendingMessages().isEmpty)
    }

    func testFailedMessageRemainsInQueue() {
        let message = OutgoingMessage(localMessageId: UUID(),
                                       conversationId: UUID(),
                                       senderId: UUID(),
                                       message: "Test Message",
                                       createdAt: Date(),
                                       messageLifeCycleStage: .pending)

        let queue = OutgoingMessageQueue()
        queue.enqueue(message)

        XCTAssertEqual(queue.pendingMessages(), [message])

        queue.updateMessage(messageId: message.localMessageId, stage: .sending)

        XCTAssertTrue(queue.pendingMessages().isEmpty)

        queue.updateMessage(messageId: message.localMessageId, stage: .failed)

        XCTAssertTrue(queue.pendingMessages().isEmpty)

        queue.updateMessage(messageId: message.localMessageId, stage: .pending)

        XCTAssertEqual(queue.pendingMessages(), [message])

    }
}
