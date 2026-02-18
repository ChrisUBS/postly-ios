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

    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: 0) {
                NavbarView(isMenuOpen: $isMenuOpen)
                    .padding(.bottom, 10)

                ScrollView {
                    WelcomeView(showAuthSheet: $showAuthSheet)
                }
                .ignoresSafeArea(.container, edges: .bottom)
            }

            // Side Menu overlay
            if isMenuOpen {
                HStack(spacing: 0) {
                    SideMenuView(
                        isMenuOpen: $isMenuOpen,
                        showAuthSheet: $showAuthSheet
                    )

                    Spacer()
                }
                .transition(.move(edge: .leading))
            }
        }
        .sheet(
            isPresented: Binding(
                get: { showAuthSheet && !session.isAuthenticated },
                set: { showAuthSheet = $0 }
            )
        ) {
            AuthSheetView()
                .environmentObject(session)
        }
    }
}


#Preview {
    ContentView()
}
