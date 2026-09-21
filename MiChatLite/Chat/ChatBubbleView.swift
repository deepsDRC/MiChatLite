//
//  MessageBubbleView.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 18/09/26.
//

import SwiftUI

struct ChatBubbleView: View {
    let message: Message

    var bubbleColor: Color = .blue
    var textColor: Color = .white

    let cornerRadius: CGFloat = 12

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(message.message)
                .foregroundStyle(textColor)
                .frame(maxWidth: 400, alignment: .leading)

            Text(message.createdAt.hhmmFormattedDateTime())
                .font(.caption)
                .foregroundStyle(textColor.opacity(0.7))
        }
        .padding()
        .background(bubbleColor)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
