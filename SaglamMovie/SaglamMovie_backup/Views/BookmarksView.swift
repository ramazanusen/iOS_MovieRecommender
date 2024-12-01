//
//  BookmarksView.swift
//  MovieRecommender
//
//  Created by Ramazan Üsen on 21.11.2024.
//

import SwiftUI

struct BookmarksView: View {
    @Binding var selectedTab: ContentView.Tab
    @State private var bookmarks: [Movie] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    VStack {
                        ProgressView("Loading bookmarks...")
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if bookmarks.isEmpty {
                    emptyBookmarksView
                } else {
                    bookmarksContent
                }
            }
            .navigationTitle("Bookmarks")
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
            .onAppear {
                loadBookmarks()
            }
        }
    }
    
    private var emptyBookmarksView: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No bookmarked movies")
                .font(.title2)
            Text("Movies you bookmark will appear here")
                .foregroundColor(.secondary)
        }
    }
    
    private var bookmarksContent: some View {
        List {
            ForEach(bookmarks) { movie in
                NavigationLink(destination: MovieDetailView(selectedTab: $selectedTab, 
                                                          movie: movie,
                                                          isRoot: true)) {
                    MovieRow(movie: movie)
                }
            }
            .onDelete(perform: removeBookmarks)
        }
    }
    
    private func loadBookmarks() {
        isLoading = true
        let bookmarkItems = BookmarkManager.shared.getBookmarks()
        self.bookmarks = bookmarkItems
        isLoading = false
    }
    
    private func removeBookmarks(at offsets: IndexSet) {
        offsets.forEach { index in
            BookmarkManager.shared.removeBookmark(bookmarks[index])
        }
        bookmarks.remove(atOffsets: offsets)
    }
}
