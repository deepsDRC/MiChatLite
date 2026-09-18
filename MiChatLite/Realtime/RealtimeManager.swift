//
//  RealtimeManager.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 18/09/26.
//

import Foundation
import Supabase

protocol RealtimeManagerProtocol {
    func subscribe(for conversationId: UUID) async throws -> AsyncStream<Message>
}

actor RealtimeManager: RealtimeManagerProtocol {
    private var realtimeEventTask: Task<Void, Never>?

    func subscribe(for conversationId: UUID) async throws -> AsyncStream<Message> {
        let channel = await supabase.channel("conversations")

        let insertions = channel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "messages",
            filter: .eq("conversation_id", value: conversationId)
        )

        try await channel.subscribeWithError()

        let messageStream = AsyncStream<Message> { continuation in

            continuation.onTermination = { [weak self] termination in
                print("Realtime stream terminated: \(termination)")

                Task {
                    await supabase.removeChannel(channel)
                    await self?.realtimeEventTask?.cancel()
                }
            }

            realtimeEventTask = Task {
                for await insert in insertions {
                    do {
                        let message: Message = try insert.record.decode()
                        continuation.yield(message)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }

        return messageStream
    }
}
