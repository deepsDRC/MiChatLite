//
//  FindUsersService.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 16/09/26.
//

import Supabase
import Foundation

protocol FindUsersServiceProtocol {
    func fetchUserProfiles(for searchText: String) async throws -> [Profile]
}

final class FindUsersService: FindUsersServiceProtocol {

    func fetchUserProfiles(for searchText: String) async throws -> [Profile] {
        if searchText.isEmpty {
            // Means the api must return all the profiles to which current user have access to.
            let profiles: [Profile] =
                try await supabase
                .from("profiles")
                .select()
                .execute()
                .value

            return profiles
        }

        // If there is a Search Text,api must return only those users that matches
        // display_name or username from supabase "profiles" table

        let profiles: [Profile] =
            try await supabase
            .from("profiles")
            .select()
            .or(
                "username.ilike.%\(searchText)%,display_name.ilike.%\(searchText)%"
            )
            .execute()
            .value

        return profiles
    }
}
