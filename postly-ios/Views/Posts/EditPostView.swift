//
//  EditPostView.swift
//  Postly
//
//  Created by Christian Bonilla on 03/03/26.
//

import SwiftUI

struct EditPostView: View {
    
    @EnvironmentObject var session: SessionManager
    let postId: String
    @Binding var selectedScreen: Screen?
    
    @State private var post: Post?
    @State private var title = ""
    @State private var content = ""
    @State private var status: String = "published"
    @State private var currentCoverImage: String?
    
    @State private var recommendedImages: [PexelsPhoto] = []
    @State private var selectedImage: PexelsPhoto?
    @State private var isLoadingImages = false
    
    @State private var isLoading = true
    @State private var saving = false
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var debounceWorkItem: DispatchWorkItem?
    
    private let pexelsService = PexelsService()
    
    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView()
                    .padding(.top, 60)
            } else {
                VStack(alignment: .leading, spacing: 24) {
                    
                    VStack(spacing: 8) {
                        HStack(spacing: 10) {
                            Image(systemName: "pencil.square")
                                .foregroundColor(.blue)
                                .font(.title2)
                            Text("Edit publication")
                                .font(.system(size: 25, weight: .bold))
                        }
                        Text("Update your Postly publication")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("Title")
                            .font(.headline)
                        
                        TextField("Write an attractive title...", text: $title)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "photo")
                                .foregroundColor(.blue)
                            Text("Cover image (optional)")
                                .font(.headline)
                            Spacer()
                        }
                        
                        if currentCoverImage != nil || selectedImage != nil {
                            VStack {
                                AsyncImage(url: URL(string: selectedImage?.src.large ?? currentCoverImage ?? "")) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(12)
                                .overlay(alignment: .topTrailing) {
                                    Button {
                                        handleRemoveImage()
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding(10)
                                            .background(Color.red)
                                            .clipShape(Circle())
                                    }
                                    .padding(8)
                                }
                                .contentShape(Rectangle())
                            }
                        }
                        
                        if !title.isEmpty {
                            Text("Suggested images (Pexels)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            if isLoadingImages {
                                HStack {
                                    ProgressView()
                                    Text("Loading images...")
                                }
                            } else if recommendedImages.isEmpty {
                                Text("No images found for \"\(title)\"")
                                    .foregroundColor(.gray)
                            } else {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                                    ForEach(recommendedImages) { image in
                                        Button {
                                            selectedImage = image
                                            currentCoverImage = nil
                                        } label: {
                                            VStack(spacing: 6) {
                                                AsyncImage(url: URL(string: image.src.medium)) { img in
                                                    img.resizable().scaledToFill()
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                                .frame(height: 90)
                                                .clipped()
                                                .cornerRadius(8)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(selectedImage?.id == image.id ? Color.blue : Color.clear, lineWidth: 2)
                                                )
                                                
                                                Text("By: \(image.photographer)")
                                                    .font(.caption)
                                                    .lineLimit(1)
                                            }
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            
                            Text("Images provided by Pexels")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("Content")
                            .font(.headline)
                        
                        TextEditor(text: $content)
                            .frame(height: 240)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: "text.alignleft")
                            Text("Words: \(wordCount)")
                        }
                        Spacer()
                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                            Text("Reading time: ~\(readingTime) min")
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("Status")
                            .font(.headline)
                        
                        HStack(spacing: 20) {
                            RadioButton(label: "Post", isSelected: status == "published") {
                                status = "published"
                            }
                            
                            RadioButton(label: "Save as draft", isSelected: status == "draft") {
                                status = "draft"
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Button {
                            selectedScreen = .profile
                        } label: {
                            Text("Cancel")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray5))
                                .cornerRadius(12)
                        }
                        .disabled(saving)
                        
                        Button {
                            Task { await saveChanges() }
                        } label: {
                            if saving {
                                ProgressView()
                                    .tint(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                HStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.down")
                                    Text("Save changes")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                            }
                        }
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .disabled(saving)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 20)
            }
        }
        .onAppear {
            Task {
                await loadPost()
            }
        }
        .onChange(of: title) { _, _ in
            debounceSearch()
        }
        .alert("Notice", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var wordCount: Int {
        content.split { $0 == " " || $0.isNewline }.count
    }
    
    private var readingTime: Int {
        max(1, wordCount / 200)
    }
    
    private func handleRemoveImage() {
        selectedImage = nil
        currentCoverImage = nil
    }
    
    @MainActor
    private func loadPost() async {
        guard session.isAuthenticated else {
            alertMessage = "You must be logged in"
            showAlert = true
            isLoading = false
            return
        }
        
        isLoading = true
        
        do {
            let fetchedPost = try await PostService.shared.getPostById(id: postId)
            
            guard fetchedPost.author.userId == session.user?.userId else {
                alertMessage = "You don't have permission to edit this post."
                showAlert = true
                isLoading = false
                return
            }
            
            post = fetchedPost
            title = fetchedPost.title
            content = fetchedPost.content
            status = fetchedPost.status
            currentCoverImage = fetchedPost.coverImage
            isLoading = false
        } catch {
            alertMessage = "Error loading post."
            showAlert = true
            isLoading = false
        }
    }
    
    private func debounceSearch() {
        debounceWorkItem?.cancel()
        
        let workItem = DispatchWorkItem {
            Task {
                await loadPexels()
            }
        }
        
        debounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
    
    @MainActor
    private func loadPexels() async {
        guard !title.isEmpty else {
            recommendedImages.removeAll()
            return
        }
        
        isLoadingImages = true
        do {
            recommendedImages = try await pexelsService.searchImages(query: title)
        } catch {
            recommendedImages = []
        }
        isLoadingImages = false
    }
    
    @MainActor
    private func saveChanges() async {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Title and content are required"
            showAlert = true
            return
        }
        
        saving = true
        
        do {
            let updatedPost = try await PostService.shared.updatePost(
                id: postId,
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                content: content.trimmingCharacters(in: .whitespacesAndNewlines),
                status: status,
                coverImage: selectedImage?.src.large ?? currentCoverImage
            )
            post = updatedPost
            selectedScreen = .profile
        } catch {
            alertMessage = "Error updating post. Try again."
            showAlert = true
        }
        
        saving = false
    }
}
