//
//  ContentView.swift
//  MovieRecommender
//
//  Created by Ramazan Üsen on 21.11.2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MovieListView()
                .tabItem {
                    Label("Movies", systemImage: "film")
                }

            GenreListView()
                .tabItem {
                    Label("Genres", systemImage: "list.bullet")
                }

            BookmarksView()
                .tabItem {
                    Label("Bookmarks", systemImage: "bookmark")
                }
        }
    }
}
