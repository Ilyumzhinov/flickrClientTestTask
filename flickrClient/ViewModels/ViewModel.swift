import Foundation
import SwiftUI

class ViewModel: ObservableObject {
    @Published
    private var model: Response
    
    init(items: [Item]? = nil) {
            self.model = .init(items: items ?? [])
    }
    
    /// Loads Model's data
    func loadData() async {
        let data = await self.model.loadData()
        DispatchQueue.main.async {
            self.model.items = data
        }
    }
}


/// A wrapper around the Model that encapsulates the Model from View and adds computed properties
struct ItemWrap: Hashable {
    let author: String, date_taten: Date, authorInitials: String, color: Color, link: String, tags: [String], title: String?, image: String
}


// MARK: - Computed properties
extension ViewModel {
    /// Strip the email from the login
    private var authors: [String] {
        model.items.map(\.author).map { author in
            if let range = author.range(of: "\"(.*?)\"",
                                        options: .regularExpression) {
                
                return author[range]
                    .replacingOccurrences(of: "\"", with: "")
            }
            return ""
        }
    }
    /// Author initials are used in an avatar. First 2 letters are returned
    private var authorInitials: [String] {
        authors.map { author in
            String(author.prefix(2))
        }
    }
    /// Tag string is split and # is added
    private var tags: [[String]] {
        return model.items
            .map(\.tags)
            .map { tag in tag.split(separator: " ") }
            .map { tags_i in tags_i.map { tag in "#\(tag)" } }
    }
    /// Color is used in a user avatar. Generated deterministically from text
    private var colors: [Color] {
        model.items.map { item in Color(generateColorFor(text: item.link)) }
    }
    
    /// The data that is presented to Views. Wraps around Model and adds computed properties
    var items: [ItemWrap] {
        (0..<model.items.count).map { i in
                .init(author: authors[i], date_taten: model.items[i].date_taken, authorInitials: authorInitials[i], color: colors[i], link: model.items[i].link, tags: tags[i], title: model.items[i].title, image: model.items[i].media.m)
        }
    }
}


// MARK: - Search
extension ViewModel {
    /// Splits a search string into an array of tags and performs an exact search.
    /// Returns a match if found at least 1 matched Item's tag.
    /// - Complexity: O(n^2).
    /// - Parameters:
    ///   - search: Search string. E.g. "#tag1 #tag2"
    ///   - items: Search domain. If nil, uses the whole Model
    /// - Returns: Found items
    func searchTags(_ search: String, _ items: [ItemWrap]? = nil) -> [ItemWrap] {
        let items_search = items ?? self.items
        let searchTags = search.split(separator: " ").map { String($0) }
        
        return items_search.filter { item in item.tags.contains(where: searchTags.contains) }
    }
}


// MARK: Sort
extension ViewModel {
    /// Specifies a sort order.
    /// Supported sorts (both ascending and descending): by title and date
    enum SortBy: String {
        case defaults = "Default"
        case title = "Title ↑"
        case titleDesc = "Title ↓"
        case date = "Date ↑"
        case dateDesc = "Date ↓"
    }
    
    /// Performs a sort based on sort selection.
    /// - Complexity: O(n logn).
    /// - Parameters:
    ///   - sortBy: Sort type.
    ///   - items: Search domain. If nil, uses the whole Model
    /// - Returns: Found items
    func sortItems(_ sortBy: SortBy, _ items: [ItemWrap]? = nil) -> [ItemWrap] {
        let items_sort = items ?? self.items
        
        switch sortBy {
        case .title:
            return items_sort.sorted { ($0.title ?? "") < ($1.title ?? "") }
        case .titleDesc:
            return items_sort.sorted { ($0.title ?? "") > ($1.title ?? "") }
        case .date:
            return items_sort.sorted { $0.date_taten < $1.date_taten }
        case .dateDesc:
            return items_sort.sorted { $0.date_taten > $1.date_taten }
        default:
            return items_sort
        }
    }
}
