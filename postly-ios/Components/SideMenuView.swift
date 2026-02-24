//
//  SideMenuView.swift
//  Postly
//
//  Created by Christian Bonilla on 05/02/26.
//

import SwiftUI

struct SideMenuView: View {
    @Binding var isMenuOpen: Bool
    @Binding var showAuthSheet: Bool
    @Binding var selectedScreen: Screen?
    @EnvironmentObject var session: SessionManager

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            // Logo
            HStack(spacing: 8) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .foregroundColor(.blue)
                Text("Postly")
                    .font(.title.bold())
            }
            .padding(.top, 40)

            Divider()

            // MARK: - Visible only when logged out
            if !session.isAuthenticated {
                // Home
                Button {
                    selectedScreen = .home
                    isMenuOpen = false
                } label: {
                    MenuItem(icon: "house", text: "Home")
                }
            }
            // MARK: - Always visible
            // Posts
            Button {
                selectedScreen = .posts
                isMenuOpen = false
            } label: {
                MenuItem(icon: "bubble.left", text: "Posts")
            }

            // MARK: - Visible only when logged in
            if session.isAuthenticated {
                // Create Post
                Button {
                    selectedScreen = .createPost
                    isMenuOpen = false
                } label: {
                    MenuItem(icon: "pencil.tip", text: "Create Post")
                }
                // My Profile
                Button {
                    selectedScreen = .profile
                    isMenuOpen = false
                } label: {
                    MenuItem(icon: "person.crop.circle", text: "My Profile")
                }
            }

            Spacer()

            // MARK: - Login or logout
            if session.isAuthenticated {
                Button {
                    session.logout()
                    isMenuOpen = false
                } label: {
                    Text("Log Out")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            } else {
                Button {
                    isMenuOpen = false
                    showAuthSheet = true
                } label: {
                    Text("Log In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal)
        .frame(width: 280, alignment: .leading)
        .frame(maxHeight: .infinity)
        .background(Color.white)
    }
}

struct MenuItem: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .font(.title3)

            Text(text)
                .font(.title3)
        }
        .padding(.vertical, 4)
    }
}
