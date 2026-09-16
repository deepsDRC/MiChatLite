//
//  ErrorView.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 16/09/26.
//

import SwiftUI

struct ErrorView: View {
    let errorMessage: String
    let onRetry: () -> Void

    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .tint(.yellow)

            Text("Something went wrong")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(errorMessage)
                .font(.caption)
                .foregroundStyle(.primary)

            Button(action: onRetry) {
                Text("Retry")
            }
        }
        .padding()
    }
}
