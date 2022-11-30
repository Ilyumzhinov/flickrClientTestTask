import Foundation
import UIKit

/// Deterministically generates a color from text
/// Reference: https://anoop4real.medium.com/swift-generate-color-hash-uicolor-from-string-names-e0aa129fec6a
/// - Returns: Color
func generateColorFor(text: String) -> UIColor {
    var hash = 0
    let colorConstant = 131
    let maxSafeValue = Int.max / colorConstant
    for char in text.unicodeScalars{
        if hash > maxSafeValue {
            hash = hash / colorConstant
        }
        hash = Int(char.value) + ((hash << 5) - hash)
    }
    let finalHash = abs(hash) % (256*256*256);
    //let color = UIColor(hue:CGFloat(finalHash)/255.0 , saturation: 0.40, brightness: 0.75, alpha: 1.0)
    let color = UIColor(red: CGFloat((finalHash & 0xFF0000) >> 16) / 255.0, green: CGFloat((finalHash & 0xFF00) >> 8) / 255.0, blue: CGFloat((finalHash & 0xFF)) / 255.0, alpha: 1.0)
    return color
}
