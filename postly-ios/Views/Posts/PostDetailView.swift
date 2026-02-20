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
    @State private var isLoading = true
    
    private let service = PostService()
    
    var body: some View {
        ScrollView {
            if let post = post {
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    if let cover = post.coverImage, let url = URL(string: cover) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                            default:
                                Rectangle().fill(.gray.opacity(0.3))
                            }
                        }
                    }
                    
                    Text(post.title)
                        .font(.title.bold())
                    
                    Text(post.content)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    HStack {
                        Label("\(post.likes)", systemImage: "hand.thumbsup")
                        Label("\(post.comments.count)", systemImage: "text.bubble")
                    }
                    .foregroundColor(.gray)
                    
                }
                .padding()
                
            } else if isLoading {
                ProgressView()
                    .padding(.top, 50)
            }
        }
        .navigationTitle("Post")
        .task {
            await loadDetails()
        }
    }
    
    private func loadDetails() async {
        isLoading = true
        do {
            post = try await service.getPostById(id: postId)
        } catch {
            print("Post detail error:", error)
        }
        isLoading = false
    }
}
