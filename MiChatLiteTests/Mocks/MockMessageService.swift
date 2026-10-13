//
//  MockMessageService.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 05/10/26.
//

import Foundation
import XCTest

@testable import MiChatLite

struct MessageRequest {
    let conversationId: UUID
    let message: String
}

enum TestError: Error {
    case serverNotAvailable
    case internalError
}

actor MockMessageService: MessageServiceProtocol {
    private var requests: [MessageRequest] = []
    private var pendingRequestContinuations:
        [UUID: CheckedContinuation<Message, Error>] = [:]

    let requestStream: AsyncStream<MessageRequest>
    private let requestStreamContinuation:
        AsyncStream<MessageRequest>.Continuation

    init() {
        let (stream, continuation) = AsyncStream<MessageRequest>.makeStream()

        self.requestStream = stream
        self.requestStreamContinuation = continuation
    }

    var receivedRequestsCount: Int {
        return requests.count
    }

    func fetchMessages(for conversationId: UUID) async throws -> [MiChatLite
        .Message]
    {
        return []
    }

    func sendMessage(with conversationId: UUID, message: String) async throws
        -> MiChatLite.Message
    {

        let request = MessageRequest(
            conversationId: conversationId,
            message: message
        )

        requests.append(request)

        return try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Message, Error>) in
            pendingRequestContinuations[conversationId] = continuation
            requestStreamContinuation.yield(request)
        }
    }

    func completePendingRequest(with conversationId: UUID, message: Message) {
        guard
            let continuation = pendingRequestContinuations.removeValue(
                forKey: conversationId
            )
        else {
            return
        }

        continuation.resume(returning: message)
    }

    func pendingRequestFailed(with conversationId: UUID) {
        guard
            let continuation = pendingRequestContinuations.removeValue(
                forKey: conversationId
            )
        else {
            return
        }

        continuation.resume(throwing: TestError.serverNotAvailable)
    }
}
