//
//  RegisterView.swift
//  Postly
//
//  Created by Christian Bonilla on 17/02/26.
//

import SwiftUI

struct RegisterView: View {
    
    @EnvironmentObject var session: SessionManager
    
    let onSwitchToLogin: () -> Void
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Name
            TextField("Full Name", text: $name)
                .textInputAutocapitalization(.words)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
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
            
            // Register Button
            Button {
                Task {
                    await handleRegister()
                }
            } label: {
                if session.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Register")
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(session.isLoading)
            
            // Switch to Login
            Button {
                onSwitchToLogin()
            } label: {
                Text("Already have an account? Log In")
                    .font(.footnote)
            }
            .padding(.top, 10)
            
        }
        .padding()
    }
    
    private func handleRegister() async {
        errorMessage = nil
        
        if name.isEmpty || email.isEmpty || password.isEmpty {
            errorMessage = "Please fill in all fields."
            return
        }
        
        await session.register(
            name: name,
            email: email,
            password: password
        )
        
        if !session.isAuthenticated {
            errorMessage = "Registration failed."
        }
    }
}
