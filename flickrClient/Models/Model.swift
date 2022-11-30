import Foundation

struct Response: Codable {
    static let URL = Foundation.URL(string: "https://www.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=?")!
    
    var items: [Item]
    
    /// Load the flickr API data
    func loadData() async -> [Item] {
        do {
            let (data, _) = try await URLSession.shared.data(from: Response.URL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let decodedResponse = try decoder.decode(Response.self, from: data)
            return decodedResponse.items
        } catch let error {
            print(error)
            return []
        }
    }
}

struct Item: Codable, Hashable {
    var author: String
    var title: String?
    var link: String
    var date_taken: Date
    var tags: String
    var media: Media
    
    struct Media: Codable, Hashable {
        var m: String
    }
}
