//
//  SideMenuView.swift
//  Postly
//
//  Created by Christian Bonilla on 05/02/26.
//

import SwiftUI

struct SideMenuView: View {
    @Binding var isMenuOpen: Bool
    @State private var isLoggedIn = false

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

            // Home
            MenuItem(icon: "house", text: "Home")

            // Posts
            MenuItem(icon: "bubble.left", text: "Posts")

            Spacer()

            // Login button
            Button(action: {
                print("Login action")
            }) {
                Text("Log In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.bottom, 40)

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
