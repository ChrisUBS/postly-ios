//
//  User.swift
//  Postly
//
//  Created by Christian Bonilla on 14/02/26.
//

import Foundation

struct User: Codable, Equatable {
    let userId: String
    let name: String
    let email: String?
    let profilePicture: String?
    let lastLogin: Date?
}
