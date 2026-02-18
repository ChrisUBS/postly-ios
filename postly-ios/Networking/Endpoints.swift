//
//  Endpoints.swift
//  Postly
//
//  Created by Christian Bonilla on 14/02/26.
//

enum Endpoint {
    
    // MARK: - Auth
    case loginEmail
    case registerEmail
    case checkAuth
    
    // MARK: - Posts
    case getPosts(page: Int, limit: Int)
    case getPost(id: String)
    case createPost
    case likePost(id: String)
    
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
            
        case .getPost(let id):
            return "posts/\(id)"
            
        case .createPost:
            return "posts"
            
        case .likePost(let id):
            return "posts/\(id)/like"
            
        case .getComments(let postId):
            return "posts/\(postId)/comments"
            
        case .createComment(let postId):
            return "posts/\(postId)/comments"
            
        case .deleteComment(let postId, let commentId):
            return "posts/\(postId)/comments/\(commentId)"
        }
    }
}
