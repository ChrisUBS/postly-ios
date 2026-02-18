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
            VStack {
                
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
