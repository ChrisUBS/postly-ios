//
//  NavigationScreen.swift
//  Postly
//
//  Created by Christian Bonilla on 19/02/26.
//

enum Screen {
    case home
    case posts
    case profile
    case createPost
    case editPost(id: String)
    case postDetail(slug: String)
}
