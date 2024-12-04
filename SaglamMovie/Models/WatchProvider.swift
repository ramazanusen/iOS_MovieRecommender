import Foundation

struct WatchProvider: Codable, Identifiable {
    let id: String
    let providerId: Int
    let name: String
    let logoPath: String?
    let providerType: ProviderType
    
    var logoURL: URL? {
        guard let logoPath = logoPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/original\(logoPath)")
    }
    
    enum ProviderType: String, Codable {
        case streaming = "Stream"
        case rental = "Rent"
        case purchase = "Buy"
    }
    
    init(id: String, providerId: Int, name: String, logoPath: String?, providerType: ProviderType) {
        self.id = id
        self.providerId = providerId
        self.name = name
        self.logoPath = logoPath
        self.providerType = providerType
    }
} 