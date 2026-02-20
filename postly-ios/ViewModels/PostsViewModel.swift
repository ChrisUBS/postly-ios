//
//  PostsViewModel.swift
//  Postly
//
//  Created by Christian Bonilla on 19/02/26.
//

import Foundation
import Combine

@MainActor
final class PostsViewModel: ObservableObject {
    
    @Published var posts: [Post] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var page: Int = 1
    @Published var totalPages: Int = 1
    
    private let postService = PostService()
    
    func fetchPosts(reset: Bool = false) async {
        if isLoading { return }
        
        if reset {
            page = 1
            posts = []
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await postService.getAllPosts(page: page, limit: 10)
            
            if reset {
                posts = response.posts
            } else {
                posts.append(contentsOf: response.posts)
            }
            
            totalPages = response.pagination.totalPages
            
        } catch {
            errorMessage = "Failed to load posts."
        }
        
        isLoading = false
    }
    
    func loadMore() async {
        guard page < totalPages else { return }
        page += 1
        await fetchPosts()
    }
}
