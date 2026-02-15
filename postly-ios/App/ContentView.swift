//
//  ContentView.swift
//  postly-ios
//
//  Created by Christian Bonilla on 05/02/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var session: SessionManager
    @State private var isMenuOpen = false

    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: 0) {
                NavbarView(isMenuOpen: $isMenuOpen)
                    .padding(.bottom, 10)

                ScrollView {
                    WelcomeView()
                }
                .ignoresSafeArea(.container, edges: .bottom)
            }

            // Side Menu overlay
            if isMenuOpen {
                HStack(spacing: 0) {
                    SideMenuView(isMenuOpen: $isMenuOpen)

                    Spacer()
                }
                .transition(.move(edge: .leading))
            }
        }
    }
}


#Preview {
    ContentView()
}
