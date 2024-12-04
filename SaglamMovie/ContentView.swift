import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .movies

    enum Tab {
        case movies
        case genres
        case watchlist
        case history
        case bookmarks
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            MovieListView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Movies", systemImage: "film")
                }
                .tag(Tab.movies)

            GenreListView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Genres", systemImage: "list.bullet")
                }
                .tag(Tab.genres)

            WatchlistView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Watchlist", systemImage: "bookmark")
                }
                .tag(Tab.watchlist)

            WatchHistoryView(selectedTab: $selectedTab)
                .tabItem {
                    Label("History", systemImage: "clock")
                }
                .tag(Tab.history)

            BookmarksView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Bookmarks", systemImage: "star")
                }
                .tag(Tab.bookmarks)
        }
    }
}
