//
//  Profile.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 15/09/26.
//

import Foundation

struct Profile: Decodable {
    let id: UUID
    let username: String
    let displayName: String
    let avatarURL: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case displayName = "display_name"
        case avatarURL = "avatar_url"
        case createdAt = "created_at"
    }
}
