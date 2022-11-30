/*: # Network calls and API tests */
import Foundation

struct Response: Codable {
    var items: [Item]
}

struct Item: Codable {
    var title: String
    var link: String
    var date_taken: Date
    var tags: String
}

// Reference: https://stackoverflow.com/a/25505305/5856760
func loadData() async -> [Item] {
    let url = URL(string: "https://www.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=?")!

    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let decodedResponse = try decoder.decode(Response.self, from: data)
        return decodedResponse.items
    } catch let error {
        print(error)
        return []
    }
}

await loadData()

let dec = ISO8601DateFormatter()
dec.date(from: "2022-11-20T18:21:57-08:00")
