//
//  NetworkManager.swift
//  MovieRecommender
//
//  Created by Ramazan Üsen on 21.11.2024.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager() // Singleton instance
    private init() {}

    private let baseURL = "https://api.themoviedb.org/3"
    private let apiKey = Config.apiKey

    /// Fetch popular movies
    func fetchPopularMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        let urlString = "\(baseURL)/movie/popular?api_key=\(apiKey)&language=en-US&page=1"
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                completion(.success(decodedResponse.results))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    enum NetworkError: Error {
        case invalidURL
        case noData
    }
    
    func searchMovies(query: String, completion: @escaping (Result<[Movie], Error>) -> Void) {
        let urlString = "\(baseURL)/search/movie?api_key=\(apiKey)&language=en-US&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&page=1"
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                completion(.success(decodedResponse.results))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func fetchRecommendations(for movieID: Int, completion: @escaping (Result<[Movie], Error>) -> Void) {
        let urlString = "\(baseURL)/movie/\(movieID)/recommendations?api_key=\(apiKey)&language=en-US&page=1"
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                completion(.success(decodedResponse.results))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}


