//
//  PostsView.swift
//  Postly
//
//  Created by Christian Bonilla on 19/02/26.
//

import SwiftUI

struct PostsView: View {
    
    @EnvironmentObject var session: SessionManager
    @StateObject private var vm = PostsViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: - Header
                    VStack(spacing: 8) {
                        Text("Recent Posts")
                            .font(.largeTitle.weight(.bold))
                        Text("Explore the most interesting conversations")
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // MARK: - Content
                    if vm.isLoading && vm.posts.isEmpty {
                        ProgressView()
                            .padding(.top, 50)
                    } else if let error = vm.errorMessage {
                        VStack {
                            Text(error)
                                .foregroundColor(.red)
                            Button("Retry") {
                                Task { await vm.fetchPosts(reset: true) }
                            }
                            .padding(.top, 8)
                        }
                    } else {
                        LazyVStack(spacing: 25) {
                            ForEach(vm.posts, id: \._id) { post in
                                NavigationLink {
                                    PostDetailView(postId: post._id)
                                        .environmentObject(session)
                                } label: {
                                    PostCardView(post: post)
                                        .padding(.horizontal)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            // MARK: Load More Pagination
                            if vm.page < vm.totalPages {
                                ProgressView()
                                    .padding()
                                    .onAppear {
                                        Task { await vm.loadMore() }
                                    }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .task {
                await vm.fetchPosts(reset: true)
            }
        }
    }
}
