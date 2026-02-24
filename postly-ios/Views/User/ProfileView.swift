//
//  ProfileView.swift
//  Postly
//
//  Created by Christian Bonilla on 23/02/26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var session: SessionManager
    @State private var posts: [Post] = []
    @State private var loading = true
    @State private var error: String?
    @State private var showingDeleteAlert: Bool = false
    @Binding var selectedScreen: Screen?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: - Profile Card
                profileCard
                
                // MARK: - My Publications
                publicationsSection
            }
            .padding()
        }
        .onAppear {
            Task {
                await loadMyPosts()
            }
        }
    }
    
    // MARK: - LOAD POSTS
    private func loadMyPosts() async {
        loading = true
        error = nil
        
        do {
            let response = try await PostService.shared.getMyPosts()
            await MainActor.run {
                self.posts = response.posts
                self.loading = false
            }
        } catch {
            await MainActor.run {
                self.error = "Failed to load your publications."
                self.loading = false
            }
        }
    }
    
    // MARK: - DELETE POST
    private func deletePost(_ id: String) {
        Task {
            do {
                try await PostService.shared.deletePost(id: id)
                await loadMyPosts()
            } catch {
                print("❌ Error deleting post:", error)
            }
        }
    }
}

extension ProfileView {
    private var profileCard: some View {
        VStack(spacing: 12) {
            
            // Profile image
            if let image = session.profilePictureURL {
                AsyncImage(url: URL(string: image)) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    )
            }
            
            Text(session.userName)
                .font(.system(size: 28, weight: .bold))
            
            Text(session.email)
                .foregroundColor(.gray)
            
            Button {
                selectedScreen = .createPost
            } label: {
                Label("New post", systemImage: "pencil.tip")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.top, 8)
            
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10)
    }
}

extension ProfileView {
    private var publicationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack {
                Image(systemName: "doc.text")
                    .foregroundColor(.blue)
                    .font(.system(size: 22))
                Text("My publications")
                    .font(.title2)
                    .bold()
            }
            .padding(.bottom, 4)
            
            if loading {
                ProgressView().padding(.vertical, 40)
            }
            else if let error = error {
                Text(error)
                    .foregroundColor(.red)
            }
            else if posts.isEmpty {
                VStack(spacing: 10) {
                    Text("You haven't created any posts yet.")
                        .foregroundColor(.gray)
                    Button {
                        selectedScreen = .createPost
                    } label: {
                        Label("Create new post", systemImage: "pencil")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
            }
            else {
                VStack(spacing: 12) {
                    ForEach(posts) { post in
                        postRow(post)
                    }
                }
            }
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8)
    }
}

extension ProfileView {
    private func postRow(_ post: Post) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(post.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .onTapGesture {
                        selectedScreen = .postDetail(slug: post.slug)
                    }
                Spacer()
                
                // Edit Button
                Button {
                    selectedScreen = .editPost(id: post.id)
                } label: {
                    Image(systemName: "pencil")
                        .padding(8)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                // Delete Button
                Button {
                    showingDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            
            HStack(spacing: 16) {
                Text(post.createdAtFormatted)
                if post.status == "published" {
                    Label("Published", systemImage: "circle.fill")
                        .foregroundColor(.green)
                        .font(.subheadline)
                } else {
                    Label("Draft", systemImage: "circle.fill")
                        .foregroundColor(.orange)
                        .font(.subheadline)
                }
                Text("\(post.comments.count) comments")
                Text("\(post.views) views")
            }
            .font(.subheadline)
            .foregroundColor(.gray)
            
            Divider()
        }
        .padding(.vertical, 4)
        .alert("Are you sure you want to delete this post?",
               isPresented: $showingDeleteAlert) {

            Button("Cancel", role: .cancel) { }

            Button("Delete", role: .destructive) {
                deletePost(post.id)
            }

        } message: {
            Text("This action cannot be undone.")
        }
    }
}
