//
//  GenreListView.swift
//  MovieRecommender
//
//  Created by Ramazan Üsen on 22.11.2024.
//

import SwiftUI

struct GenreListView: View {
    @State private var genres: [Genre] = []
    @State private var selectedGenre: Genre?
    @State private var movies: [Movie] = []
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            VStack {
                Picker("Select Genre", selection: $selectedGenre) {
                    Text("All Genres").tag(Genre?.none)
                    ForEach(genres) { genre in
                        Text(genre.name).tag(Genre?.some(genre))
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()

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
                .navigationTitle("Movies by Genre")
                .onAppear(perform: fetchGenres)
                .onChange(of: selectedGenre) { _ in
                    fetchMovies()
                }
            }
        }
    }

    private func fetchGenres() {
        isLoading = true
        NetworkManager.shared.fetchGenres { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let genres):
                    self.genres = genres
                    self.selectedGenre = nil
                case .failure(let error):
                    print("Error fetching genres: \(error)")
                }
                self.isLoading = false
            }
        }
    }

    private func fetchMovies() {
        guard let selectedGenre = selectedGenre else {
            fetchPopularMovies()
            return
        }

        isLoading = true
        NetworkManager.shared.fetchMoviesByGenre(genreID: selectedGenre.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let movies):
                    self.movies = movies
                case .failure(let error):
                    print("Error fetching movies by genre: \(error)")
                }
                self.isLoading = false
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
                case .failure(let error):
                    print("Error fetching popular movies: \(error)")
                }
                self.isLoading = false
            }
        }
    }
}
