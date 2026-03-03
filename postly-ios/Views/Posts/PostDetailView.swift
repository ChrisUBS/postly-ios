//
//  PostDetailView.swift
//  Postly
//
//  Created by Christian Bonilla on 19/02/26.
//

import SwiftUI

struct PostDetailView: View {
    
    let postId: String
    @State private var post: Post?
    @State private var newComment = ""
    @State private var isLoading = true
    @State private var isSubmittingComment = false
    @State private var deletingCommentId: String?
    @State private var pendingDeleteCommentId: String?
    @State private var isLiking = false
    @State private var didLike = false
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var showDeleteAlert = false
    
    @EnvironmentObject private var session: SessionManager
    private let postService = PostService.shared
    private let commentService = CommentService()
    
    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView()
                    .padding(.top, 50)
            } else if let post {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        if let cover = post.coverImage, let url = URL(string: cover) {
                            ZStack(alignment: .bottomLeading) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: 400)
                                            .frame(height: 300)
                                            .clipped()
                                    default:
                                        Rectangle()
                                            .fill(.gray.opacity(0.2))
                                            .frame(height: 300)
                                    }
                                }
                                
                                if isFromPexels(cover) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "camera")
                                        Text("Photo provided by")
                                        Link("Pexels", destination: URL(string: "https://www.pexels.com")!)
                                            .foregroundColor(.white)
                                            .underline()
                                    }
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.black.opacity(0.8))
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text(post.title)
                                .font(.system(size: 48, weight: .bold))
                            
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 10) {
                                    avatarView(urlString: post.author.profilePicture, name: post.author.name)
                                        .frame(width: 42, height: 42)
                                    
                                    Text(post.author.name)
                                        .font(.title3.bold())
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Label(formatDateTime(post.createdAt), systemImage: "calendar")
                                    Label("\(post.readTime) minutes of reading", systemImage: "clock")
                                    Label("\(post.views) views", systemImage: "eye")
                                }
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            }
                            
                            postContent(post.content)
                            
                            Divider()
                            
                            if session.isAuthenticated {
                                Button {
                                    Task { await handleLikeToggle() }
                                } label: {
                                    Label("\(post.likes) Like", systemImage: "hand.thumbsup")
                                        .foregroundColor(didLike ? .blue : .secondary)
                                }
                                .disabled(isLiking)
                            } else {
                                Label("\(post.likes) Like", systemImage: "hand.thumbsup")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                    }
                    
                }
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.08), radius: 6)
                
                commentsSection(post: post)
            }
        }
        .padding(.horizontal, 16)
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Notice", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .alert("Delete comment?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {
                pendingDeleteCommentId = nil
            }
            Button("Delete", role: .destructive) {
                if let commentId = pendingDeleteCommentId {
                    Task { await handleDeleteComment(commentId: commentId) }
                }
                pendingDeleteCommentId = nil
            }
        } message: {
            Text("This action cannot be undone.")
        }
        .task {
            await loadDetails()
        }
    }
    
    private func commentsSection(post: Post) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "message")
                    .foregroundColor(.blue)
                Text("Comments (\(post.comments.count))")
                    .font(.title2.bold())
            }
            
            if session.isAuthenticated {
                HStack(alignment: .top, spacing: 10) {
                    avatarView(urlString: session.profilePictureURL, name: session.userName)
                        .frame(width: 42, height: 42)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        TextEditor(text: $newComment)
                            .frame(height: 100)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        Button {
                            Task { await handleSubmitComment() }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "paperplane")
                                Text(isSubmittingComment ? "Sending..." : "Comment")
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.blue.opacity(0.65))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(isSubmittingComment || newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            } else {
                Text("Sign in to comment")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
            
            if post.comments.isEmpty {
                Text("There are no comments yet. Be the first to comment!")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            } else {
                VStack(spacing: 14) {
                    ForEach(post.comments, id: \._id) { comment in
                        HStack(alignment: .top, spacing: 10) {
                            avatarView(urlString: comment.author.profilePicture, name: comment.author.name)
                                .frame(width: 40, height: 40)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(comment.author.name)
                                        .font(.headline)
                                    
                                    Text(formatDateTime(comment.createdAt))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text(comment.content)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            if canDeleteComment(comment) {
                                Button {
                                    pendingDeleteCommentId = comment._id
                                    showDeleteAlert = true
                                } label: {
                                    if deletingCommentId == comment._id {
                                        ProgressView()
                                    } else {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                                .disabled(deletingCommentId == comment._id)
                            }
                        }
                        .padding(.bottom, 10)
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 6)
    }
    
    private func avatarView(urlString: String?, name: String) -> some View {
        Group {
            if let urlString, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Image(systemName: "person.fill")
                            .font(.system(size: 16))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.gray.opacity(0.2))
                    }
                }
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        Text(initials(for: name))
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                    )
            }
        }
        .clipShape(Circle())
    }
    
    private func postContent(_ content: String) -> some View {
        Text(wrappableText(content))
            .font(.body)
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .clipped()
    }

    private func wrappableText(_ content: String) -> String {
        content.replacingOccurrences(
            of: "(\\S{25})",
            with: "$1\u{200B}",
            options: .regularExpression
        )
    }
    
    private func initials(for name: String) -> String {
        let words = name.split(separator: " ")
        let first = words.first?.first.map(String.init) ?? ""
        let second = words.dropFirst().first?.first.map(String.init) ?? ""
        return (first + second).uppercased()
    }
    
    private func isFromPexels(_ url: String) -> Bool {
        url.contains("images.pexels.com")
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func canDeleteComment(_ comment: Comment) -> Bool {
        guard let userId = session.user?.userId, let post else { return false }
        return comment.author.userId == userId || post.author.userId == userId
    }
    
    @MainActor
    private func handleSubmitComment() async {
        guard
            session.isAuthenticated,
            let post,
            !newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return }
        
        isSubmittingComment = true
        
        do {
            let comment = try await commentService.createComment(
                postId: post._id,
                content: newComment.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            
            if var updatedPost = self.post {
                updatedPost.comments.append(comment)
                self.post = updatedPost
            }
            newComment = ""
        } catch {
            alertMessage = "Error creating comment"
            showAlert = true
        }
        
        isSubmittingComment = false
    }
    
    @MainActor
    private func handleDeleteComment(commentId: String) async {
        guard let post else { return }
        
        deletingCommentId = commentId
        
        do {
            try await commentService.deleteComment(postId: post._id, commentId: commentId)
            if var updatedPost = self.post {
                updatedPost.comments.removeAll(where: { $0._id == commentId })
                self.post = updatedPost
            }
        } catch {
            alertMessage = "Error deleting comment"
            showAlert = true
        }
        
        deletingCommentId = nil
    }
    
    @MainActor
    private func handleLikeToggle() async {
        guard let post else { return }
        isLiking = true
        
        do {
            if didLike {
                try await postService.unlikePost(postId: post._id)
            } else {
                try await postService.likePost(postId: post._id)
            }
            didLike.toggle()
            if var updatedPost = self.post {
                updatedPost.likes = max(0, updatedPost.likes + (didLike ? 1 : -1))
                self.post = updatedPost
            }
        } catch {
            alertMessage = "Error managing like"
            showAlert = true
        }
        
        isLiking = false
    }
    
    @MainActor
    private func loadDetails() async {
        isLoading = true
        do {
            let fetchedPost = try await postService.getPostById(id: postId)
            post = fetchedPost
            if session.isAuthenticated {
                didLike = (try? await postService.checkLike(postId: fetchedPost._id)) ?? false
            } else {
                didLike = false
            }
        } catch {
            alertMessage = "Error loading post. Please try again."
            showAlert = true
        }
        isLoading = false
    }
}
