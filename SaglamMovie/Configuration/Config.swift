//
//  Config.swift
//  MovieRecommender
//
//  Created by Ramazan Üsen on 21.11.2024.
//

import Foundation

struct Config {
    static func value(for key: String) -> String {
        guard let filePath = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: filePath) as? [String: Any],
              let value = config[key] as? String else {
            fatalError("Key \(key) not found in Config.plist")
        }
        return value
    }

    static var apiKey: String {
        return value(for: "API_KEY")
    }

    static var apiToken: String {
        return value(for: "API_TOKEN")
    }
}
