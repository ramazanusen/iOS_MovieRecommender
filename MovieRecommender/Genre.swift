//
//  Genre.swift
//  MovieRecommender
//
//  Created by Ramazan Üsen on 22.11.2024.
//

import Foundation

struct GenreResponse: Codable {
    let genres: [Genre]
}

struct Genre: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
}
