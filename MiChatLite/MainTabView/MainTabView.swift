//
//  MainTabView.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 16/09/26.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab {
                ProfileView()
            }

            Tab {
                FindUsersView()
            }
        }
    }
}
