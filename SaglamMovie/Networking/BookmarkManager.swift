//
//  BookmarkManager.swift
//  MovieRecommender
//
//  Created by Ramazan Üsen on 21.11.2024.
//

import Foundation

class BookmarkManager {
    static let shared = BookmarkManager()
    private let bookmarksKey = "bookmarkedMovies"
    private init() {}

    func addBookmark(_ movie: Movie) {
        var bookmarks = getBookmarks()
        if !bookmarks.contains(where: { $0.id == movie.id }) {
            bookmarks.append(movie)
            saveBookmarks(bookmarks)
        }
    }

    func removeBookmark(_ movie: Movie) {
        var bookmarks = getBookmarks()
        bookmarks.removeAll { $0.id == movie.id }
        saveBookmarks(bookmarks)
    }

    func getBookmarks() -> [Movie] {
        guard let data = UserDefaults.standard.data(forKey: bookmarksKey) else { return [] }
        do {
            let decoded = try JSONDecoder().decode([Movie].self, from: data)
            return decoded
        } catch {
            print("Error decoding bookmarks: \(error)")
            return []
        }
    }

    private func saveBookmarks(_ bookmarks: [Movie]) {
        do {
            let data = try JSONEncoder().encode(bookmarks)
            UserDefaults.standard.set(data, forKey: bookmarksKey)
        } catch {
            print("Error saving bookmarks: \(error)")
        }
    }
}
