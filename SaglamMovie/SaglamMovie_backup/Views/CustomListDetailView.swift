import SwiftUI

struct CustomListDetailView: View {
    let list: CustomList
    @State private var movies: [Movie] = []
    @State private var isLoading = true
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading movies...")
            } else if movies.isEmpty {
                emptyStateView
            } else {
                moviesList
            }
        }
        .navigationTitle(list.name)
        .onAppear(perform: loadMovies)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "film.stack")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No movies in this list")
                .font(.title2)
            if let description = list.description {
                Text(description)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }
    
    private var moviesList: some View {
        List {
            if let description = list.description {
                Section {
                    Text(description)
                        .foregroundColor(.secondary)
                }
            }
            
            Section {
                ForEach(movies) { movie in
                    NavigationLink(destination: MovieDetailView(selectedTab: .constant(.movies), 
                                                             movie: movie,
                                                             isRoot: true)) {
                        MovieRow(movie: movie)
                    }
                }
                .onDelete(perform: removeMovies)
            }
        }
    }
    
    private func loadMovies() {
        let group = DispatchGroup()
        var loadedMovies: [Movie] = []
        
        for movieId in list.movieIds {
            group.enter()
            NetworkManager.shared.fetchMovieDetails(id: movieId) { result in
                defer { group.leave() }
                if case .success(let movie) = result {
                    loadedMovies.append(movie)
                }
            }
        }
        
        group.notify(queue: .main) {
            self.movies = loadedMovies.sorted { $0.title < $1.title }
            self.isLoading = false
        }
    }
    
    private func removeMovies(at offsets: IndexSet) {
        offsets.forEach { index in
            UserDataManager.shared.removeMovieFromList(movieId: movies[index].id, listId: list.id)
        }
        movies.remove(atOffsets: offsets)
    }
} 