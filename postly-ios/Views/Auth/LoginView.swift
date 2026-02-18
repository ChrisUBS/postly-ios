//
//  LoginView.swift
//  Postly
//
//  Created by Christian Bonilla on 17/02/26.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var session: SessionManager
    
    let onSwitchToRegister: () -> Void
    
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Email
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            // Password
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            // Error
            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }
            
            // Login Button
            Button {
                Task {
                    await handleLogin()
                }
            } label: {
                if session.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Log In")
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(session.isLoading)
            
            // Switch to Register
            Button {
                onSwitchToRegister()
            } label: {
                Text("Don't have an account? Register")
                    .font(.footnote)
            }
            .padding(.top, 10)
            
        }
        .padding()
    }
    
    private func handleLogin() async {
        errorMessage = nil
        
        if email.isEmpty || password.isEmpty {
            errorMessage = "Please fill in all fields."
            return
        }
        
        await session.login(email: email, password: password)
        
        if !session.isAuthenticated {
            errorMessage = "Invalid email or password."
        }
    }
}
