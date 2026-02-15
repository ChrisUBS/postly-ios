//
//  AuthResponse.swift
//  Postly
//
//  Created by Christian Bonilla on 14/02/26.
//

struct AuthResponse: Codable {
    let accessToken: String
    let user: User
}
