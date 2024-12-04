import SwiftUI

struct WatchHistoryView: View {
    @Binding var selectedTab: ContentView.Tab
    @State private var watchHistory: [Movie] = []
    @State private var isLoading = false
    @State private var sortOrder = SortOrder.newest
    
    enum SortOrder {
        case newest
        case oldest
        case highestRated
        case lowestRated
    }
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    VStack {
                        ProgressView("Loading watch history...")
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if watchHistory.isEmpty {
                    emptyHistoryView
                } else {
                    historyContent
                }
            }
            .navigationTitle("Watch History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    homeButton
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    if !watchHistory.isEmpty {
                        sortButton
                    }
                }
            }
        }
        .onAppear {
            loadWatchHistory()
        }
    }
    
    private var emptyHistoryView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No watch history")
                .font(.title2)
            Text("Movies you've watched will appear here")
                .foregroundColor(.secondary)
        }
    }
    
    private var historyContent: some View {
        List {
            ForEach(watchHistory) { movie in
                NavigationLink(destination: MovieDetailView(selectedTab: $selectedTab, movie: movie, isRoot: true)) {
                    WatchHistoryRow(movie: movie)
                }
            }
            .onDelete(perform: removeFromHistory)
        }
    }
    
    private var homeButton: some View {
        Button(action: {
            selectedTab = .movies
        }) {
            Image(systemName: "house.fill")
                .foregroundColor(.blue)
        }
    }
    
    private var sortButton: some View {
        Menu {
            Button("Newest First") {
                sortOrder = .newest
                sortWatchHistory()
            }
            Button("Oldest First") {
                sortOrder = .oldest
                sortWatchHistory()
            }
            Button("Highest Rated") {
                sortOrder = .highestRated
                sortWatchHistory()
            }
            Button("Lowest Rated") {
                sortOrder = .lowestRated
                sortWatchHistory()
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .foregroundColor(.blue)
        }
    }
    
    private func loadWatchHistory() {
        let historyItems = UserDataManager.shared.getWatchHistory()
        
        if historyItems.isEmpty {
            watchHistory = []
            return
        }
        
        isLoading = true
        
        let group = DispatchGroup()
        var movies: [Movie] = []
        
        for item in historyItems {
            group.enter()
            NetworkManager.shared.fetchMovieDetails(id: item.movieId) { result in
                defer { group.leave() }
                if case .success(let movie) = result {
                    movies.append(movie)
                }
            }
        }
        
        group.notify(queue: .main) {
            self.watchHistory = movies
            self.sortWatchHistory()
            self.isLoading = false
        }
    }
    
    private func sortWatchHistory() {
        let historyItems = UserDataManager.shared.getWatchHistory()
        
        switch sortOrder {
        case .newest:
            watchHistory.sort { movie1, movie2 in
                let date1 = historyItems.first { $0.movieId == movie1.id }?.watchedDate ?? Date.distantPast
                let date2 = historyItems.first { $0.movieId == movie2.id }?.watchedDate ?? Date.distantPast
                return date1 > date2
            }
        case .oldest:
            watchHistory.sort { movie1, movie2 in
                let date1 = historyItems.first { $0.movieId == movie1.id }?.watchedDate ?? Date.distantPast
                let date2 = historyItems.first { $0.movieId == movie2.id }?.watchedDate ?? Date.distantPast
                return date1 < date2
            }
        case .highestRated:
            watchHistory.sort { movie1, movie2 in
                let rating1 = historyItems.first { $0.movieId == movie1.id }?.rating ?? 0
                let rating2 = historyItems.first { $0.movieId == movie2.id }?.rating ?? 0
                return rating1 > rating2
            }
        case .lowestRated:
            watchHistory.sort { movie1, movie2 in
                let rating1 = historyItems.first { $0.movieId == movie1.id }?.rating ?? 0
                let rating2 = historyItems.first { $0.movieId == movie2.id }?.rating ?? 0
                return rating1 < rating2
            }
        }
    }
    
    private func removeFromHistory(at offsets: IndexSet) {
        offsets.forEach { index in
            UserDataManager.shared.removeFromWatchHistory(watchHistory[index].id)
        }
        watchHistory.remove(atOffsets: offsets)
    }
}

struct WatchHistoryRow: View {
    let movie: Movie
    @State private var watchDate: Date?
    @State private var rating: Double?
    
    var body: some View {
        HStack(spacing: 12) {
            // Movie Poster
            Group {
                if let url = movie.posterURL(size: "w500") {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure(_):
                            placeholderView
                        case .empty:
                            ProgressView()
                        @unknown default:
                            placeholderView
                        }
                    }
                } else {
                    placeholderView
                }
            }
            .frame(width: 60, height: 90)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)
                
                if let date = watchDate {
                    Text("Watched: \(date.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let rating = rating {
                    HStack {
                        Text("Rating:")
                            .font(.caption)
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: "star.fill")
                                .foregroundColor(star <= Int(rating.rounded()) ? .yellow : .gray)
                                .font(.caption)
                        }
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .onAppear {
            if let historyItem = UserDataManager.shared.getWatchHistoryItem(for: movie.id) {
                self.watchDate = historyItem.watchedDate
                self.rating = historyItem.rating
            }
        }
    }
    
    private var placeholderView: some View {
        VStack(spacing: 8) {
            Image(systemName: "film")
                .font(.largeTitle)
                .foregroundColor(.gray)
            Text(movie.title)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
        }
        .frame(width: 60, height: 90)
        .background(Color(.systemGray6))
    }
} 