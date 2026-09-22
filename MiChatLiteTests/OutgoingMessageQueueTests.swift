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

        XCTAssertEqual(queue.nextPendingMessage(), messageA)

        queue.updateMessage(messageId: messageA.localMessageId, stage: .sending)

        XCTAssertEqual(queue.nextPendingMessage(), messageB)

        queue.updateMessage(messageId: messageB.localMessageId, stage: .sending)

        XCTAssertEqual(queue.nextPendingMessage(), messageC)

        queue.updateMessage(messageId: messageC.localMessageId, stage: .sending)

        XCTAssertNil(queue.nextPendingMessage())
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

        XCTAssertEqual(queue.nextPendingMessage(), message)

        queue.updateMessage(messageId: message.localMessageId, stage: .sending)
        queue.updateMessage(messageId: message.localMessageId, stage: .sent)
        queue.dequeue(messageId: message.localMessageId)

        XCTAssertNil(queue.nextPendingMessage())
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

        XCTAssertEqual(queue.nextPendingMessage(), message)

        queue.updateMessage(messageId: message.localMessageId, stage: .sending)

        XCTAssertNil(queue.nextPendingMessage())

        queue.updateMessage(messageId: message.localMessageId, stage: .failed)

        XCTAssertNil(queue.nextPendingMessage())

        queue.updateMessage(messageId: message.localMessageId, stage: .pending)

        XCTAssertEqual(queue.nextPendingMessage(), message)

    }
}
