import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private let apiKey = Config.apiKey
    private let baseURL = "https://api.themoviedb.org/3"
    private let accessToken = Config.apiToken
    private let justwatchBaseURL = "https://apis.justwatch.com/content"
    private let justwatchCountry = "US"
    
    private var headers: [String: String] {
        ["Authorization": "Bearer \(accessToken)"]
    }
    
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        configuration.waitsForConnectivity = true
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        self.session = URLSession(configuration: configuration)
    }

    func fetchPopularMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        let urlString = "\(baseURL)/movie/popular"
        fetchMovies(from: urlString, completion: completion)
    }

    func fetchTrendingMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        let urlString = "\(baseURL)/trending/movie/day"
        fetchMovies(from: urlString, completion: completion)
    }

    func searchMovies(query: String, completion: @escaping (Result<[Movie], Error>) -> Void) {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)/search/movie?query=\(encodedQuery)"
        fetchMovies(from: urlString, completion: completion)
    }

    func fetchRecommendations(for movieId: Int, completion: @escaping (Result<[Movie], Error>) -> Void) {
        let urlString = "\(baseURL)/movie/\(movieId)/recommendations"
        fetchMovies(from: urlString, completion: completion)
    }

    func fetchGenres(completion: @escaping (Result<[Genre], Error>) -> Void) {
        let urlString = "\(baseURL)/genre/movie/list"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(GenreResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(response.genres))
                }
            } catch {
                print("Decoding error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func fetchMoviesByGenre(genreId: Int, completion: @escaping (Result<[Movie], Error>) -> Void) {
        let urlString = "\(baseURL)/discover/movie?with_genres=\(genreId)"
        fetchMovies(from: urlString, completion: completion)
    }

    func fetchWatchProviders(for movieId: Int, completion: @escaping (Result<[WatchProvider], Error>) -> Void) {
        let urlString = "\(baseURL)/movie/\(movieId)/watch/providers"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }

            do {
                let response = try JSONDecoder().decode(TMDBWatchProvidersResponse.self, from: data)
                if let results = response.results.US {
                    var providers: [WatchProvider] = []
                    var seenProviderIds = Set<Int>()
                    
                    // Function to add unique providers
                    func addUniqueProviders(from tmdbProviders: [TMDBProvider]?, type: WatchProvider.ProviderType) {
                        tmdbProviders?.forEach { provider in
                            if !seenProviderIds.contains(provider.providerId) {
                                seenProviderIds.insert(provider.providerId)
                                providers.append(WatchProvider(
                                    id: "\(provider.providerId)_\(type.rawValue)",  // Create unique ID
                                    providerId: provider.providerId,
                                    name: provider.providerName,
                                    logoPath: provider.logoPath,
                                    providerType: type
                                ))
                            }
                        }
                    }
                    
                    // Add providers in order: streaming, rental, purchase
                    addUniqueProviders(from: results.flatrate, type: .streaming)
                    addUniqueProviders(from: results.rent, type: .rental)
                    addUniqueProviders(from: results.buy, type: .purchase)
                    
                    DispatchQueue.main.async {
                        completion(.success(providers))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                }
            } catch {
                print("Watch providers decoding error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    private func fetchMovies(from urlString: String, completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.cachePolicy = .returnCacheDataElseLoad

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 429 {
                print("Rate limit exceeded. Please wait before making more requests.")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.rateLimitExceeded))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(MovieResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(response.results))
                }
            } catch {
                print("Decoding error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func fetchMovieDetails(id: Int, completion: @escaping (Result<Movie, Error>) -> Void) {
        let urlString = "\(baseURL)/movie/\(id)?language=en-US&append_to_response=images,videos"
        print("🎬 Fetching movie details for ID: \(id)")
        print("🔗 URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL for movie details")
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.cachePolicy = .returnCacheDataElseLoad

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                print("❌ No data received")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let movie = try decoder.decode(Movie.self, from: data)
                
                print("✅ Successfully decoded movie:")
                print("- Title: \(movie.title)")
                print("- ID: \(movie.id)")
                print("- Poster Path: \(String(describing: movie.posterPath))")
                
                if let posterPath = movie.posterPath {
                    let fullURL = "https://image.tmdb.org/t/p/w500\(posterPath)"
                    print("🖼 Full Poster URL: \(fullURL)")
                }
                
                DispatchQueue.main.async {
                    completion(.success(movie))
                }
            } catch {
                print("❌ Decoding error: \(error)")
                if let dataString = String(data: data, encoding: .utf8) {
                    print("📝 Raw response data: \(dataString)")
                }
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    enum NetworkError: Error {
        case invalidURL
        case noData
        case rateLimitExceeded
    }
}

struct MovieResponse: Codable {
    let results: [Movie]
}

struct GenreResponse: Codable {
    let genres: [Genre]
}

struct ExternalIds: Codable {
    let imdbId: String?
    
    enum CodingKeys: String, CodingKey {
        case imdbId = "imdb_id"
    }
}

struct JustWatchResponse: Codable {
    let offers: [JustWatchOffer]?
}

struct JustWatchOffer: Codable {
    let monetizationType: String
    let providerId: Int
    let providerName: String
    let providerLogoPath: String?
    
    enum CodingKeys: String, CodingKey {
        case monetizationType = "monetization_type"
        case providerId = "provider_id"
        case providerName = "provider_name"
        case providerLogoPath = "provider_logo_path"
    }
}

struct TMDBWatchProvidersResponse: Codable {
    let results: TMDBWatchProviderResults
}

struct TMDBWatchProviderResults: Codable {
    let US: TMDBWatchProviderRegion?
}

struct TMDBWatchProviderRegion: Codable {
    let link: String?
    let flatrate: [TMDBProvider]?
    let rent: [TMDBProvider]?
    let buy: [TMDBProvider]?
}

struct TMDBProvider: Codable {
    let providerId: Int
    let providerName: String
    let logoPath: String?
    
    enum CodingKeys: String, CodingKey {
        case providerId = "provider_id"
        case providerName = "provider_name"
        case logoPath = "logo_path"
    }
}
