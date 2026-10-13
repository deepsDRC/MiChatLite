//
//  MessageLifeCycleManagerTests.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 05/10/26.
//

import XCTest

@testable import MiChatLite

final class MessageLifeCycleManagerTests: XCTestCase {

    func testManagerNeverExceedMaxConcurrentSend() async {
        let messageA = OutgoingMessage(
            localMessageId: UUID(),
            conversationId: UUID(),
            senderId: UUID(),
            message: "Test Message A",
            createdAt: Date(),
            messageLifeCycleStage: .pending
        )

        let messageB = OutgoingMessage(
            localMessageId: UUID(),
            conversationId: UUID(),
            senderId: UUID(),
            message: "Test Message B",
            createdAt: Date(),
            messageLifeCycleStage: .pending
        )

        let messageC = OutgoingMessage(
            localMessageId: UUID(),
            conversationId: UUID(),
            senderId: UUID(),
            message: "Test Message C",
            createdAt: Date(),
            messageLifeCycleStage: .pending
        )

        let messageD = OutgoingMessage(
            localMessageId: UUID(),
            conversationId: UUID(),
            senderId: UUID(),
            message: "Test Message D",
            createdAt: Date(),
            messageLifeCycleStage: .pending
        )

        let messageService = MockMessageService()
        let queue = OutgoingMessageQueue()
        var requests: [MessageRequest] = []

        let messageLifeCycleManager = await MessageLifeCycleManager(
            outgoingMessageQueue: queue,
            messageService: messageService,
            maxConcurrentSends: 3
        )

        await messageLifeCycleManager.send(messageA)
        await messageLifeCycleManager.send(messageB)
        await messageLifeCycleManager.send(messageC)
        await messageLifeCycleManager.send(messageD)

        let sentMessageA: Message = Message(
            id: messageA.localMessageId,
            conversationId: messageA.conversationId,
            senderId: messageA.senderId,
            message: messageA.message,
            createdAt: messageA.createdAt,
            isRead: false
        )

        for await request in messageService.requestStream {
            requests.append(request)

            if requests.count == 3 {
                XCTAssertEqual(requests.count, 3)

                let pendingMessages = queue.pendingMessages()
                XCTAssertEqual(pendingMessages.count, 1)
                XCTAssertEqual(
                    pendingMessages.first?.localMessageId,
                    messageD.localMessageId
                )

                await messageService.completePendingRequest(
                    with: messageA.conversationId,
                    message: sentMessageA
                )

            }

            if requests.count == 4 {
                break
            }
        }

        XCTAssertEqual(requests.count, 4)
        XCTAssertEqual(requests.last?.conversationId, messageD.conversationId)
    }

    func testPerConversationSerialization() async {
        let conversationIDForMessageA = UUID()

        let messageA1 = OutgoingMessage(
            localMessageId: UUID(),
            conversationId: conversationIDForMessageA,
            senderId: UUID(),
            message: "Test Message A1",
            createdAt: Date(),
            messageLifeCycleStage: .pending
        )

        let messageA2 = OutgoingMessage(
            localMessageId: UUID(),
            conversationId: conversationIDForMessageA,
            senderId: UUID(),
            message: "Test Message A2",
            createdAt: Date(),
            messageLifeCycleStage: .pending
        )

        let messageB = OutgoingMessage(
            localMessageId: UUID(),
            conversationId: UUID(),
            senderId: UUID(),
            message: "Test Message B",
            createdAt: Date(),
            messageLifeCycleStage: .pending
        )

        let messageC = OutgoingMessage(
            localMessageId: UUID(),
            conversationId: UUID(),
            senderId: UUID(),
            message: "Test Message C",
            createdAt: Date(),
            messageLifeCycleStage: .pending
        )

        let sentMessageA1: Message = Message(
            id: messageA1.localMessageId,
            conversationId: messageA1.conversationId,
            senderId: messageA1.senderId,
            message: messageA1.message,
            createdAt: messageA1.createdAt,
            isRead: false
        )

        let queue = OutgoingMessageQueue()
        let messagingService = MockMessageService()
        let scheduler = await MessageLifeCycleManager(
            outgoingMessageQueue: queue,
            messageService: messagingService,
            maxConcurrentSends: 3
        )

        await scheduler.send(messageA1)
        await scheduler.send(messageA2)
        await scheduler.send(messageB)
        await scheduler.send(messageC)

        var requests: [MessageRequest] = []

        for await request in messagingService.requestStream {
            requests.append(request)

            if requests.count <= 3 {
                XCTAssertNotEqual(
                    request.message,
                    messageA2.message
                )
            }

            if requests.count == 3 {
                let pendingMessage = queue.pendingMessages()
                XCTAssertEqual(pendingMessage.count, 1)
                XCTAssertEqual(
                    pendingMessage.first?.localMessageId,
                    messageA2.localMessageId
                )

                await messagingService.completePendingRequest(
                    with: messageA1.conversationId,
                    message: sentMessageA1
                )
            }

            if requests.count == 4 {
                break
            }
        }

        XCTAssertEqual(requests.count, 4)
        XCTAssertEqual(requests.last?.conversationId, messageA2.conversationId)
    }

    func testFailedSendReleasesItsSlot() async {
        let messageA = OutgoingMessage(
            localMessageId: UUID(),
            conversationId: UUID(),
            senderId: UUID(),
            message: "Test Message A",
            createdAt: Date(),
            messageLifeCycleStage: .pending
        )

        let messageB = OutgoingMessage(
            localMessageId: UUID(),
            conversationId: UUID(),
            senderId: UUID(),
            message: "Test Message B",
            createdAt: Date(),
            messageLifeCycleStage: .pending
        )

        let messageC = OutgoingMessage(
            localMessageId: UUID(),
            conversationId: UUID(),
            senderId: UUID(),
            message: "Test Message C",
            createdAt: Date(),
            messageLifeCycleStage: .pending
        )

        let messageD = OutgoingMessage(
            localMessageId: UUID(),
            conversationId: UUID(),
            senderId: UUID(),
            message: "Test Message D",
            createdAt: Date(),
            messageLifeCycleStage: .pending
        )

        let queue = OutgoingMessageQueue()
        let service = MockMessageService()
        let scheduler = await MessageLifeCycleManager(
            outgoingMessageQueue: queue,
            messageService: service,
            maxConcurrentSends: 3
        )

        await scheduler.send(messageA)
        await scheduler.send(messageB)
        await scheduler.send(messageC)
        await scheduler.send(messageD)

        var requests: [MessageRequest] = []

        for await request in service.requestStream {

            requests.append(request)

            if requests.count == 3 {
                XCTAssertEqual(queue.pendingMessages().count, 1)
                XCTAssertEqual(
                    queue.pendingMessages().last?.conversationId,
                    messageD.conversationId
                )
                await service.pendingRequestFailed(
                    with: messageA.conversationId
                )
            }

            if requests.count == 4 {
                XCTAssertEqual(queue.pendingMessages().count, 0)
                XCTAssertEqual(request.conversationId, messageD.conversationId)
                break
            }
        }
        let expectation = XCTestExpectation(
            description: "Message A should transition to failed"
        )

        Task {
            while queue.messageWith(localId: messageA.localMessageId)?
                .messageLifeCycleStage != .failed
            {
                await Task.yield()
            }

            expectation.fulfill()
        }

        await fulfillment(
            of: [expectation],
            timeout: 1.0
        )

        let messageInQueue = queue.messageWith(
            localId: messageA.localMessageId
        )

        XCTAssertNotNil(messageInQueue)
        XCTAssertEqual(
            messageInQueue?.messageLifeCycleStage,
            .failed
        )
    }

    func testFailedMessageRetry() async {
        let messageA = OutgoingMessage(
            localMessageId: UUID(),
            conversationId: UUID(),
            senderId: UUID(),
            message: "Test Message A",
            createdAt: Date(),
            messageLifeCycleStage: .pending
        )

        let queue = OutgoingMessageQueue()
        let service = MockMessageService()
        let scheduler = await MessageLifeCycleManager(
            outgoingMessageQueue: queue,
            messageService: service
        )

        await scheduler.send(messageA)

        var requests: [MessageRequest] = []

        for await request in service.requestStream {
            requests.append(request)
            XCTAssertEqual(queue.pendingMessages().count, 0)

            await service.pendingRequestFailed(with: messageA.conversationId)
            break
        }

        let expectation = XCTestExpectation(
            description: "Failed request of Message A should be retried"
        )

        Task {
            while queue.messageWith(localId: messageA.localMessageId)?
                .messageLifeCycleStage != .failed
            {
                await Task.yield()
            }

            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1.0)
        await scheduler.retry(messageA)

        for await request in service.requestStream {
            XCTAssertEqual(
                request.conversationId,
                messageA.conversationId
            )

            let message = queue.messageWith(localId:messageA.localMessageId)

            XCTAssertEqual(
                message?.messageLifeCycleStage,
                .sending
            )

            break
        }

    }
}
