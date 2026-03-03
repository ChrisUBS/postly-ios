//
//  NavigationScreen.swift
//  Postly
//
//  Created by Christian Bonilla on 19/02/26.
//

enum Screen: Equatable {
    case home
    case posts
    case search(query: String)
    case profile
    case createPost
    case editPost(id: String)
    case postDetail(slug: String)
}
