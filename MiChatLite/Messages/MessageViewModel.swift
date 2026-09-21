//
//  MessageViewModel.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 16/09/26.
//

import Observation
import Foundation
import Supabase

struct FailedMessage {
    let conversationId: UUID
    let message: String
}

enum MessageLifeCycleStage {
    case idle
    case sending
    case sent
    case failed
}

protocol MessageViewModelProtocol {
    func fetchMessages(for conversationId: UUID) async
    func sendMessage(with conversationId: UUID, message: String) async
    func startListening(for conversationId: UUID) async
    func stopListening()
    func retryFailedMessage() async
}

@Observable final class MessageViewModel: MessageViewModelProtocol {
    var isLoading: Bool = false
    let messageService: MessageServiceProtocol
    let realTimeManager: RealtimeManagerProtocol
    var errorMessage: String? = nil
    var messages: [Message] = []
    var realTimeListenerTask: Task<Void, Never>?
    var messageLifeCycleStage: MessageLifeCycleStage = .idle
    var messageSendError: MessageSendError?
    private var lastFailedMessage: FailedMessage?

    init(
        messageService: MessageServiceProtocol = MessageService(),
        realTimeManager: RealtimeManagerProtocol = RealtimeManager()
    ) {
        self.messageService = messageService
        self.realTimeManager = realTimeManager
    }

    func fetchMessages(for conversationId: UUID) async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            self.messages = try await messageService.fetchMessages(for: conversationId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func retryFailedMessage() async {
        guard let lastFailedMessage else { return }
        await sendMessage(with: lastFailedMessage.conversationId,
                              message: lastFailedMessage.message)
    }
    
    func sendMessage(with conversationId: UUID, message: String) async {
        messageLifeCycleStage = .sending
        messageSendError = nil
        lastFailedMessage = nil

        do {
            let _ = try await messageService.sendMessage(with: conversationId,
                                                         message: message)

            messageLifeCycleStage = .sent
        } catch {
            print("Error type:", type(of: error))
            print("Error:", String(describing: error))

            messageSendError = error as? MessageSendError
            messageLifeCycleStage = .failed
            lastFailedMessage = .init(conversationId: conversationId, message: message)
        }
    }

    func startListening(for conversationId: UUID) async {
        do {
            let messageAsyncStream = try await realTimeManager.subscribe(for: conversationId)

            realTimeListenerTask = Task {
                for await message in messageAsyncStream {
                    print("Realtime message received: \(message)")
                    let isDuplicateMessage = self.messages.contains(where: { $0.id == message.id })
                    if !isDuplicateMessage {
                        self.messages.append(message)
                    }
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func stopListening() {
        print("stop listening called...")

        realTimeListenerTask?.cancel()
        realTimeListenerTask = nil

        print("Realtime listener task cancelled...")
    }
}
