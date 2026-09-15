//
//  ProfileService.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 15/09/26.
//

import Foundation
import Supabase

protocol ProfileServiceProtocol {
    func fetchUserProfile(for userId: UUID) async throws -> Profile
}

final class ProfileService: ProfileServiceProtocol {
    func fetchUserProfile(for userId: UUID) async throws -> Profile {
        let profile: Profile =
            try await supabase
            .from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value

        return profile
    }
}
