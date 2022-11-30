/*: # Regex tests */
import Foundation
import RegexBuilder
let author = "nobody@flickr.com (\"ღღ Callie Akahi-Landry ღღ\")"


func extract_username(author: String) -> String {
    let regex = try Regex(/"(.*?)"/)
    let result = author.matches(of: regex)
    
    return author[result[0].range.lowerBound..<result[0].range.upperBound]
        .replacingOccurrences(of: "\"", with: "")
}

//extract_username(author: author)


func extract_username1(author: String) -> String {
    if let range = author.range(of: "\"(.*?)\"",
                                options: .regularExpression) {
        
        return author[range]
            .replacingOccurrences(of: "\"", with: "")
    }
    return ""
}
//extract_username1(author: author)


// MARK: Format initial
let o = "1"
    .prefix(2)

o
