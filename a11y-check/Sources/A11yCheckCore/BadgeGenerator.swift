import Foundation

/// Generates SVG badges showing the a11y-check score.
/// Compatible with shields.io style badges.
public struct BadgeGenerator {

    public init() {}

    /// Generate an SVG badge string for the given score.
    public func generate(score: A11yScore) -> String {
        let color = badgeColor(for: score.score)
        let label = "a11y score"
        let value = "\(String(format: "%.0f", score.score))% \(score.grade)"
        let labelWidth = label.count * 7 + 10
        let valueWidth = value.count * 7 + 10
        let totalWidth = labelWidth + valueWidth

        return """
        <svg xmlns="http://www.w3.org/2000/svg" width="\(totalWidth)" height="20" role="img" aria-label="\(label): \(value)">
          <title>\(label): \(value)</title>
          <linearGradient id="s" x2="0" y2="100%">
            <stop offset="0" stop-color="#bbb" stop-opacity=".1"/>
            <stop offset="1" stop-opacity=".1"/>
          </linearGradient>
          <clipPath id="r">
            <rect width="\(totalWidth)" height="20" rx="3" fill="#fff"/>
          </clipPath>
          <g clip-path="url(#r)">
            <rect width="\(labelWidth)" height="20" fill="#555"/>
            <rect x="\(labelWidth)" width="\(valueWidth)" height="20" fill="\(color)"/>
            <rect width="\(totalWidth)" height="20" fill="url(#s)"/>
          </g>
          <g fill="#fff" text-anchor="middle" font-family="Verdana,Geneva,DejaVu Sans,sans-serif" text-rendering="geometricPrecision" font-size="11">
            <text aria-hidden="true" x="\(labelWidth / 2)" y="15" fill="#010101" fill-opacity=".3">\(label)</text>
            <text x="\(labelWidth / 2)" y="14" fill="#fff">\(label)</text>
            <text aria-hidden="true" x="\(labelWidth + valueWidth / 2)" y="15" fill="#010101" fill-opacity=".3">\(value)</text>
            <text x="\(labelWidth + valueWidth / 2)" y="14" fill="#fff">\(value)</text>
          </g>
        </svg>
        """
    }

    /// Generate a Markdown shields.io badge URL.
    public func shieldsURL(score: A11yScore) -> String {
        let color = shieldsColor(for: score.score)
        let value = "\(String(format: "%.0f", score.score))%25 \(score.grade)"
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        return "https://img.shields.io/badge/a11y_score-\(value)-\(color)"
    }

    private func badgeColor(for score: Double) -> String {
        switch score {
        case 90...: return "#4c1"    // bright green
        case 80...: return "#97CA00" // green
        case 70...: return "#a4a61d" // yellow-green
        case 60...: return "#dfb317" // yellow
        case 50...: return "#fe7d37" // orange
        default:    return "#e05d44" // red
        }
    }

    private func shieldsColor(for score: Double) -> String {
        switch score {
        case 90...: return "brightgreen"
        case 80...: return "green"
        case 70...: return "yellowgreen"
        case 60...: return "yellow"
        case 50...: return "orange"
        default:    return "red"
        }
    }
}
