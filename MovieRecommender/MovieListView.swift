//
//  MovieListView.swift
//  MovieRecommender
//
//  Created by Ramazan Üsen on 21.11.2024.
//


import SwiftUI

struct MovieListView: View {
    @State private var popularMovies: [Movie] = []
    @State private var trendingMovies: [Movie] = []
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

                ScrollView {
                    VStack(alignment: .leading) {
                        if !trendingMovies.isEmpty {
                            Text("Trending Movies")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)
                                .padding(.top)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(trendingMovies) { movie in
                                        NavigationLink(destination: MovieDetailView(movie: movie)) {
                                            VStack {
                                                if let url = movie.posterURL {
                                                    AsyncImage(url: url) { image in
                                                        image.resizable()
                                                    } placeholder: {
                                                        ProgressView()
                                                    }
                                                    .frame(width: 100, height: 150)
                                                    .cornerRadius(8)
                                                }
                                                Text(movie.title)
                                                    .font(.caption)
                                                    .lineLimit(1)
                                            }
                                            .padding(.trailing, 8)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        if !popularMovies.isEmpty {
                            Text("Popular Movies")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)
                                .padding(.top)

                            ForEach(popularMovies) { movie in
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
                                    .padding(.vertical, 8)
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Movies")
                .onAppear(perform: fetchMovies)
            }
        }
    }

    private func fetchMovies() {
        isLoading = true

        NetworkManager.shared.fetchPopularMovies { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let movies):
                    self.popularMovies = movies
                case .failure(let error):
                    print("Error fetching popular movies: \(error)")
                }
                self.isLoading = false
            }
        }

        NetworkManager.shared.fetchTrendingMovies { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let movies):
                    self.trendingMovies = movies
                case .failure(let error):
                    print("Error fetching trending movies: \(error)")
                }
            }
        }
    }

    private func searchMovies() {
        guard !searchQuery.isEmpty else {
            fetchMovies()
            return
        }

        isLoading = true
        NetworkManager.shared.searchMovies(query: searchQuery) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let movies):
                    self.popularMovies = movies
                case .failure(let error):
                    print("Error searching for movies: \(error)")
                }
                self.isLoading = false
            }
        }
    }
}
