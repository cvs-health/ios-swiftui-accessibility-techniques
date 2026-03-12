import Foundation

/// WCAG 2.x contrast ratio calculation.
public enum ContrastCalculator {

    public struct RGBA: Equatable, Sendable {
        public let r: Double
        public let g: Double
        public let b: Double
        public let a: Double

        public init(r: Double, g: Double, b: Double, a: Double = 1.0) {
            self.r = r
            self.g = g
            self.b = b
            self.a = a
        }
    }

    /// Linearize an sRGB component (0..1) for luminance calculation.
    private static func linearize(_ c: Double) -> Double {
        if c <= 0.04045 {
            return c / 12.92
        }
        return pow((c + 0.055) / 1.055, 2.4)
    }

    /// Relative luminance per WCAG 2.x (0..1).
    public static func relativeLuminance(_ color: RGBA) -> Double {
        let r = linearize(color.r)
        let g = linearize(color.g)
        let b = linearize(color.b)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }

    /// Contrast ratio between two colors (1..21).
    public static func contrastRatio(_ c1: RGBA, _ c2: RGBA) -> Double {
        let l1 = relativeLuminance(c1)
        let l2 = relativeLuminance(c2)
        let lighter = max(l1, l2)
        let darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }

    /// WCAG AA threshold for normal text.
    public static let aaNormalText: Double = 4.5

    /// WCAG AA threshold for large text (18pt+ or 14pt+ bold).
    public static let aaLargeText: Double = 3.0

    /// WCAG AAA threshold for normal text.
    public static let aaaNormalText: Double = 7.0

    /// Format a ratio for display, e.g. "3.2:1".
    public static func formatRatio(_ ratio: Double) -> String {
        String(format: "%.1f:1", ratio)
    }
}
