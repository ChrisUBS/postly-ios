//
//  PostService.swift
//  Postly
//
//  Created by Christian Bonilla on 14/02/26.
//

import Foundation

final class PostService {
    
    static let shared = PostService()
    
    func getAllPosts(page: Int = 1, limit: Int = 10) async throws -> PaginatedResponse<Post> {
        try await APIClient.shared.request(
            endpoint: .getPosts(page: page, limit: limit)
        )
    }
    
    func getPostById(id: String) async throws -> Post {
        try await APIClient.shared.request(
            endpoint: .getPost(id: id)
        )
    }
    
    func getMyPosts() async throws -> PaginatedResponse<Post> {
        try await APIClient.shared.request(
            endpoint: .getMyPosts,
            requiresAuth: true
        )
    }
    
    func deletePost(id: String) async throws {
        let _: EmptyResponse = try await APIClient.shared.request(
            endpoint: .deletePost(id: id),
            method: "DELETE",
            requiresAuth: true
        )
    }
    
    func createPost(title: String, content: String, status: String? = nil, coverImage: String? = nil) async throws -> Post {
        
        let bodyDict: [String: Any?] = [
            "title": title,
            "content": content,
            "status": status,
            "coverImage": coverImage
        ]
        
        let body = try JSONSerialization.data(withJSONObject: bodyDict.compactMapValues { $0 })
        
        return try await APIClient.shared.request(
            endpoint: .createPost,
            method: "POST",
            body: body,
            requiresAuth: true
        )
    }

    func updatePost(id: String, title: String, content: String, status: String? = nil, coverImage: String? = nil) async throws -> Post {
        
        var bodyDict: [String: Any] = [
            "title": title,
            "content": content,
            "coverImage": coverImage ?? NSNull()
        ]
        if let status {
            bodyDict["status"] = status
        }
        
        let body = try JSONSerialization.data(withJSONObject: bodyDict)
        
        return try await APIClient.shared.request(
            endpoint: .updatePost(id: id),
            method: "PUT",
            body: body,
            requiresAuth: true
        )
    }
    
    func likePost(postId: String) async throws {
        let _: EmptyResponse = try await APIClient.shared.request(
            endpoint: .likePost(id: postId),
            method: "POST",
            requiresAuth: true
        )
    }
}

struct EmptyResponse: Codable {}
