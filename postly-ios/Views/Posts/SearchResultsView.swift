//
//  SearchResultsView.swift
//  Postly
//
//  Created by Christian Bonilla on 03/03/26.
//

import SwiftUI

struct SearchResultsView: View {
    
    @EnvironmentObject var session: SessionManager
    
    let query: String
    @Binding var selectedScreen: Screen?
    @Binding var isSearchExpanded: Bool
    
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let postService = PostService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            headerView
            
            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding(.top, 40)
            } else if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.08))
                    .cornerRadius(12)
            } else if posts.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(posts, id: \._id) { post in
                        NavigationLink {
                            PostDetailView(postId: post._id)
                                .environmentObject(session)
                        } label: {
                            searchResultCard(post)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .task(id: query) {
            await fetchSearchResults()
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 25, weight: .medium))
                    .foregroundColor(.blue)
                Text("Search results: \"\(query)\"")
                    .font(.system(size: 25, weight: .bold))
                    .lineLimit(2)
            }
            
            if !isLoading && !posts.isEmpty {
                Text("\(posts.count) result(s) were found.")
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Text("No results were found")
                .font(.system(size: 25, weight: .medium))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Text("Try different search terms")
                .font(.system(size: 20))
                .foregroundColor(.gray)
            
            Button {
                isSearchExpanded = false
                selectedScreen = .posts
            } label: {
                Text("See all publications")
                    .font(.headline)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private func searchResultCard(_ post: Post) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(post.title)
                .font(.title.bold())
                .foregroundColor(.primary)
            
            Text(post.content)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack(spacing: 18) {
                Label(shortDate(post.createdAt), systemImage: "calendar")
                Label("\(post.readTime) min", systemImage: "clock")
                Label("\(post.likes)", systemImage: "hand.thumbsup")
                Label("\(post.comments.count)", systemImage: "message")
            }
            .font(.subheadline)
            .foregroundColor(.gray)
            
            HStack(spacing: 10) {
                if let urlString = post.author.profilePicture, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            Circle().fill(Color.gray.opacity(0.25))
                        }
                    }
                    .frame(width: 28, height: 28)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                
                Text(post.author.name)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 7)
    }
    
    private func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    @MainActor
    private func fetchSearchResults() async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            posts = []
            errorMessage = nil
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            posts = try await postService.searchPosts(query: trimmed)
        } catch {
            errorMessage = "Error searching. Try again."
        }
        
        isLoading = false
    }
}
