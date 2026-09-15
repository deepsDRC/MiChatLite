//
//  HomeView.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 15/09/26.
//

import SwiftUI
import Supabase

struct HomeView: View {

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Welcome to MiChatLite")
                    .font(.title)
                    .navigationTitle("Home")
            }
            .padding()
        }
    }
}

#Preview {
    HomeView()
}
