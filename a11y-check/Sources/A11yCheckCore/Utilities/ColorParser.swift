/*
   Copyright 2026 CVS Health and/or one of its affiliates

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */

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

    /// Try to resolve a color expression string to an RGBA value (light/universal appearance).
    /// Handles system colors, Color(red:green:blue:), Color(white:), hex patterns,
    /// and asset catalog named colors.
    public static func parse(
        _ expression: String,
        assetColors: AssetCatalogParser.ThemedColorMap = [:]
    ) -> RGBA? {
        parseThemed(expression, assetColors: assetColors)?.light
    }

    /// Resolve a color expression to a ``AssetCatalogParser/ThemedColor`` that carries
    /// dark-mode and high-contrast variants for asset catalog colors.
    /// Non-asset colors (system, RGB literal, hex) always return a light-only themed color.
    public static func parseThemed(
        _ expression: String,
        assetColors: AssetCatalogParser.ThemedColorMap = [:]
    ) -> AssetCatalogParser.ThemedColor? {
        let trimmed = expression.trimmingCharacters(in: .whitespaces)

        // System named colors (not theme-aware — wrap in light-only ThemedColor)
        if let color = systemColors[trimmed] {
            return AssetCatalogParser.ThemedColor(light: color)
        }

        if let rgba = parseColorRGB(trimmed) {
            return AssetCatalogParser.ThemedColor(light: rgba)
        }

        if let rgba = parseColorWhite(trimmed) {
            return AssetCatalogParser.ThemedColor(light: rgba)
        }

        if let rgba = parseColorHSB(trimmed) {
            return AssetCatalogParser.ThemedColor(light: rgba)
        }

        if let rgba = parseColorHex(trimmed) {
            return AssetCatalogParser.ThemedColor(light: rgba)
        }

        // Asset catalog: Color("MyColorName") — may have dark/highContrast variants
        if let name = parseAssetColorName(trimmed), let themed = assetColors[name] {
            return themed
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

    /// Parse `Color(hue: 0.5, saturation: 1, brightness: 0.8)` with optional `opacity:`.
    /// Converts HSB to sRGB so the contrast calculator can use it.
    private static func parseColorHSB(_ text: String) -> RGBA? {
        guard text.hasPrefix("Color(") && text.hasSuffix(")") else { return nil }
        guard text.contains("hue:") && text.contains("saturation:") && text.contains("brightness:") else {
            return nil
        }
        let inner = String(text.dropFirst(6).dropLast())
        let parts = inner.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        var h: Double?, s: Double?, v: Double?
        var a: Double = 1.0
        for part in parts {
            if part.hasPrefix("hue:") {
                h = Double(part.dropFirst(4).trimmingCharacters(in: .whitespaces))
            } else if part.hasPrefix("saturation:") {
                s = Double(part.dropFirst(11).trimmingCharacters(in: .whitespaces))
            } else if part.hasPrefix("brightness:") {
                v = Double(part.dropFirst(11).trimmingCharacters(in: .whitespaces))
            } else if part.hasPrefix("opacity:") {
                a = Double(part.dropFirst(8).trimmingCharacters(in: .whitespaces)) ?? 1.0
            }
        }
        guard let hue = h, let sat = s, let bright = v else { return nil }
        return hsbToRGBA(hue: hue, saturation: sat, brightness: bright, alpha: a)
    }

    /// Standard HSB to sRGB conversion. `hue` is a 0–1 fraction, matching SwiftUI.
    static func hsbToRGBA(hue: Double, saturation: Double, brightness: Double, alpha: Double) -> RGBA {
        let s = min(max(saturation, 0), 1)
        let v = min(max(brightness, 0), 1)
        guard s > 0 else { return RGBA(r: v, g: v, b: v, a: alpha) }

        // Wrap hue into 0–1 so values like 1.25 behave the way SwiftUI renders them.
        var h = hue.truncatingRemainder(dividingBy: 1)
        if h < 0 { h += 1 }
        let sector = h * 6
        let i = Int(sector) % 6
        let f = sector - Double(Int(sector))
        let p = v * (1 - s)
        let q = v * (1 - s * f)
        let t = v * (1 - s * (1 - f))

        switch i {
        case 0: return RGBA(r: v, g: t, b: p, a: alpha)
        case 1: return RGBA(r: q, g: v, b: p, a: alpha)
        case 2: return RGBA(r: p, g: v, b: t, a: alpha)
        case 3: return RGBA(r: p, g: q, b: v, a: alpha)
        case 4: return RGBA(r: t, g: p, b: v, a: alpha)
        default: return RGBA(r: v, g: p, b: q, a: alpha)
        }
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
