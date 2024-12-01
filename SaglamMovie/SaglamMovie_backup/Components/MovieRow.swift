import SwiftUI

struct MovieRow: View {
    let movie: Movie
    @State private var watchProviders: [WatchProvider] = []
    @State private var isLoadingProviders = true

    var body: some View {
        HStack(spacing: 12) {
            // Movie Poster with Placeholder
            Group {
                if let path = movie.posterPath {
                    let url = URL(string: "https://image.tmdb.org/t/p/w500\(path)")
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    // Placeholder for missing poster
                    VStack(spacing: 8) {
                        Image(systemName: "film")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text(movie.title)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                    }
                    .frame(width: 80, height: 120)
                    .background(Color(.systemGray6))
                }
            }
            .frame(width: 80, height: 120)
            .cornerRadius(8)
            
            // Movie Info
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)
                
                if let releaseDate = movie.releaseDate {
                    Text(releaseDate)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text(movie.overview)
                    .font(.caption)
                    .lineLimit(3)
                    .foregroundColor(.secondary)
                
                // Watch Providers
                if !watchProviders.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Text("Available on:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            ForEach(watchProviders) { provider in
                                HStack(spacing: 4) {
                                    if let url = provider.logoURL {
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(width: 20, height: 20)
                                    }
                                    Text(provider.name)
                                        .font(.caption)
                                }
                                .padding(4)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(4)
                            }
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .onAppear {
            fetchWatchProviders()
            print("🎬 Movie: \(movie.title)")
            print("🖼 Poster Path: \(movie.posterPath ?? "nil")")
            if let path = movie.posterPath {
                print("🔗 Full URL: https://image.tmdb.org/t/p/w500\(path)")
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
}
