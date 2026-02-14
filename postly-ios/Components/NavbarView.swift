//
//  NavbarView.swift
//  Postly
//
//  Created by Christian Bonilla on 05/02/26.
//

import SwiftUI

struct NavbarView: View {
    @Binding var isMenuOpen: Bool

    var body: some View {
        HStack {
            // Logo
            HStack(spacing: 8) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .foregroundColor(.blue)
                Text("Postly")
                    .font(.title3.bold())
            }

            Spacer()

            // Search Icon
            Button(action: {}) {
                Image(systemName: "magnifyingglass")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding(8)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(Circle())
            }

            // Hamburger Menu
            Button(action: {
                withAnimation(.spring()) {
                    isMenuOpen.toggle()
                }
            }) {
                Image(systemName: isMenuOpen ? "xmark" : "line.horizontal.3")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding(8)
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .background(Color.white.opacity(0.95))
    }
}
