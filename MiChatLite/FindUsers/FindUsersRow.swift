//
//  FindUsersRow.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 16/09/26.
//

import SwiftUI

struct FindUsersRow: View {
    var profile: Profile

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "person.circle.fill")
                .frame(width: 44, height: 44)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                Text(profile.displayName)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)

                Text("@\(profile.username)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
