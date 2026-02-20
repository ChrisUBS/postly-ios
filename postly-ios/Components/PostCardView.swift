//
//  PostCardView.swift
//  Postly
//
//  Created by Christian Bonilla on 19/02/26.
//

import SwiftUI

struct PostCardView: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // MARK: - Cover Image
            if let cover = post.coverImage, let url = URL(string: cover) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 180)
                            .clipped()
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 180)
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 180)
                    @unknown default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 180)
                    }
                }
            }
            
            // MARK: - Content
            VStack(alignment: .leading, spacing: 8) {
                Text(post.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(post.content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(post.coverImage == nil ? 6 : 3)
            }
            .padding()
            
            Divider()
            
            // MARK: - Metadata Footer
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "calendar")
                        Text(formatDate(post.createdAt))
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                    
                    HStack {
                        Image(systemName: "clock")
                        Text("\(post.readTime) min")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "hand.thumbsup")
                        Text("\(post.likes)")
                    }
                    .font(.caption)
                    
                    HStack {
                        Image(systemName: "text.bubble")
                        Text("\(post.comments.count)")
                    }
                    .font(.caption)
                }
                .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 3)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
}
