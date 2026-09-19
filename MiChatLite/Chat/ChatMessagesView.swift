//
//  ChatMessagesView.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 19/09/26.
//

internal import Auth
import Foundation
import SwiftUI

struct ChatMessagesView: View {
    let messages: [Message]
    let authManager: AuthenticationManager

    private func isCurrentUserMessage(message: Message) -> Bool {
        guard let currentUserId = authManager.currentUser?.id else {
            fatalError("Unable to fetch user information")
        }

        return message.senderId == currentUserId
    }

    var body: some View {
        ScrollViewReader { reader in
            ScrollView {
                LazyVStack {
                    ForEach(messages) { message in
                        let isCurrentUserMessage = self.isCurrentUserMessage(
                            message: message
                        )

                        HStack {
                            if isCurrentUserMessage {
                                Spacer()

                                ChatBubbleView(
                                    message: message,
                                    bubbleColor: .blue.opacity(0.7),
                                    textColor: .white
                                )
                            } else {
                                ChatBubbleView(
                                    message: message,
                                    bubbleColor: Color(
                                        .secondarySystemBackground
                                    ),
                                    textColor: .primary
                                )

                                Spacer()
                            }
                        }
                        .id(message.id)
                    }
                }
                .padding()
            }
            .onChange(of: messages) { _, newValue in
                if !newValue.isEmpty,
                    let lastMessage = newValue.last
                {
                    withAnimation {
                        reader.scrollTo(lastMessage.id)
                    }
                }
            }
        }
    }
}
