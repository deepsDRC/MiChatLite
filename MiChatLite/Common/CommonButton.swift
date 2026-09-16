//
//  CommonButton.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 16/09/26.
//

import SwiftUI

struct CommonButton: View {
    let buttonImage: String
    let title: String
    let conditionFlag: Bool
    let onTap: (() -> Void)

    var body: some View {

        Button(action: onTap) {
            if conditionFlag {
                ProgressView()
                    .tint(.white)
            } else {
                HStack(alignment: .center, spacing: 4) {
                    Image(systemName: buttonImage)

                    Text(title)
                        .font(.callout)
                }
            }
        }
    }
}
