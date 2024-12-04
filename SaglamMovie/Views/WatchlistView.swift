import SwiftUI

struct WatchlistView: View {
    @Binding var selectedTab: ContentView.Tab
    @State private var watchlist: [Movie] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    VStack {
                        ProgressView("Loading watchlist...")
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if watchlist.isEmpty {
                    emptyWatchlistView
                } else {
                    watchlistContent
                }
            }
            .navigationTitle("Watchlist")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        selectedTab = .movies
                    }) {
                        Image(systemName: "house.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .onAppear {
            loadWatchlist()
        }
        .onChange(of: selectedTab) { _, _ in
            if selectedTab == .watchlist {
                loadWatchlist()
            }
        }
    }
    
    private var emptyWatchlistView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("Your watchlist is empty")
                .font(.title2)
            Text("Add movies you want to watch later")
                .foregroundColor(.secondary)
        }
    }
    
    private var watchlistContent: some View {
        List {
            ForEach(watchlist) { movie in
                NavigationLink(destination: MovieDetailView(selectedTab: $selectedTab, movie: movie, isRoot: true)) {
                    MovieRow(movie: movie)
                }
            }
            .onDelete(perform: removeFromWatchlist)
        }
    }
    
    private func loadWatchlist() {
        let watchlistItems = UserDataManager.shared.getWatchlist()
        
        if watchlistItems.isEmpty {
            watchlist = []
            return
        }
        
        isLoading = true
        
        let group = DispatchGroup()
        var movies: [Movie] = []
        var errors: [Error] = []
        
        for item in watchlistItems {
            group.enter()
            NetworkManager.shared.fetchMovieDetails(id: item.movieId) { result in
                defer { group.leave() }
                switch result {
                case .success(let movie):
                    movies.append(movie)
                case .failure(let error):
                    errors.append(error)
                    print("Error fetching movie \(item.movieId): \(error)")
                }
            }
        }
        
        group.notify(queue: .main) {
            self.watchlist = movies.sorted { $0.title < $1.title }
            self.isLoading = false
            
            if !errors.isEmpty {
                print("Encountered \(errors.count) errors while loading watchlist")
            }
        }
    }
    
    private func removeFromWatchlist(at offsets: IndexSet) {
        offsets.forEach { index in
            UserDataManager.shared.removeFromWatchlist(watchlist[index].id)
        }
        watchlist.remove(atOffsets: offsets)
        loadWatchlist() // Reload to ensure consistency
    }
} 