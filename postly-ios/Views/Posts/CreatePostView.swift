//
//  CreatePostView.swift
//  Postly
//
//  Created by Christian Bonilla on 23/02/26.
//

import SwiftUI

struct CreatePostView: View {

    @EnvironmentObject var session: SessionManager
    @Binding var selectedScreen: Screen?
    
    @State private var title = ""
    @State private var content = ""
    @State private var status: String = "published"
    @State private var loading = false
    @State private var alertMessage = ""
    @State private var showAlert = false

    // Pexels
    @State private var recommendedImages: [PexelsPhoto] = []
    @State private var selectedImage: PexelsPhoto?
    @State private var isLoadingImages = false

    private let pexelsService = PexelsService()

    // Debounce timer
    @State private var debounceWorkItem: DispatchWorkItem?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // MARK: Header
                VStack(spacing: 8) {
                    Text("Create new publication")
                        .font(.system(size: 25, weight: .bold))

                    Text("Share your ideas with the Postly community")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

                // MARK: Title
                VStack(alignment: .leading) {
                    Text("Title")
                        .font(.headline)

                    TextField("Write an attractive title...", text: $title)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                // MARK: PEXELS SECTION
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "photo")
                            .foregroundColor(.blue)
                        Text("Cover image (optional)")
                            .font(.headline)
                        Spacer()
                    }

                    // Selected Image
                    if let selected = selectedImage {
                        VStack {
                            AsyncImage(url: URL(string: selected.src.large)) { img in
                                img.resizable().scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(12)
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    selectedImage = nil
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
                        } else {
                            if recommendedImages.isEmpty {
                                Text("No images found for \"\(title)\"")
                                    .foregroundColor(.gray)
                            } else {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {

                                    ForEach(recommendedImages) { img in
                                        Button {
                                            selectedImage = img
                                        } label: {
                                            VStack(spacing: 4) {
                                                AsyncImage(url: URL(string: img.src.medium)) { img2 in
                                                    img2.resizable().scaledToFill()
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                                .frame(height: 90)
                                                .clipped()
                                                .cornerRadius(8)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(selectedImage?.id == img.id ? Color.blue : Color.clear, lineWidth: 2)
                                                )
                                            }
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }

                        Text("Images provided by Pexels")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }

                }
                .padding(.horizontal)

                // MARK: CONTENT
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

                // MARK: Info section
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

                // MARK: Status options
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

                // MARK: Buttons
                HStack {
                    Button {
                        clearForm()
                        selectedScreen = .profile
                    } label: {
                        Text("Cancel")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                    }

                    Button {
                        Task { await createPost() }
                    } label: {
                        Text(status == "published" ? "Post" : "Save draft")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(loading)
                }
                .padding(.horizontal)

            }
            .padding(.bottom, 40)
        }
        .onChange(of: title) { newValue, old in
            debounceSearch()
        }
        .alert("Notice", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    // Helpers
    private var wordCount: Int {
        content.split { $0 == " " || $0.isNewline }.count
    }

    private var readingTime: Int {
        max(1, wordCount / 200)
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
            print("Error:", error)
        }
        isLoadingImages = false
    }

    private func clearForm() {
        title = ""
        content = ""
        selectedImage = nil
        status = "published"
    }

    @MainActor
    private func createPost() async {
        if title.trimmingCharacters(in: .whitespaces).isEmpty ||
            content.trimmingCharacters(in: .whitespaces).isEmpty {
            alertMessage = "Title and content are required"
            showAlert = true
            return
        }

        loading = true

        do {
            let cover = selectedImage?.src.large

            _ = try await PostService.shared.createPost(
                title: title,
                content: content,
                status: status,
                coverImage: cover
            )

            clearForm()
            selectedScreen = .profile

        } catch {
            alertMessage = "Error creating post"
            showAlert = true
        }

        loading = false
    }
}


// MARK: RADIO BUTTON
struct RadioButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "circle.inset.filled" : "circle")
                Text(label)
            }
            .foregroundColor(.black)
        }
    }
}
