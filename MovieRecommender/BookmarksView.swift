//
//  BookmarksView.swift
//  MovieRecommender
//
//  Created by Ramazan Üsen on 21.11.2024.
//

import SwiftUI

struct BookmarksView: View {
    @State private var bookmarks: [Movie] = []

    var body: some View {
        NavigationView {
            List(bookmarks) { movie in
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
            .navigationTitle("Bookmarks")
            .onAppear {
                bookmarks = BookmarkManager.shared.getBookmarks()
            }
        }
    }
}
