//
//  ChatView.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 16/09/26.
//

import Foundation
import SwiftUI

struct ChatView: View {
    let conversationId: UUID
    @State private var currentMessage: String = ""
    @State private var messageViewModel = MessageViewModel()

    private func isValidMessage() -> Bool {
        if currentMessage.trimmed.isBlank {
            return false
        }

        return true
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
                List(messageViewModel.messages) { message in
                    Text(message.message)
                }

                HStack(alignment: .bottom) {
                    TextField(
                        "Enter your message",
                        text: $currentMessage,
                        axis: .vertical
                    )
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)

                    Button {
                        Task {
                            await messageViewModel.sendMessage(
                                with: conversationId,
                                message: currentMessage.trimmed
                            )

                            if messageViewModel.errorMessage == nil {
                                currentMessage = ""
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 38, height: 38)
                            .background(Circle().fill(.black))
                            .foregroundStyle(.white)
                    }
                    .disabled(!isValidMessage() || messageViewModel.isLoading)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await messageViewModel.fetchMessages(for: conversationId)
        }
    }
}
