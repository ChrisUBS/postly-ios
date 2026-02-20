//
//  WelcomeView.swift
//  Postly
//
//  Created by Christian Bonilla on 05/02/26.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var session: SessionManager
    @Binding var selectedScreen: Screen?
    @Binding var showAuthSheet: Bool

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.15), Color.blue.opacity(0.30)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {

                    // MARK: - Title
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)

                            Text("Welcome to Postly")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(Color(.darkGray))
                        }

                        Text("A platform to share ideas, connect with people, and explore fascinating conversations all in one place.")
                            .font(.title3)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 300)
                    }

                    // MARK: - Cards
                    VStack(spacing: 20) {
                        FeatureCard(
                            icon: "pencil.tip",
                            iconColor: .blue,
                            title: "Create Posts",
                            description: "Share your thoughts, stories, and ideas with our community."
                        )

                        FeatureCard(
                            icon: "bubble.left.and.text.bubble.right.fill",
                            iconColor: .green,
                            title: "Explore Conversations",
                            description: "Discover amazing posts and participate in relevant conversations."
                        )

                        FeatureCard(
                            icon: "person.3.fill",
                            iconColor: .purple,
                            title: "Connect",
                            description: "Meet people with similar interests and expand your network."
                        )
                    }
                    .padding(.horizontal)

                    // MARK: - Main Button
                    if session.isAuthenticated {
                        Button(action: {
                            selectedScreen = .posts
                        }) {
                            Label("Explore Posts", systemImage: "bubble.left.and.bubble.right")
                                .font(.title3)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    } else {
                        Button(action: {
                            showAuthSheet = true
                        }) {
                            Label("Join Now", systemImage: "pencil.tip")
                                .font(.title3)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                }
                 .padding(.vertical, 40)
            }
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(iconColor)

            Text(title)
                .font(.title3)
                .fontWeight(.semibold)

            Text(description)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
