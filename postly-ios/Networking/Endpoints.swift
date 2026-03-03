//
//  Endpoints.swift
//  Postly
//
//  Created by Christian Bonilla on 14/02/26.
//

import Foundation

enum Endpoint {
    
    // MARK: - Auth
    case loginEmail
    case registerEmail
    case checkAuth
    
    // MARK: - Posts
    case getPosts(page: Int, limit: Int)
    case searchPosts(query: String)
    case getPost(id: String)
    case createPost
    case updatePost(id: String)
    case likePost(id: String)
    case unlikePost(id: String)
    case checkLike(id: String)

    // MARK: - User
    case getMyPosts
    case deletePost(id: String)

    // MARK: - Comments
    case getComments(postId: String)
    case createComment(postId: String)
    case deleteComment(postId: String, commentId: String)
    
    var path: String {
        switch self {
            
        case .loginEmail:
            return "auth/login/email"
            
        case .registerEmail:
            return "auth/register"
            
        case .checkAuth:
            return "auth/check"
            
        case .getPosts(let page, let limit):
            return "posts?page=\(page)&limit=\(limit)"

        case .searchPosts(let query):
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            return "posts/search?q=\(encodedQuery)"
            
        case .getPost(let id):
            return "posts/\(id)"
            
        case .createPost:
            return "posts"

        case .updatePost(let id):
            return "posts/\(id)"
            
        case .likePost(let id):
            return "posts/\(id)/like"

        case .unlikePost(let id):
            return "posts/\(id)/like"

        case .checkLike(let id):
            return "posts/\(id)/like"
            
        case .getMyPosts:
            return "users/me/posts"
            
        case .deletePost(let id):
            return "posts/\(id)"
            
        case .getComments(let postId):
            return "posts/\(postId)/comments"
            
        case .createComment(let postId):
            return "posts/\(postId)/comments"
            
        case .deleteComment(let postId, let commentId):
            return "posts/\(postId)/comments/\(commentId)"
        }
    }
}
