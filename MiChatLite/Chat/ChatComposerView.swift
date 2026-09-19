//
//  ChatComposerView.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 19/09/26.
//

import SwiftUI

struct ChatComposerView: View {
    @Binding var message: String

    let isLoading: Bool
    let onSend: () -> Void

    private func isValidMessage() -> Bool {
        !message.trimmed.isBlank
    }

    var body: some View {
        HStack(alignment: .bottom) {
            TextField(
                "Enter your message",
                text: $message,
                axis: .vertical
            )
            .textFieldStyle(.roundedBorder)
            .lineLimit(1...4)

            Button {
                onSend()
            } label: {
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 38, height: 38)
                    .background(
                        Circle()
                            .fill(.black)
                    )
                    .foregroundStyle(.white)
            }
            .disabled(!isValidMessage() || isLoading)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}
