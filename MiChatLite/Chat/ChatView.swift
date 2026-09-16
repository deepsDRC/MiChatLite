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
    @State private var messageViewModel = MessageViewModel()

    var body: some View {
        VStack {
            if messageViewModel.isLoading {
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
            }
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await messageViewModel.fetchMessages(for: conversationId)
        }
    }
}
