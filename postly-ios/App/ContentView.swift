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
    @State private var showAuthSheet = false
    @State private var selectedScreen: Screen?

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    NavbarView(isMenuOpen: $isMenuOpen)
                        .padding(.bottom, 10)

                    ScrollView {
                        if selectedScreen == .posts {
                            PostsView()
                        } else {
                            WelcomeView(selectedScreen: $selectedScreen, showAuthSheet: $showAuthSheet)
                        }
                    }
                    .ignoresSafeArea(.container, edges: .bottom)
                }

                if isMenuOpen {
                    HStack(spacing: 0) {
                        SideMenuView(
                            isMenuOpen: $isMenuOpen,
                            showAuthSheet: $showAuthSheet,
                            selectedScreen: $selectedScreen
                        )
                        Spacer()
                    }
                    .transition(.move(edge: .leading))
                }
            }
        }
        .sheet(
            isPresented: Binding(
                get: { showAuthSheet && !session.isAuthenticated },
                set: { showAuthSheet = $0 }
            )
        ) {
            AuthSheetView().environmentObject(session)
        }
    }
}
