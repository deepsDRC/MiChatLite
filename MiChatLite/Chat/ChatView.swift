//
//  ChatView.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 16/09/26.
//

import SwiftUI
import Foundation

struct ChatView: View {
    let conversationId: UUID

    var body: some View {
        NavigationStack {
            Text("Chat Id: \(conversationId.uuidString)")
                .navigationTitle("Chat")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
