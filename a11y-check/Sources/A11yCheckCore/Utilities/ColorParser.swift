import Foundation

/// Parses SwiftUI color expressions into RGBA values.
public enum ColorParser {

    public typealias RGBA = ContrastCalculator.RGBA

    /// SwiftUI named system colors mapped to their approximate sRGB values.
    static let systemColors: [String: RGBA] = [
        ".black":   RGBA(r: 0, g: 0, b: 0),
        ".white":   RGBA(r: 1, g: 1, b: 1),
        ".red":     RGBA(r: 1, g: 0.231, b: 0.188),
        ".orange":  RGBA(r: 1, g: 0.584, b: 0),
        ".yellow":  RGBA(r: 1, g: 0.8, b: 0),
        ".green":   RGBA(r: 0.204, g: 0.78, b: 0.349),
        ".mint":    RGBA(r: 0, g: 0.78, b: 0.745),
        ".teal":    RGBA(r: 0.188, g: 0.686, b: 0.78),
        ".cyan":    RGBA(r: 0.196, g: 0.678, b: 0.902),
        ".blue":    RGBA(r: 0, g: 0.478, b: 1),
        ".indigo":  RGBA(r: 0.345, g: 0.337, b: 0.839),
        ".purple":  RGBA(r: 0.686, g: 0.322, b: 0.871),
        ".pink":    RGBA(r: 1, g: 0.176, b: 0.333),
        ".brown":   RGBA(r: 0.635, g: 0.518, b: 0.369),
        ".gray":    RGBA(r: 0.557, g: 0.557, b: 0.576),
        // Fully-qualified forms
        "Color.black":  RGBA(r: 0, g: 0, b: 0),
        "Color.white":  RGBA(r: 1, g: 1, b: 1),
        "Color.red":    RGBA(r: 1, g: 0.231, b: 0.188),
        "Color.orange": RGBA(r: 1, g: 0.584, b: 0),
        "Color.yellow": RGBA(r: 1, g: 0.8, b: 0),
        "Color.green":  RGBA(r: 0.204, g: 0.78, b: 0.349),
        "Color.mint":   RGBA(r: 0, g: 0.78, b: 0.745),
        "Color.teal":   RGBA(r: 0.188, g: 0.686, b: 0.78),
        "Color.cyan":   RGBA(r: 0.196, g: 0.678, b: 0.902),
        "Color.blue":   RGBA(r: 0, g: 0.478, b: 1),
        "Color.indigo": RGBA(r: 0.345, g: 0.337, b: 0.839),
        "Color.purple": RGBA(r: 0.686, g: 0.322, b: 0.871),
        "Color.pink":   RGBA(r: 1, g: 0.176, b: 0.333),
        "Color.brown":  RGBA(r: 0.635, g: 0.518, b: 0.369),
        "Color.gray":   RGBA(r: 0.557, g: 0.557, b: 0.576),
    ]

    /// Try to resolve a color expression string to an RGBA value.
    /// Handles system colors, Color(red:green:blue:), Color(white:), hex patterns,
    /// and asset catalog named colors.
    public static func parse(
        _ expression: String,
        assetColors: [String: (r: Double, g: Double, b: Double, a: Double)] = [:]
    ) -> RGBA? {
        let trimmed = expression.trimmingCharacters(in: .whitespaces)

        // System named colors
        if let color = systemColors[trimmed] {
            return color
        }

        // Color(red: R, green: G, blue: B) or with optional alpha
        if let rgba = parseColorRGB(trimmed) {
            return rgba
        }

        // Color(white: W) or Color(white: W, opacity: A)
        if let rgba = parseColorWhite(trimmed) {
            return rgba
        }

        // Hex patterns: Color(hex: "RRGGBB") or Color(hex: "#RRGGBB")
        if let rgba = parseColorHex(trimmed) {
            return rgba
        }

        // Asset catalog: Color("MyColorName")
        if let name = parseAssetColorName(trimmed), let asset = assetColors[name] {
            return RGBA(r: asset.r, g: asset.g, b: asset.b, a: asset.a)
        }

        return nil
    }

    // MARK: - Parsers

    /// Parse `Color(red: 0.5, green: 0.3, blue: 0.1)` with optional `opacity:`
    private static func parseColorRGB(_ text: String) -> RGBA? {
        guard text.hasPrefix("Color(") && text.hasSuffix(")") else { return nil }
        guard text.contains("red:") && text.contains("green:") && text.contains("blue:") else { return nil }

        let inner = String(text.dropFirst(6).dropLast(1))
        let parts = inner.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }

        var r: Double?, g: Double?, b: Double?, a: Double = 1.0
        for part in parts {
            if part.hasPrefix("red:") {
                r = Double(part.dropFirst(4).trimmingCharacters(in: .whitespaces))
            } else if part.hasPrefix("green:") {
                g = Double(part.dropFirst(6).trimmingCharacters(in: .whitespaces))
            } else if part.hasPrefix("blue:") {
                b = Double(part.dropFirst(5).trimmingCharacters(in: .whitespaces))
            } else if part.hasPrefix("opacity:") {
                a = Double(part.dropFirst(8).trimmingCharacters(in: .whitespaces)) ?? 1.0
            }
        }

        guard let rr = r, let gg = g, let bb = b else { return nil }
        return RGBA(r: rr, g: gg, b: bb, a: a)
    }

    /// Parse `Color(white: 0.5)` with optional `opacity:`
    private static func parseColorWhite(_ text: String) -> RGBA? {
        guard text.hasPrefix("Color(") && text.hasSuffix(")") else { return nil }
        guard text.contains("white:") else { return nil }

        let inner = String(text.dropFirst(6).dropLast(1))
        let parts = inner.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }

        var w: Double?
        var a: Double = 1.0
        for part in parts {
            if part.hasPrefix("white:") {
                w = Double(part.dropFirst(6).trimmingCharacters(in: .whitespaces))
            } else if part.hasPrefix("opacity:") {
                a = Double(part.dropFirst(8).trimmingCharacters(in: .whitespaces)) ?? 1.0
            }
        }

        guard let ww = w else { return nil }
        return RGBA(r: ww, g: ww, b: ww, a: a)
    }

    /// Parse `Color(hex: "FF0000")` or `Color(hex: "#FF0000")`
    private static func parseColorHex(_ text: String) -> RGBA? {
        guard text.hasPrefix("Color(") && text.hasSuffix(")") else { return nil }
        guard text.contains("hex:") else { return nil }

        let inner = String(text.dropFirst(6).dropLast(1))
        guard let hexStart = inner.range(of: "hex:") else { return nil }
        var hexStr = inner[hexStart.upperBound...].trimmingCharacters(in: .whitespaces)
        hexStr = hexStr.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
        hexStr = hexStr.replacingOccurrences(of: "#", with: "")

        return parseHexString(hexStr)
    }

    /// Parse a 6 or 8 character hex string to RGBA.
    static func parseHexString(_ hex: String) -> RGBA? {
        let chars = Array(hex)
        guard chars.count == 6 || chars.count == 8 else { return nil }

        guard let rInt = UInt8(String(chars[0...1]), radix: 16),
              let gInt = UInt8(String(chars[2...3]), radix: 16),
              let bInt = UInt8(String(chars[4...5]), radix: 16) else { return nil }

        var a: Double = 1.0
        if chars.count == 8 {
            if let aInt = UInt8(String(chars[6...7]), radix: 16) {
                a = Double(aInt) / 255.0
            }
        }

        return RGBA(r: Double(rInt) / 255.0, g: Double(gInt) / 255.0, b: Double(bInt) / 255.0, a: a)
    }

    /// Extract asset catalog color name from `Color("name")`.
    static func parseAssetColorName(_ text: String) -> String? {
        guard text.hasPrefix("Color(\"") && text.hasSuffix("\")") else { return nil }
        let name = String(text.dropFirst(7).dropLast(2))
        guard !name.isEmpty, !name.contains("red:"), !name.contains("hex:") else { return nil }
        return name
    }
}
