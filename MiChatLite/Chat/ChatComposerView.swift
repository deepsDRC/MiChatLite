//
//  ChatComposerView.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 19/09/26.
//

import SwiftUI

struct ChatComposerView: View {
    @Binding var message: String
    let messageLifeCycleStage: MessageLifeCycleStage
    let onSend: () -> Void
    let onRetryFailedMessage: () -> Void

    private func isValidMessage() -> Bool {
        !message.trimmed.isBlank
    }

    var body: some View {
        VStack {
            if messageLifeCycleStage == .failed {
                HStack(spacing: 10) {
                    Text("Message failed to send ")
                        .font(.caption)
                        .foregroundStyle(.red)

                    Button(action: onRetryFailedMessage) {
                        Image(systemName: "arrow.trianglehead.clockwise")
                            .foregroundColor(.red)
                    }
                }
            }
            
            HStack(alignment: .bottom, spacing: 8) {
                TextField(
                    "Enter your message",
                    text: $message,
                    axis: .vertical
                )
                .textFieldStyle(.plain)
                .lineLimit(1...4)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .stroke(
                            Color.secondary.opacity(0.35),
                            lineWidth: 1
                        )
                )

                Button {
                    onSend()
                } label: {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 42, height: 42)
                        .background(
                            Circle()
                                .fill(.blue.opacity(0.7))
                        )
                        .foregroundStyle(.white)
                }
                .disabled(!isValidMessage() || messageLifeCycleStage == .sending)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.vertical, 5)

        }
    }
}
