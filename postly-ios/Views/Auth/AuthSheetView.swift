//
//  AuthSheetView.swift
//  Postly
//
//  Created by Christian Bonilla on 17/02/26.
//

import SwiftUI

struct AuthSheetView: View {
    
    enum AuthMode {
        case login
        case register
    }
    
    @State private var mode: AuthMode = .login
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                    
                    Text("Postly")
                        .font(.title.bold())
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 16)
                
                AuthModeHeader(mode: mode)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                
                if mode == .login {
                    LoginView(
                        onSwitchToRegister: {
                            mode = .register
                        }
                    )
                } else {
                    RegisterView(
                        onSwitchToLogin: {
                            mode = .login
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationTitle(mode == .login ? "Log In" : "Register")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct AuthModeHeader: View {
    let mode: AuthSheetView.AuthMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(mode == .login ? "Welcome back" : "Create your account")
                .font(.title2.bold())
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(items, id: \.title) { item in
                    HStack(spacing: 10) {
                        Image(systemName: item.icon)
                            .foregroundColor(.blue)
                            .frame(width: 22)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.subheadline.bold())
                            
                            Text(item.subtitle)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(14)
    }
    
    private var items: [(icon: String, title: String, subtitle: String)] {
        if mode == .login {
            return [
                ("doc.text.magnifyingglass", "Continue your drafts", "Pick up your posts where you left off."),
                ("person.2.wave.2", "Rejoin the community", "Jump back into conversations and comments.")
            ]
        }
        
        return [
            ("sparkles", "Share ideas faster", "Create and publish your first post in minutes."),
            ("person.crop.circle.badge.plus", "Build your profile", "Connect with readers and grow your audience.")
        ]
    }
}
