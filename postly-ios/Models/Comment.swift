//
//  Comment.swift
//  Postly
//
//  Created by Christian Bonilla on 14/02/26.
//

import Foundation

struct Comment: Codable {
    let _id: String
    let content: String
    let author: Author
    let createdAt: Date
    let likes: Int
}
