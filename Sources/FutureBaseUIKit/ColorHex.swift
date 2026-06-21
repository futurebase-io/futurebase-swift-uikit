import Foundation

/// Parses a CSS-style hex color string into RGBA components in 0...1.
/// Accepts `#RGB`, `#RRGGBB`, `#RRGGBBAA` (with or without leading `#`).
/// Returns `nil` for malformed input. Pure function — unit-tested directly.
func rgba(fromHex raw: String) -> (r: Double, g: Double, b: Double, a: Double)? {
    var hex = raw.trimmingCharacters(in: .whitespacesAndNewlines)
    if hex.hasPrefix("#") { hex.removeFirst() }

    // Expand 3-digit shorthand (#RGB -> #RRGGBB).
    if hex.count == 3 {
        hex = hex.map { "\($0)\($0)" }.joined()
    }

    guard hex.count == 6 || hex.count == 8 else { return nil }
    guard let value = UInt64(hex, radix: 16) else { return nil }

    if hex.count == 6 {
        let r = Double((value & 0xFF0000) >> 16) / 255.0
        let g = Double((value & 0x00FF00) >> 8) / 255.0
        let b = Double(value & 0x0000FF) / 255.0
        return (r, g, b, 1.0)
    } else {
        let r = Double((value & 0xFF000000) >> 24) / 255.0
        let g = Double((value & 0x00FF0000) >> 16) / 255.0
        let b = Double((value & 0x0000FF00) >> 8) / 255.0
        let a = Double(value & 0x000000FF) / 255.0
        return (r, g, b, a)
    }
}

#if canImport(UIKit)
import UIKit

extension UIColor {
    /// Creates a `UIColor` from a hex string, or returns `nil` if it can't be parsed.
    convenience init?(hex: String) {
        guard let c = rgba(fromHex: hex) else { return nil }
        self.init(red: c.r, green: c.g, blue: c.b, alpha: c.a)
    }
}
#endif
