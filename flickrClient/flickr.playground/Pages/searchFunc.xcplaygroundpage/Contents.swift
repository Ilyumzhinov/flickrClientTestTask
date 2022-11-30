/*: # Search and sort tests */
import Foundation

typealias Item = ( title: String, tags: [String], date_taken: Date )

let dates: [Date] = [
    "2022-11-28T18:21:57-08:00",
    "2022-11-22T10:35:42-08:00"
]
    .map { ISO8601DateFormatter().date(from: $0)! }

let items: [Item] = [
    ("xzy", ["#tag1", "#tag2", "#tag3"], dates[0]),
    ("not me", ["#tag3"], dates[1])
]
let search = "#tag1 #tag3"


// MARK: - Search
let s = search.split(separator: " ").map { String($0) }
let result = items.filter { item in item.tags.contains(where: s.contains) }
result


// MARK: - Sort
enum SortBy: String {
    case defaults = "Default"
    case title = "Title ⬆️"
    case titleDesc = "Title ⬇️"
    case date = "Date"
    case dateDesc = "Date ⬇️"
}

func sortItems(_ sortType: SortBy) -> [Item] {
    switch sortType {
    case .title:
        return items.sorted { $0.title < $1.title }
    case .titleDesc:
        return items.sorted { $0.title > $1.title }
    case .date:
        return items.sorted { $0.date_taken < $1.date_taken }
    case .dateDesc:
        return items.sorted { $0.date_taken > $1.date_taken }
    default:
        return items
    }
}

sortItems(.dateDesc)
