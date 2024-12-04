import SwiftUI

struct GenreListView: View {
    @Binding var selectedTab: ContentView.Tab
    @State private var genres: [Genre] = []
    @State private var selectedGenre: Genre?
    @State private var moviesByGenre: [Movie] = []
    @State private var isLoading = false
    
    // Break down the gradients into a computed property
    private var cardGradients: [[Color]] {
        [
            [.blue, .purple],
            [.purple, .pink],
            [.pink, .orange],
            [.orange, .yellow],
            [.teal, .blue],
            [.indigo, .purple]
        ]
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if selectedGenre == nil {
                        genreGridView
                    } else if let genre = selectedGenre {
                        selectedGenreView(genre: genre)
                    }
                }
            }
            .navigationTitle("Genres")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    homeButton
                }
            }
            .onAppear {
                if genres.isEmpty {
                    fetchGenres()
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var genreGridView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Explore Categories")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            if genres.isEmpty {
                loadingView
            } else {
                genreGrid
            }
        }
    }
    
    private var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: 200)
    }
    
    private var genreGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 16) {
            ForEach(Array(genres.enumerated()), id: \.element.id) { index, genre in
                genreButton(for: genre, at: index)
            }
        }
        .padding(.horizontal)
    }
    
    private func genreButton(for genre: Genre, at index: Int) -> some View {
        Button(action: {
            selectedGenre = genre
            fetchMoviesByGenre(genreId: genre.id)
        }) {
            GenreCardView(
                genre: genre,
                gradient: cardGradients[index % cardGradients.count]
            )
        }
    }
    
    private func selectedGenreView(genre: Genre) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            backButton
            
            Text(genre.name)
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            if isLoading {
                loadingView
            } else if moviesByGenre.isEmpty {
                emptyStateView
            } else {
                moviesList
            }
        }
    }
    
    private var backButton: some View {
        HStack {
            Button(action: {
                withAnimation {
                    selectedGenre = nil
                    moviesByGenre.removeAll()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundColor(.blue)
            }
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var emptyStateView: some View {
        Text("No movies found")
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: 200)
    }
    
    private var moviesList: some View {
        LazyVStack(spacing: 16) {
            ForEach(moviesByGenre) { movie in
                NavigationLink(destination: MovieDetailView(selectedTab: $selectedTab, 
                                                          movie: movie,
                                                          isRoot: true)) {
                    MovieRow(movie: movie)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: .gray.opacity(0.3),
                                       radius: 4, x: 0, y: 2)
                        )
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var homeButton: some View {
        Button(action: {
            selectedTab = .movies
        }) {
            Image(systemName: "house.fill")
                .foregroundColor(.blue)
        }
    }
    
    // MARK: - Network Calls
    
    private func fetchGenres() {
        NetworkManager.shared.fetchGenres { result in
            switch result {
            case .success(let genres):
                self.genres = genres
            case .failure(let error):
                print("Error fetching genres: \(error)")
            }
        }
    }
    
    private func fetchMoviesByGenre(genreId: Int) {
        isLoading = true
        NetworkManager.shared.fetchMoviesByGenre(genreId: genreId) { result in
            isLoading = false
            switch result {
            case .success(let movies):
                self.moviesByGenre = movies
            case .failure(let error):
                print("Error fetching movies by genre: \(error)")
            }
        }
    }
}
