//
//  MovieListView.swift
//  MovieRecommender
//
//  Created by Ramazan Üsen on 21.11.2024.
//

import SwiftUI

struct MovieListView: View {
    @Binding var selectedTab: ContentView.Tab
    @State private var searchText = ""
    @State private var searchResults: [Movie] = []
    @State private var trendingMovies: [Movie] = []
    @State private var isSearching = false
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    searchBarSection
                    
                    if isSearching {
                        searchResultsSection
                    } else {
                        trendingMoviesSection
                    }
                }
            }
            .navigationTitle("Movies")
            .onAppear {
                if trendingMovies.isEmpty {
                    fetchTrendingMovies()
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var searchBarSection: some View {
        SearchBar(text: $searchText, isSearching: $isSearching)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            .onChange(of: searchText) { oldValue, newValue in
                if !newValue.isEmpty {
                    searchMovies()
                } else {
                    searchResults.removeAll()
                    isSearching = false
                }
            }
    }
    
    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Search Results")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            if searchResults.isEmpty {
                emptySearchResultView
            } else {
                searchResultsList
            }
        }
    }
    
    private var emptySearchResultView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundColor(.gray)
            Text("No results found")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
    
    private var searchResultsList: some View {
        LazyVStack(spacing: 16) {
            ForEach(searchResults) { movie in
                NavigationLink(destination: MovieDetailView(selectedTab: $selectedTab, 
                                                          movie: movie,
                                                          isRoot: true)) {
                    MovieRow(movie: movie)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: .gray.opacity(0.2),
                                       radius: 4, x: 0, y: 2)
                        )
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var trendingMoviesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Trending Movies")
                    .font(.title2)
                    .bold()
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
            }
            .padding(.horizontal)
            
            if isLoading {
                loadingView
            } else {
                trendingMoviesList
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading trending movies...")
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
    
    private var trendingMoviesList: some View {
        LazyVStack(spacing: 16) {
            ForEach(trendingMovies) { movie in
                NavigationLink(destination: MovieDetailView(selectedTab: $selectedTab, 
                                                          movie: movie,
                                                          isRoot: true)) {
                    MovieRow(movie: movie)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: .gray.opacity(0.2),
                                       radius: 4, x: 0, y: 2)
                        )
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Network Calls
    
    private func searchMovies() {
        guard !searchText.isEmpty else { return }
        
        isSearching = true
        NetworkManager.shared.searchMovies(query: searchText) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let movies):
                    self.searchResults = movies
                case .failure(let error):
                    print("Search error: \(error)")
                    self.searchResults = []
                }
            }
        }
    }
    
    private func fetchTrendingMovies() {
        isLoading = true
        NetworkManager.shared.fetchTrendingMovies { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let movies):
                    self.trendingMovies = movies
                case .failure(let error):
                    print("Error fetching trending movies: \(error)")
                }
                self.isLoading = false
            }
        }
    }
}

// Improved SearchBar design
struct SearchBar: View {
    @Binding var text: String
    @Binding var isSearching: Bool
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search movies...", text: $text)
                    .autocapitalization(.none)
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                        isSearching = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}
