//
//  PaginatedResponse.swift
//  Postly
//
//  Created by Christian Bonilla on 14/02/26.
//

struct PaginatedResponse<T: Codable>: Codable {
    let posts: [T]
    let pagination: Pagination
}
