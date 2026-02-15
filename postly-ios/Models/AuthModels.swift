//
//  AuthModels.swift
//  Postly
//
//  Created by Christian Bonilla on 14/02/26.
//

import Foundation

struct LoginRequest: Codable {
    let email: String
    let password: String
}
