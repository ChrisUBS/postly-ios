//
//  Post.swift
//  Postly
//
//  Created by Christian Bonilla on 14/02/26.
//

import Foundation

struct Post: Codable, Identifiable {
    let _id: String
    var id: String { _id }
    let title: String
    let content: String
    let author: Author
    let slug: String
    let createdAt: Date
    let updatedAt: Date
    let status: String
    let readTime: Int
    let views: Int
    var likes: Int
    var comments: [Comment]
    let coverImage: String?
    
    var createdAtFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: createdAt)
    }
}
