//
//  MovieDetailView.swift
//  MovieRecommender
//
//  Created by Ramazan Üsen on 21.11.2024.
//

import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    @State private var recommendations: [Movie] = []
    @State private var isLoadingRecommendations = true
    @State private var isBookmarked = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Poster Image
                if let url = movie.posterURL {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit() // Maintain aspect ratio
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width) // Adjust width dynamically
                    .cornerRadius(8) // Optional: Add rounded corners
                    .padding(.horizontal) // Add horizontal padding for better alignment
                }

                // Movie Title
                Text(movie.title)
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 16)
                    .padding(.horizontal)

                // Bookmark Button
                Button(action: toggleBookmark) {
                    Label(isBookmarked ? "Remove Bookmark" : "Add Bookmark", systemImage: isBookmarked ? "bookmark.fill" : "bookmark")
                        .padding()
                        .background(isBookmarked ? Color.red.opacity(0.2) : Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                // Release Date and Rating
                Text("Release Date: \(movie.releaseDate ?? "N/A")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                Text(movie.overview)
                    .font(.body)
                    .padding(.horizontal)
                    .padding(.top, 8)

                // Recommendations Section
                if !recommendations.isEmpty {
                    Text("Recommended Movies")
                        .font(.title2)
                        .bold()
                        .padding(.top, 16)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(recommendations) { recommendation in
                                NavigationLink(destination: MovieDetailView(movie: recommendation)) {
                                    VStack {
                                        if let url = recommendation.posterURL {
                                            AsyncImage(url: url) { image in
                                                image.resizable()
                                            } placeholder: {
                                                ProgressView()
                                            }
                                            .frame(width: 100, height: 150)
                                            .cornerRadius(8)
                                        }
                                        Text(recommendation.title)
                                            .font(.caption)
                                            .lineLimit(1)
                                    }
                                    .padding(.trailing, 8)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                } else if isLoadingRecommendations {
                    ProgressView()
                        .padding()
                }
            }
        }
        .navigationTitle("Movie Details")
        .onAppear {
            isBookmarked = BookmarkManager.shared.getBookmarks().contains(where: { $0.id == movie.id })
            fetchRecommendations()
        }
    }

    private func toggleBookmark() {
        if isBookmarked {
            BookmarkManager.shared.removeBookmark(movie)
        } else {
            BookmarkManager.shared.addBookmark(movie)
        }
        isBookmarked.toggle()
    }

    private func fetchRecommendations() {
        NetworkManager.shared.fetchRecommendations(for: movie.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let movies):
                    self.recommendations = movies
                    self.isLoadingRecommendations = false
                case .failure(let error):
                    print("Error fetching recommendations: \(error)")
                    self.isLoadingRecommendations = false
                }
            }
        }
    }
}
