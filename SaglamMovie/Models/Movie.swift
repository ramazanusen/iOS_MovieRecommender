import Foundation

struct Movie: Codable, Identifiable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String?
    private(set) var streamingPlatforms: [StreamingPlatform]?
    let images: MovieImages?
    
    func posterURL(size: String = "w500") -> URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/\(size)\(posterPath)")
    }
    
    enum StreamingPlatform: String, Codable {
        case netflix = "Netflix"
        case disneyPlus = "Disney+"
        case amazonPrime = "Amazon Prime"
        case hboMax = "HBO Max"
        case appleTv = "Apple TV+"
        
        var iconName: String {
            switch self {
            case .netflix: return "play.tv"
            case .disneyPlus: return "play.circle"
            case .amazonPrime: return "play.square"
            case .hboMax: return "play.rectangle"
            case .appleTv: return "appletv"
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case streamingPlatforms
        case images
    }
    
    mutating func updateStreamingPlatforms(_ platforms: [StreamingPlatform]) {
        self.streamingPlatforms = platforms
    }
}

struct MovieImages: Codable {
    let posters: [MoviePoster]?
}

struct MoviePoster: Codable {
    let filePath: String
    let width: Int
    let height: Int
    
    enum CodingKeys: String, CodingKey {
        case filePath = "file_path"
        case width
        case height
    }
}
