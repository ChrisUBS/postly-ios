//
//  CommentService.swift
//  Postly
//
//  Created by Christian Bonilla on 14/02/26.
//

import Foundation

final class CommentService {
    
    func getComments(postId: String) async throws -> [Comment] {
        try await APIClient.shared.request(
            endpoint: .getComments(postId: postId)
        )
    }
    
    func createComment(postId: String, content: String) async throws -> Comment {
        
        let body = try JSONEncoder().encode(
            ["content": content]
        )
        
        return try await APIClient.shared.request(
            endpoint: .createComment(postId: postId),
            method: "POST",
            body: body,
            requiresAuth: true
        )
    }
    
    func deleteComment(postId: String, commentId: String) async throws {
        let _: EmptyResponse = try await APIClient.shared.request(
            endpoint: .deleteComment(postId: postId, commentId: commentId),
            method: "DELETE",
            requiresAuth: true
        )
    }
}
