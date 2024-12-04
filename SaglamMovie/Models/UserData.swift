import Foundation

struct UserRating: Codable, Identifiable {
    let id: UUID
    let movieId: Int
    let rating: Double
    let review: String?
    let date: Date
}

struct WatchlistItem: Codable, Identifiable {
    let id: UUID
    let movieId: Int
    let addedDate: Date
}

struct WatchHistoryItem: Codable, Identifiable {
    let id: UUID
    let movieId: Int
    let watchedDate: Date
    let rating: Double?
}

struct CustomList: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String?
    let movieIds: [Int]
    let createdDate: Date
    let modifiedDate: Date
}

class UserDataManager {
    static let shared = UserDataManager()
    private let defaults = UserDefaults.standard
    
    // Keys for UserDefaults
    private let ratingsKey = "user_ratings"
    private let watchlistKey = "user_watchlist"
    private let watchHistoryKey = "user_watch_history"
    private let customListsKey = "user_custom_lists"
    
    // MARK: - Ratings and Reviews
    
    func addRating(_ rating: Double, review: String?, for movieId: Int) {
        var ratings = getRatings()
        
        // Remove existing rating if present
        ratings.removeAll { $0.movieId == movieId }
        
        // Add new rating
        let newRating = UserRating(id: UUID(), 
                                 movieId: movieId, 
                                 rating: rating, 
                                 review: review, 
                                 date: Date())
        ratings.append(newRating)
        saveRatings(ratings)
        
        // Force UserDefaults to save immediately
        UserDefaults.standard.synchronize()
    }
    
    func getRating(for movieId: Int) -> UserRating? {
        getRatings().first { $0.movieId == movieId }
    }
    
    func getRatings() -> [UserRating] {
        guard let data = defaults.data(forKey: ratingsKey),
              let ratings = try? JSONDecoder().decode([UserRating].self, from: data) else {
            return []
        }
        return ratings
    }
    
    private func saveRatings(_ ratings: [UserRating]) {
        if let data = try? JSONEncoder().encode(ratings) {
            defaults.set(data, forKey: ratingsKey)
            defaults.synchronize() // Force immediate save
        }
    }
    
    // MARK: - Watchlist
    
    func addToWatchlist(_ movieId: Int) {
        var watchlist = getWatchlist()
        let newItem = WatchlistItem(id: UUID(), movieId: movieId, addedDate: Date())
        watchlist.append(newItem)
        saveWatchlist(watchlist)
    }
    
    func removeFromWatchlist(_ movieId: Int) {
        var watchlist = getWatchlist()
        watchlist.removeAll { $0.movieId == movieId }
        saveWatchlist(watchlist)
    }
    
    func isInWatchlist(_ movieId: Int) -> Bool {
        getWatchlist().contains { $0.movieId == movieId }
    }
    
    func getWatchlist() -> [WatchlistItem] {
        guard let data = defaults.data(forKey: watchlistKey),
              let watchlist = try? JSONDecoder().decode([WatchlistItem].self, from: data) else {
            return []
        }
        return watchlist
    }
    
    private func saveWatchlist(_ watchlist: [WatchlistItem]) {
        if let data = try? JSONEncoder().encode(watchlist) {
            defaults.set(data, forKey: watchlistKey)
            defaults.synchronize()
        }
    }
    
    // MARK: - Watch History
    
    func addToWatchHistory(_ movieId: Int, rating: Double? = nil) {
        var history = getWatchHistory()
        // Remove existing entry if present
        history.removeAll { $0.movieId == movieId }
        
        let newItem = WatchHistoryItem(
            id: UUID(),
            movieId: movieId,
            watchedDate: Date(),
            rating: rating
        )
        history.append(newItem)
        saveWatchHistory(history)
    }
    
    func getWatchHistory() -> [WatchHistoryItem] {
        guard let data = defaults.data(forKey: watchHistoryKey),
              let history = try? JSONDecoder().decode([WatchHistoryItem].self, from: data) else {
            return []
        }
        return history
    }
    
    private func saveWatchHistory(_ history: [WatchHistoryItem]) {
        if let data = try? JSONEncoder().encode(history) {
            defaults.set(data, forKey: watchHistoryKey)
            defaults.synchronize()
        }
    }
    
    // MARK: - Custom Lists
    
    func createList(name: String, description: String? = nil) -> CustomList {
        let newList = CustomList(id: UUID(),
                               name: name,
                               description: description,
                               movieIds: [],
                               createdDate: Date(),
                               modifiedDate: Date())
        var lists = getCustomLists()
        lists.append(newList)
        saveCustomLists(lists)
        return newList
    }
    
    func addMovieToList(movieId: Int, listId: UUID) {
        var lists = getCustomLists()
        guard let index = lists.firstIndex(where: { $0.id == listId }) else { return }
        let list = lists[index]
        if !list.movieIds.contains(movieId) {
            let movieIds = list.movieIds + [movieId]
            lists[index] = CustomList(id: list.id,
                                    name: list.name,
                                    description: list.description,
                                    movieIds: movieIds,
                                    createdDate: list.createdDate,
                                    modifiedDate: Date())
            saveCustomLists(lists)
        }
    }
    
    func removeMovieFromList(movieId: Int, listId: UUID) {
        var lists = getCustomLists()
        guard let index = lists.firstIndex(where: { $0.id == listId }) else { return }
        let list = lists[index]
        lists[index] = CustomList(id: list.id,
                                name: list.name,
                                description: list.description,
                                movieIds: list.movieIds.filter { $0 != movieId },
                                createdDate: list.createdDate,
                                modifiedDate: Date())
        saveCustomLists(lists)
    }
    
    func getCustomLists() -> [CustomList] {
        guard let data = defaults.data(forKey: customListsKey),
              let lists = try? JSONDecoder().decode([CustomList].self, from: data) else {
            return []
        }
        return lists
    }
    
    private func saveCustomLists(_ lists: [CustomList]) {
        if let data = try? JSONEncoder().encode(lists) {
            defaults.set(data, forKey: customListsKey)
        }
    }
    
    // Add this method to UserDataManager
    func getWatchlistItemDate(for movieId: Int) -> Date? {
        getWatchlist().first { $0.movieId == movieId }?.addedDate
    }
    
    // Add these methods to UserDataManager
    func getWatchHistoryItem(for movieId: Int) -> WatchHistoryItem? {
        getWatchHistory().first { $0.movieId == movieId }
    }
    
    func removeFromWatchHistory(_ movieId: Int) {
        var history = getWatchHistory()
        history.removeAll { $0.movieId == movieId }
        saveWatchHistory(history)
    }
} 