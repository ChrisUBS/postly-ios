//
//  AuthService.swift
//  Postly
//
//  Created by Christian Bonilla on 14/02/26.
//

import Foundation

final class AuthService {
    
    func login(email: String, password: String) async throws -> AuthResponse {
        
        let body = try JSONEncoder().encode(
            LoginRequest(email: email, password: password)
        )
        
        let response: AuthResponse = try await APIClient.shared.request(
            endpoint: .loginEmail,
            method: "POST",
            body: body
        )
        
        AuthManager.shared.accessToken = response.accessToken
        
        return response
    }
    
    func register(name: String, email: String, password: String) async throws -> AuthResponse {
        
        let body = try JSONEncoder().encode(
            [
                "name": name,
                "email": email,
                "password": password
            ]
        )
        
        let response: AuthResponse = try await APIClient.shared.request(
            endpoint: .registerEmail, // asegúrate que exista
            method: "POST",
            body: body
        )
        
        AuthManager.shared.accessToken = response.accessToken
        
        return response
    }
    
    func checkAuth() async throws -> User {
        try await APIClient.shared.request(
            endpoint: .checkAuth,
            requiresAuth: true
        )
    }
}
