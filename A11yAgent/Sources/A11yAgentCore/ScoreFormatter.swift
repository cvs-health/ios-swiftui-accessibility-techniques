import Foundation

/// Formats A11yScore results for terminal output with ANSI colors.
public struct ScoreTerminalFormatter {

    public init() {}

    public func format(_ score: A11yScore, relativeTo basePath: String? = nil) -> String {
        var output = ""

        // Header
        output += "\u{001B}[1m╔══════════════════════════════════════════════════╗\u{001B}[0m\n"
        output += "\u{001B}[1m║       a11y-check  WCAG 2.2 Accessibility Score  ║\u{001B}[0m\n"
        output += "\u{001B}[1m╚══════════════════════════════════════════════════╝\u{001B}[0m\n\n"

        // Overall score and grade
        let scoreColor = colorForScore(score.score)
        output += "\u{001B}[1m  Overall Score: \(scoreColor)\(String(format: "%.1f", score.score)) / 100  (\(score.grade))\u{001B}[0m\n\n"

        // Principle scores
        output += "\u{001B}[1m  WCAG Principles:\u{001B}[0m\n"
        let principleOrder: [WCAGPrinciple] = [.perceivable, .operable, .understandable, .robust]
        for principle in principleOrder {
            let pScore = score.principleScores[principle] ?? 100.0
            let bar = progressBar(pScore)
            let pColor = colorForScore(pScore)
            output += "    \(principle.rawValue.padding(toLength: 15, withPad: " ", startingAt: 0)) \(bar)  \(pColor)\(String(format: "%5.1f", pScore))%\u{001B}[0m\n"
        }
        output += "\n"

        // Summary stats
        output += "\u{001B}[1m  Summary:\u{001B}[0m\n"
        output += "    Files analyzed:     \(score.filesAnalyzed)\n"
        output += "    Criteria checked:   \(score.criteriaPassed + score.criteriaFailed) / \(score.criteriaPassed + score.criteriaFailed + score.criteriaNotChecked)\n"
        output += "    Criteria passed:    \u{001B}[32m\(score.criteriaPassed)\u{001B}[0m\n"
        output += "    Criteria failed:    \u{001B}[31m\(score.criteriaFailed)\u{001B}[0m\n"
        output += "    Total errors:       \u{001B}[31m\(score.totalErrors)\u{001B}[0m\n"
        output += "    Total warnings:     \u{001B}[33m\(score.totalWarnings)\u{001B}[0m\n"
        output += "    Total info:         \u{001B}[36m\(score.totalInfo)\u{001B}[0m\n\n"

        // WCAG criteria breakdown
        output += "\u{001B}[1m  WCAG 2.2 Criteria:\u{001B}[0m\n"
        var currentPrinciple: WCAGPrinciple?
        for cs in score.criteriaScores {
            if cs.principle != currentPrinciple {
                currentPrinciple = cs.principle
                output += "\n    \u{001B}[1m\u{001B}[4m\(cs.principle.rawValue)\u{001B}[0m\n"
            }

            let statusIcon: String
            let statusColor: String
            switch cs.status {
            case .pass:
                statusIcon = "✓"
                statusColor = "\u{001B}[32m"
            case .fail:
                statusIcon = "✗"
                statusColor = "\u{001B}[31m"
            case .review:
                statusIcon = "⚠"
                statusColor = "\u{001B}[33m"
            case .notChecked:
                statusIcon = "·"
                statusColor = "\u{001B}[90m"
            }

            let criterion = cs.criterion.padding(toLength: 7, withPad: " ", startingAt: 0)
            let name = cs.name.padding(toLength: 42, withPad: " ", startingAt: 0)
            let level = "(\(cs.level.rawValue))".padding(toLength: 5, withPad: " ", startingAt: 0)

            output += "    \(statusColor)\(statusIcon) \(criterion) \(name) \(level)\u{001B}[0m"
            if cs.errorCount > 0 {
                output += " \u{001B}[31m\(cs.errorCount)E\u{001B}[0m"
            }
            if cs.warningCount > 0 {
                output += " \u{001B}[33m\(cs.warningCount)W\u{001B}[0m"
            }
            output += "\n"
        }
        output += "\n"

        // Per-file scores (top 10 worst + top 5 best if many files)
        if !score.fileScores.isEmpty {
            let sorted = score.fileScores.sorted { $0.score < $1.score }
            let worstFiles = Array(sorted.prefix(10))

            if !worstFiles.isEmpty && worstFiles.first!.score < 100.0 {
                output += "\u{001B}[1m  Lowest Scoring Files:\u{001B}[0m\n"
                for fs in worstFiles {
                    let displayPath: String
                    if let base = basePath {
                        displayPath = fs.filePath.replacingOccurrences(of: base + "/", with: "")
                    } else {
                        displayPath = (fs.filePath as NSString).lastPathComponent
                    }
                    let fColor = colorForScore(fs.score)
                    output += "    \(fColor)\(String(format: "%5.1f", fs.score))\u{001B}[0m  \(displayPath)"
                    if fs.errorCount > 0 { output += " \u{001B}[31m(\(fs.errorCount)E)\u{001B}[0m" }
                    if fs.warningCount > 0 { output += " \u{001B}[33m(\(fs.warningCount)W)\u{001B}[0m" }
                    output += "\n"
                }
                output += "\n"
            }
        }

        // Legend
        output += "\u{001B}[90m  Legend: ✓ Pass  ✗ Fail  ⚠ Review  · Not Checked\u{001B}[0m\n"

        return output
    }

    private func progressBar(_ value: Double) -> String {
        let width = 20
        let filled = Int((value / 100.0) * Double(width))
        let empty = width - filled
        let color = colorForScore(value)
        return "\(color)[\(String(repeating: "█", count: filled))\(String(repeating: "░", count: empty))]\u{001B}[0m"
    }

    private func colorForScore(_ score: Double) -> String {
        switch score {
        case 90...100: return "\u{001B}[32m"  // green
        case 70..<90:  return "\u{001B}[33m"  // yellow
        case 50..<70:  return "\u{001B}[38;5;208m" // orange
        default:       return "\u{001B}[31m"  // red
        }
    }
}

/// Formats A11yScore results as JSON.
public struct ScoreJSONFormatter {

    public init() {}

    public func format(_ score: A11yScore) throws -> String {
        var dict: [String: Any] = [
            "score": score.score,
            "grade": score.grade,
            "filesAnalyzed": score.filesAnalyzed,
            "totalErrors": score.totalErrors,
            "totalWarnings": score.totalWarnings,
            "totalInfo": score.totalInfo,
            "criteriaPassed": score.criteriaPassed,
            "criteriaFailed": score.criteriaFailed,
            "criteriaNotChecked": score.criteriaNotChecked,
        ]

        // Principle scores
        var principles: [String: Any] = [:]
        for (principle, pScore) in score.principleScores {
            principles[principle.rawValue] = (pScore * 10).rounded() / 10
        }
        dict["principleScores"] = principles

        // Criteria
        let criteria = score.criteriaScores.map { cs -> [String: Any] in
            [
                "criterion": cs.criterion,
                "name": cs.name,
                "principle": cs.principle.rawValue,
                "level": cs.level.rawValue,
                "status": cs.status.rawValue,
                "errorCount": cs.errorCount,
                "warningCount": cs.warningCount,
                "ruleIDs": cs.ruleIDs,
            ]
        }
        dict["criteria"] = criteria

        // File scores
        let files = score.fileScores.map { fs -> [String: Any] in
            [
                "filePath": fs.filePath,
                "score": (fs.score * 10).rounded() / 10,
                "errorCount": fs.errorCount,
                "warningCount": fs.warningCount,
                "infoCount": fs.infoCount,
            ]
        }
        dict["fileScores"] = files

        let data = try JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys])
        return String(data: data, encoding: .utf8) ?? "{}"
    }
}
