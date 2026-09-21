//
//  FindUsersView.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 16/09/26.
//

import SwiftUI

struct FindUsersView: View {
    @State private var viewModel = FindUsersViewModel()
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.isLoading && viewModel.userProfiles.isEmpty {
                    ProgressView()
                        .tint(.accentColor)
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(errorMessage: errorMessage) {
                        Task {
                            await viewModel.fetchUserProfiles()
                        }
                    }
                } else if viewModel.userProfiles.isEmpty {
                    ContentUnavailableView(
                        "No users found",
                        systemImage: "person.2.slash"
                    )
                } else {
                    FindUsersSearchView(viewModel: viewModel)

                    Divider()

                    List(viewModel.userProfiles) { profile in
                        FindUsersRow(profile: profile)
                            .onTapGesture {
                                Task {
                                    await viewModel.getConversationId(
                                        for: profile
                                    )
                                }
                            }
                    }
                    .navigationDestination(item: $viewModel.conversationId) {
                        conversationId in
                        ChatView(conversationId: conversationId)
                    }
                    .listStyle(.plain)
                    .overlay {
                        if viewModel.isLoading {
                            ProgressView()
                        }
                    }
                }
            }
            .navigationTitle("Find Users")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await viewModel.fetchUserProfiles()
        }
    }
}

private struct FindUsersSearchView: View {
    @Bindable var viewModel: FindUsersViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .scaledToFit()

            TextField("Search", text: $viewModel.searchText)
                .focused($isFocused)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 8)
                .submitLabel(.search)
                .onSubmit {
                    Task {
                        await viewModel.fetchUserProfiles()
                    }
                }

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                    isFocused = false

                    Task {
                        await viewModel.fetchUserProfiles()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }
}

#Preview {
    FindUsersView()
}
