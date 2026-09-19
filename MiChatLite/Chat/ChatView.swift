//
//  ChatView.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 16/09/26.
//

//import Auth
import Foundation
import SwiftUI

struct ChatView: View {
    let conversationId: UUID

    @State private var currentMessage: String = ""
    @State private var messageViewModel = MessageViewModel()

    @Environment(AuthenticationManager.self)
    private var authManager

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
                ChatMessagesView(
                    messages: messageViewModel.messages,
                    authManager: authManager
                )

                ChatComposerView(
                    message: $currentMessage,
                    isLoading: messageViewModel.isLoading
                ) {
                    Task {
                        await messageViewModel.sendMessage(
                            with: conversationId,
                            message: currentMessage.trimmed
                        )

                        if messageViewModel.errorMessage == nil {
                            currentMessage = ""
                        }
                    }
                }
            }
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .task {
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
