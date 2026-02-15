//
//  AuthManager.swift
//  Postly
//
//  Created by Christian Bonilla on 14/02/26.
//

import Foundation

final class AuthManager {
    
    static let shared = AuthManager()
    
    private init() {}
    
    var accessToken: String? {
        get {
            UserDefaults.standard.string(forKey: "accessToken")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "accessToken")
        }
    }
    
    func logout() {
        accessToken = nil
    }
}
