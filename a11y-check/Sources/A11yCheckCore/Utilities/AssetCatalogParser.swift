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

/// Discovers and parses color definitions from `.xcassets` catalogs.
public enum AssetCatalogParser {

    /// A color resolved for all appearance themes present in a .colorset.
    public struct ThemedColor {
        /// Universal / light-mode RGBA.
        public let light: ContrastCalculator.RGBA
        /// Dark-mode RGBA, if the colorset defines one.
        public let dark: ContrastCalculator.RGBA?
        /// Light + Increase Contrast RGBA, if defined.
        public let highContrast: ContrastCalculator.RGBA?
        /// Dark + Increase Contrast RGBA, if defined.
        public let darkHighContrast: ContrastCalculator.RGBA?

        public init(
            light: ContrastCalculator.RGBA,
            dark: ContrastCalculator.RGBA? = nil,
            highContrast: ContrastCalculator.RGBA? = nil,
            darkHighContrast: ContrastCalculator.RGBA? = nil
        ) {
            self.light = light
            self.dark = dark
            self.highContrast = highContrast
            self.darkHighContrast = darkHighContrast
        }

        /// Resolve to the best available RGBA for the given appearance.
        public func resolve(darkMode: Bool, contrastMode: Bool) -> ContrastCalculator.RGBA {
            if darkMode && contrastMode { return darkHighContrast ?? dark ?? highContrast ?? light }
            if darkMode { return dark ?? light }
            if contrastMode { return highContrast ?? light }
            return light
        }

        public var hasDarkVariant: Bool { dark != nil || darkHighContrast != nil }
        public var hasHighContrastVariant: Bool { highContrast != nil || darkHighContrast != nil }
    }

    /// Per-color-name themed map returned by ``discoverColors(in:)``.
    public typealias ThemedColorMap = [String: ThemedColor]

    /// Flat single-RGBA map kept for backward compatibility.
    public typealias ColorMap = [String: (r: Double, g: Double, b: Double, a: Double)]

    /// Scan a directory tree for `.xcassets` and extract all named color definitions,
    /// including dark-mode and high-contrast appearance variants.
    public static func discoverColors(in directory: String) -> ThemedColorMap {
        let fm = FileManager.default
        var isDir: ObjCBool = false
        guard fm.fileExists(atPath: directory, isDirectory: &isDir), isDir.boolValue else {
            return [:]
        }

        var result: ThemedColorMap = [:]
        guard let enumerator = fm.enumerator(atPath: directory) else { return [:] }

        while let relativePath = enumerator.nextObject() as? String {
            guard relativePath.hasSuffix(".colorset") else { continue }
            let contentsPath = (directory as NSString)
                .appendingPathComponent(relativePath)
                .appending("/Contents.json")
            guard fm.fileExists(atPath: contentsPath) else { continue }

            let colorSetName = ((relativePath as NSString).lastPathComponent as NSString)
                .deletingPathExtension

            if let themed = parseColorSet(at: contentsPath) {
                result[colorSetName] = themed
            }
        }

        return result
    }

    /// Parse a single Contents.json from a .colorset directory, returning all appearance variants.
    static func parseColorSet(at path: String) -> ThemedColor? {
        guard let data = FileManager.default.contents(atPath: path),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let colors = json["colors"] as? [[String: Any]] else {
            return nil
        }

        var lightRGBA: ContrastCalculator.RGBA?
        var darkRGBA: ContrastCalculator.RGBA?
        var highContrastRGBA: ContrastCalculator.RGBA?
        var darkHighContrastRGBA: ContrastCalculator.RGBA?

        for entry in colors {
            guard let rgba = extractRGBA(from: entry) else { continue }
            let appearances = entry["appearances"] as? [[String: Any]] ?? []

            let isDark = appearances.contains { app in
                (app["appearance"] as? String) == "luminosity" &&
                (app["value"] as? String) == "dark"
            }
            let isHighContrast = appearances.contains { app in
                (app["appearance"] as? String) == "contrast" &&
                (app["value"] as? String) == "high"
            }

            switch (isDark, isHighContrast) {
            case (false, false): lightRGBA = rgba        // universal
            case (true, false):  darkRGBA = rgba
            case (false, true):  highContrastRGBA = rgba
            case (true, true):   darkHighContrastRGBA = rgba
            }
        }

        guard let light = lightRGBA else { return nil }
        return ThemedColor(
            light: light,
            dark: darkRGBA,
            highContrast: highContrastRGBA,
            darkHighContrast: darkHighContrastRGBA
        )
    }

    // MARK: - Private helpers

    private static func extractRGBA(from entry: [String: Any]) -> ContrastCalculator.RGBA? {
        guard let color = entry["color"] as? [String: Any],
              let components = color["components"] as? [String: String] else {
            return nil
        }
        guard let r = parseComponent(components["red"]),
              let g = parseComponent(components["green"]),
              let b = parseComponent(components["blue"]) else {
            return nil
        }
        let a = parseComponent(components["alpha"]) ?? 1.0
        return ContrastCalculator.RGBA(r: r, g: g, b: b, a: a)
    }

    /// Parse a color component which may be a float string ("0.500"), hex ("0xFF"), or integer.
    private static func parseComponent(_ value: String?) -> Double? {
        guard let value = value?.trimmingCharacters(in: .whitespaces), !value.isEmpty else {
            return nil
        }

        if value.hasPrefix("0x") || value.hasPrefix("0X") {
            let hex = String(value.dropFirst(2))
            guard let intVal = UInt8(hex, radix: 16) else { return nil }
            return Double(intVal) / 255.0
        }

        guard let doubleVal = Double(value) else { return nil }
        if doubleVal > 1.0 {
            return doubleVal / 255.0
        }
        return doubleVal
    }
}
