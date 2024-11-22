//
//  MovieListView.swift
//  MovieRecommender
//
//  Created by Ramazan Üsen on 21.11.2024.
//


import SwiftUI

struct MovieListView: View {
    @State private var movies: [Movie] = []
    @State private var searchQuery: String = ""
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Search for movies...", text: $searchQuery, onCommit: searchMovies)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }

                List(movies) { movie in
                    NavigationLink(destination: MovieDetailView(movie: movie)) {
                        HStack {
                            if let url = movie.posterURL {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 100, height: 150)
                                .cornerRadius(8)
                            }
                            VStack(alignment: .leading) {
                                Text(movie.title)
                                    .font(.headline)
                                Text(movie.overview)
                                    .font(.subheadline)
                                    .lineLimit(3)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .navigationTitle("Movies")
                .onAppear(perform: fetchPopularMovies)
            }
        }
    }

    private func fetchPopularMovies() {
        isLoading = true
        NetworkManager.shared.fetchPopularMovies { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let movies):
                    self.movies = movies
                    self.isLoading = false
                case .failure(let error):
                    print("Error fetching popular movies: \(error)")
                }
            }
        }
    }

    private func searchMovies() {
        guard !searchQuery.isEmpty else {
            fetchPopularMovies()
            return
        }

        isLoading = true
        NetworkManager.shared.searchMovies(query: searchQuery) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let movies):
                    self.movies = movies
                    self.isLoading = false
                case .failure(let error):
                    print("Error searching for movies: \(error)")
                }
            }
        }
    }
}
