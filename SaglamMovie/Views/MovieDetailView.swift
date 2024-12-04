//
//  MovieDetailView.swift
//  MovieRecommender
//
//  Created by Ramazan Üsen on 21.11.2024.
//

import SwiftUI

// First, create a custom environment key
private struct NavigationStackDepthKey: EnvironmentKey {
    static let defaultValue: Int = 0
}

extension EnvironmentValues {
    var navigationStackDepth: Int {
        get { self[NavigationStackDepthKey.self] }
        set { self[NavigationStackDepthKey.self] = newValue }
    }
}

struct MovieDetailView: View {
    @Binding var selectedTab: ContentView.Tab
    @Environment(\.dismiss) private var dismiss
    let movie: Movie
    let isRoot: Bool
    @State private var recommendations: [Movie] = []
    @State private var watchProviders: [WatchProvider] = []
    @State private var isLoadingRecommendations = true
    @State private var isLoadingProviders = true
    @State private var isBookmarked = false
    @State private var userRating: Double = 0
    @State private var userReview: String = ""
    @State private var isReviewSheetPresented = false
    @State private var existingRating: UserRating?
    @State private var isInWatchlist = false
    @State private var isWatched = false

    private var posterURL: URL? {
        movie.posterURL(size: "original")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                posterSection
                titleSection
                actionButtonsSection
                releaseDateSection
                watchProvidersSection
                overviewSection
                ratingSection
                recommendationsSection
            }
        }
        .navigationTitle("Movie Details")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                homeButton
            }
        }
        .onAppear(perform: loadData)
        .sheet(isPresented: $isReviewSheetPresented) {
            ReviewSheet(
                movie: movie,
                rating: $userRating,
                review: $userReview,
                isPresented: $isReviewSheetPresented,
                onSave: {
                    existingRating = UserRating(
                        id: UUID(),
                        movieId: movie.id,
                        rating: userRating,
                        review: userReview,
                        date: Date()
                    )
                }
            )
        }
    }

    // MARK: - View Components

    private var posterSection: some View {
        Group {
            if let url = posterURL {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
            } else {
                posterPlaceholder
            }
        }
        .frame(maxWidth: UIScreen.main.bounds.width)
        .cornerRadius(8)
        .padding(.horizontal)
    }

    private var posterPlaceholder: some View {
        VStack(spacing: 16) {
            Image(systemName: "film")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text(movie.title)
                .font(.title2)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .background(Color(.systemGray6))
    }

    private var titleSection: some View {
        Text(movie.title)
            .font(.largeTitle)
            .bold()
            .padding(.top, 16)
            .padding(.horizontal)
    }

    private var actionButtonsSection: some View {
        VStack(spacing: 8) {
            Button(action: toggleBookmark) {
                Label(isBookmarked ? "Remove Bookmark" : "Add Bookmark",
                      systemImage: isBookmarked ? "bookmark.fill" : "bookmark")
                    .padding()
                    .background(isBookmarked ? Color.red.opacity(0.2) : Color.blue.opacity(0.2))
                    .cornerRadius(8)
            }

            Button(action: toggleWatchlist) {
                Label(isInWatchlist ? "Remove from Watchlist" : "Add to Watchlist",
                      systemImage: isInWatchlist ? "bookmark.fill" : "bookmark")
                    .padding()
                    .background(isInWatchlist ? Color.purple.opacity(0.2) : Color.blue.opacity(0.2))
                    .cornerRadius(8)
            }

            Button(action: toggleWatched) {
                Label(isWatched ? "Watched" : "Mark as Watched",
                      systemImage: isWatched ? "checkmark.circle.fill" : "checkmark.circle")
                    .padding()
                    .background(isWatched ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }

    private var releaseDateSection: some View {
        Text("Release Date: \(movie.releaseDate ?? "N/A")")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .padding(.horizontal)
            .padding(.top, 8)
    }

    private var watchProvidersSection: some View {
        Group {
            if !watchProviders.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Where to Watch")
                        .font(.headline)
                        .padding(.top, 8)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(watchProviders) { provider in
                                providerCard(provider)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 8)
            } else if isLoadingProviders {
                loadingProviderView
            } else {
                noProvidersView
            }
        }
    }

    private func providerCard(_ provider: WatchProvider) -> some View {
        VStack(alignment: .center, spacing: 4) {
            if let url = provider.logoURL {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 40, height: 40)
                .cornerRadius(8)
            }
            
            Text(provider.name)
                .font(.caption)
                .multilineTextAlignment(.center)
            
            Text(provider.providerType.rawValue)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.blue.opacity(0.1))
                )
        }
        .frame(width: 80)
    }

    private var loadingProviderView: some View {
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }
        .padding()
    }

    private var noProvidersView: some View {
        Text("No streaming information available")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding()
    }

    private var overviewSection: some View {
       return Text(movie.overview)
            .font(.body)
            .padding(.horizontal)
            .padding(.top, 4)
    }

    private var ratingSection: some View {
        Group {
            Divider()
                .padding(.vertical)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Your Rating")
                    .font(.headline)
                
                HStack {
                    RatingView(currentRating: $userRating)
                        .onChange(of: userRating) { _, newValue in
                            saveRating(rating: newValue)
                        }
                    Spacer()
                    Button(action: {
                        isReviewSheetPresented = true
                    }) {
                        Label("Add Review", systemImage: "square.and.pencil")
                            .foregroundColor(.blue)
                    }
                }
                
                if let review = existingRating?.review, !review.isEmpty {
                    Text("Your Review")
                        .font(.headline)
                        .padding(.top)
                    
                    Text(review)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
        }
    }

    private var recommendationsSection: some View {
        Group {
            if !recommendations.isEmpty {
                VStack(alignment: .leading) {
                    Text("You May Also Like")
                        .font(.headline)
                        .padding(.top, 16)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(recommendations) { recommendation in
                                NavigationLink(destination: 
                                    MovieDetailView(selectedTab: $selectedTab,
                                                  movie: recommendation,
                                                  isRoot: false)
                                ) {
                                    VStack {
                                        if let url = recommendation.posterURL() {
                                            AsyncImage(url: url) { image in
                                                image.resizable()
                                            } placeholder: {
                                                ProgressView()
                                            }
                                            .frame(width: 100, height: 150)
                                            .cornerRadius(8)
                                        }
                                        Text(recommendation.title)
                                            .font(.caption)
                                            .lineLimit(1)
                                    }
                                    .frame(width: 100)
                                    .padding(.trailing, 8)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }

    private var homeButton: some View {
        Button(action: {
            selectedTab = .movies
            dismiss()
        }) {
            Image(systemName: "house.fill")
                .foregroundColor(.blue)
        }
    }

    // MARK: - Helper Functions

    private func loadData() {
        isBookmarked = BookmarkManager.shared.getBookmarks().contains(where: { $0.id == movie.id })
        isInWatchlist = UserDataManager.shared.isInWatchlist(movie.id)
        isWatched = UserDataManager.shared.getWatchHistoryItem(for: movie.id) != nil
        loadExistingRating()
        fetchRecommendations()
        fetchWatchProviders()
    }

    private func toggleBookmark() {
        if isBookmarked {
            BookmarkManager.shared.removeBookmark(movie)
        } else {
            BookmarkManager.shared.addBookmark(movie)
        }
        isBookmarked.toggle()
    }

    private func toggleWatchlist() {
        if isInWatchlist {
            UserDataManager.shared.removeFromWatchlist(movie.id)
        } else {
            UserDataManager.shared.addToWatchlist(movie.id)
        }
        isInWatchlist.toggle()
    }

    private func toggleWatched() {
        if isWatched {
            UserDataManager.shared.removeFromWatchHistory(movie.id)
        } else {
            UserDataManager.shared.addToWatchHistory(movie.id, rating: userRating)
        }
        isWatched.toggle()
    }

    private func fetchRecommendations() {
        NetworkManager.shared.fetchRecommendations(for: movie.id) { result in
            switch result {
            case .success(let movies):
                self.recommendations = movies
                self.isLoadingRecommendations = false
            case .failure(let error):
                print("Error fetching recommendations: \(error)")
                self.isLoadingRecommendations = false
            }
        }
    }
    
    private func fetchWatchProviders() {
        isLoadingProviders = true
        NetworkManager.shared.fetchWatchProviders(for: movie.id) { result in
            isLoadingProviders = false
            switch result {
            case .success(let providers):
                self.watchProviders = providers
            case .failure(let error):
                print("Error fetching watch providers: \(error)")
            }
        }
    }

    private func loadExistingRating() {
        if let rating = UserDataManager.shared.getRating(for: movie.id) {
            self.existingRating = rating
            self.userRating = rating.rating
            self.userReview = rating.review ?? ""
        }
    }
    
    private func saveRating(rating: Double) {
        UserDataManager.shared.addRating(rating, review: userReview, for: movie.id)
        existingRating = UserRating(
            id: UUID(),
            movieId: movie.id,
            rating: rating,
            review: userReview,
            date: Date()
        )
    }
}
