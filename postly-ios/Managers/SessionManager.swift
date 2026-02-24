//
//  SessionManager.swift
//  Postly
//
//  Created by Christian Bonilla on 15/02/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class SessionManager: ObservableObject {
    
    static let shared = SessionManager()
    
    @Published var user: User?
    @Published var isLoading = false
    
    private let authService = AuthService()
    
    private init() {
        Task {
            await checkSession()
        }
    }
    
    var isAuthenticated: Bool {
        user != nil
    }
    
    var userName: String {
        user?.name ?? "User"
    }

    var email: String {
        user?.email ?? ""
    }

    var profilePictureURL: String? {
        user?.profilePicture
    }
    
    // MARK: - Login
    
    func login(email: String, password: String) async {
        isLoading = true
        
        do {
            let response = try await authService.login(email: email, password: password)
            user = response.user
        } catch {
            print("Login error:", error)
        }
        
        isLoading = false
    }
    
    // MARK: - Register

    func register(name: String, email: String, password: String) async {
        isLoading = true
        
        do {
            let response = try await authService.register(
                name: name,
                email: email,
                password: password
            )
            
            user = response.user
            
        } catch {
            print("Register error:", error)
        }
        
        isLoading = false
    }
    
    // MARK: - Check existing session
    
    func checkSession() async {
        guard AuthManager.shared.accessToken != nil else {
            return
        }
        
        do {
            let currentUser = try await authService.checkAuth()
            user = currentUser
        } catch {
            AuthManager.shared.logout()
            user = nil
        }
    }
    
    // MARK: - Logout
    
    func logout() {
        AuthManager.shared.logout()
        user = nil
    }
}
