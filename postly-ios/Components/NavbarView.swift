//
//  NavbarView.swift
//  Postly
//
//  Created by Christian Bonilla on 05/02/26.
//

import SwiftUI

struct NavbarView: View {
    @Binding var isMenuOpen: Bool
    @Binding var isSearchExpanded: Bool
    @Binding var selectedScreen: Screen?
    var onSearchSubmit: (String) -> Void
    
    @State private var query = ""

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
            if isSearchExpanded {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search posts...", text: $query)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onSubmit {
                            submitSearch()
                        }
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isSearchExpanded = false
                            if selectedScreen == .search(query: query) {
                                selectedScreen = .posts
                            }
                            query = ""
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .frame(maxWidth: 320)
                .background(Color(.systemGray6))
                .cornerRadius(14)
            } else {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isSearchExpanded = true
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .padding(8)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(Circle())
                }
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
    
    private func submitSearch() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onSearchSubmit(trimmed)
    }
}
