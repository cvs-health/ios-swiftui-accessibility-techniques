import Foundation

/// Discovers and parses color definitions from `.xcassets` catalogs.
public enum AssetCatalogParser {

    public typealias ColorMap = [String: (r: Double, g: Double, b: Double, a: Double)]

    /// Scan a directory tree for `.xcassets` and extract all named color definitions.
    public static func discoverColors(in directory: String) -> ColorMap {
        let fm = FileManager.default
        var isDir: ObjCBool = false
        guard fm.fileExists(atPath: directory, isDirectory: &isDir), isDir.boolValue else {
            return [:]
        }

        var result: ColorMap = [:]
        guard let enumerator = fm.enumerator(atPath: directory) else { return [:] }

        while let relativePath = enumerator.nextObject() as? String {
            // Look for .colorset directories inside .xcassets
            guard relativePath.hasSuffix(".colorset") else { continue }
            let contentsPath = (directory as NSString)
                .appendingPathComponent(relativePath)
                .appending("/Contents.json")
            guard fm.fileExists(atPath: contentsPath) else { continue }

            // Color name is the .colorset directory name minus extension
            let colorSetName = ((relativePath as NSString).lastPathComponent as NSString)
                .deletingPathExtension

            if let rgba = parseColorSet(at: contentsPath) {
                result[colorSetName] = rgba
            }
        }

        return result
    }

    /// Parse a single Contents.json from a .colorset directory.
    /// Returns the "universal" (light mode) color if available.
    static func parseColorSet(at path: String) -> (r: Double, g: Double, b: Double, a: Double)? {
        guard let data = FileManager.default.contents(atPath: path),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let colors = json["colors"] as? [[String: Any]] else {
            return nil
        }

        // Prefer the universal appearance (no "appearances" key, or idiom "universal")
        let universalEntry = colors.first { entry in
            let appearances = entry["appearances"] as? [[String: Any]]
            return appearances == nil || appearances?.isEmpty == true
        } ?? colors.first

        guard let entry = universalEntry,
              let color = entry["color"] as? [String: Any],
              let components = color["components"] as? [String: String] else {
            return nil
        }

        guard let r = parseComponent(components["red"]),
              let g = parseComponent(components["green"]),
              let b = parseComponent(components["blue"]) else {
            return nil
        }
        let a = parseComponent(components["alpha"]) ?? 1.0

        return (r: r, g: g, b: b, a: a)
    }

    /// Parse a color component which may be a float string ("0.500"), hex ("0xFF"), or integer.
    private static func parseComponent(_ value: String?) -> Double? {
        guard let value = value?.trimmingCharacters(in: .whitespaces), !value.isEmpty else {
            return nil
        }

        // Hex format: "0x1A" or "0xFF"
        if value.hasPrefix("0x") || value.hasPrefix("0X") {
            let hex = String(value.dropFirst(2))
            guard let intVal = UInt8(hex, radix: 16) else { return nil }
            return Double(intVal) / 255.0
        }

        // Float/integer string
        guard let doubleVal = Double(value) else { return nil }

        // Values > 1.0 are likely 0-255 range
        if doubleVal > 1.0 {
            return doubleVal / 255.0
        }
        return doubleVal
    }
}
