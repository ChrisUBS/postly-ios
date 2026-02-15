//
//  Pagination.swift
//  Postly
//
//  Created by Christian Bonilla on 14/02/26.
//

struct Pagination: Codable {
    let total: Int
    let page: Int
    let limit: Int
    let totalPages: Int
}
