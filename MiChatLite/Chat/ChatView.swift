//
//  ChatView.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 16/09/26.
//

import Foundation
import SwiftUI
internal import Auth

struct ChatView: View {
    let conversationId: UUID

    @State private var currentMessage: String = ""
    @State private var messageViewModel = MessageViewModel()

    @Environment(AuthenticationManager.self)
    private var authManager

    private func clearMessageOnSuccessfulSend() {
        if messageViewModel.messageLifeCycleStage == .sent {
            currentMessage = ""
        }
    }

    var body: some View {
        VStack {
            if messageViewModel.isLoading && messageViewModel.messages.isEmpty {
                ProgressView()
                    .tint(.accentColor)
            } else if let errorMessage = messageViewModel.errorMessage {
                ErrorView(errorMessage: errorMessage) {
                    Task {
                        await messageViewModel.fetchMessages(
                            for: conversationId
                        )
                    }
                }
            } else {
                if let loggedInUserId = authManager.currentUser?.id {
                    ChatMessagesView(
                        messages: messageViewModel.messages,
                        loggedInUserId: loggedInUserId
                    )

                    ChatComposerView(
                        message: $currentMessage,
                        messageLifeCycleStage: messageViewModel.messageLifeCycleStage,

                    ) {
                        Task {
                            await messageViewModel.sendMessage(
                                with: conversationId,
                                message: currentMessage.trimmed
                            )
                            clearMessageOnSuccessfulSend()
                        }
                    } onRetryFailedMessage: {
                        Task {
                            await messageViewModel.retryFailedMessage()
                            clearMessageOnSuccessfulSend()
                        }
                    }
                } else {
                    ErrorView(errorMessage: "Unable to load user information. Please try again.") {
                        Task {
                            await authManager.refreshCurrentSession()
                        }
                    }
                }
            }
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: authManager.currentUser?.id) {
            await messageViewModel.fetchMessages(for: conversationId)

            print("Real time starts listening to updates...")
            await messageViewModel.startListening(for: conversationId)
        }
        .onDisappear {
            print("Calling stop listening...")
            messageViewModel.stopListening()
        }
    }
}
