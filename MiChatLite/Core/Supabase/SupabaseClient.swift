//
//  SupabaseClient.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 14/09/26.
//

import Foundation
import Supabase

enum SupabaseConfig {

    static let host: String = {
        guard let value = Bundle.main.object(
            forInfoDictionaryKey: "SUPABASE_HOST"
        ) as? String else {
            fatalError("Missing SUPABASE_HOST")
        }

        return value
    }()

    static let key: String = {
        guard let value = Bundle.main.object(
            forInfoDictionaryKey: "SUPABASE_KEY"
        ) as? String else {
            fatalError("Missing SUPABASE_KEY")
        }

        return value
    }()

    static var url: URL {
        guard let url = URL(string: "https://\(host)") else {
            fatalError("Invalid Supabase URL")
        }

        return url
    }
}

let supabase = SupabaseClient(
    supabaseURL: SupabaseConfig.url,
    supabaseKey: SupabaseConfig.key
)
