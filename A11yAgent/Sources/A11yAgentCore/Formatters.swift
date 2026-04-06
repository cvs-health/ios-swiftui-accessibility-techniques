import Foundation

/// Formats diagnostics for terminal output with ANSI colors.
public struct TerminalFormatter {

    public init() {}

    /// Format a list of diagnostics for colored terminal output.
    public func format(_ diagnostics: [A11yDiagnostic], relativeTo basePath: String? = nil, score: A11yScore? = nil) -> String {
        if diagnostics.isEmpty, let score = score {
            var output = "\u{001B}[32m✓ No accessibility issues found.\u{001B}[0m\n"
            output += formatScoreSummary(score)
            return output
        }
        guard !diagnostics.isEmpty else {
            return "\u{001B}[32m✓ No accessibility issues found.\u{001B}[0m\n"
        }

        var output = ""
        var currentFile = ""

        for diag in diagnostics {
            let displayPath: String
            if let base = basePath {
                displayPath = diag.filePath.replacingOccurrences(of: base + "/", with: "")
            } else {
                displayPath = diag.filePath
            }

            // Print file header when file changes
            if displayPath != currentFile {
                if !currentFile.isEmpty { output += "\n" }
                output += "\u{001B}[1m\(displayPath)\u{001B}[0m\n"
                currentFile = displayPath
            }

            // Color by severity
            let severityColor: String
            let severityIcon: String
            switch diag.severity {
            case .error:
                severityColor = "\u{001B}[31m" // red
                severityIcon = "✗"
            case .warning:
                severityColor = "\u{001B}[33m" // yellow
                severityIcon = "⚠"
            case .info:
                severityColor = "\u{001B}[36m" // cyan
                severityIcon = "ℹ"
            }
            let reset = "\u{001B}[0m"

            let wcag = diag.wcagCriteria.isEmpty ? "" : " [WCAG \(diag.wcagCriteria.joined(separator: ", "))]"
            output += "  \(severityColor)\(severityIcon) \(diag.line):\(diag.column)\(reset) "
            output += "\(severityColor)\(diag.severity.rawValue)\(reset): "
            output += "\(diag.message)"
            output += "\u{001B}[2m\(wcag) (\(diag.ruleID))\(reset)\n"
        }

        // Summary
        let errorCount = diagnostics.filter { $0.severity == .error }.count
        let warningCount = diagnostics.filter { $0.severity == .warning }.count
        let infoCount = diagnostics.filter { $0.severity == .info }.count

        output += "\n"
        if errorCount > 0 {
            output += "\u{001B}[31m\(errorCount) error\(errorCount == 1 ? "" : "s")\u{001B}[0m"
        }
        if warningCount > 0 {
            if errorCount > 0 { output += ", " }
            output += "\u{001B}[33m\(warningCount) warning\(warningCount == 1 ? "" : "s")\u{001B}[0m"
        }
        if infoCount > 0 {
            if errorCount > 0 || warningCount > 0 { output += ", " }
            output += "\u{001B}[36m\(infoCount) info\u{001B}[0m"
        }
        output += " in \(Set(diagnostics.map(\.filePath)).count) file\(Set(diagnostics.map(\.filePath)).count == 1 ? "" : "s")\n"

        if let score = score {
            output += formatScoreSummary(score)
        }

        return output
    }

    private func formatScoreSummary(_ score: A11yScore) -> String {
        let reset = "\u{001B}[0m"
        let bold = "\u{001B}[1m"
        let gradeColor: String
        switch score.grade.prefix(1) {
        case "A": gradeColor = "\u{001B}[32m" // green
        case "B": gradeColor = "\u{001B}[32m"
        case "C": gradeColor = "\u{001B}[33m" // yellow
        case "D": gradeColor = "\u{001B}[33m"
        default:  gradeColor = "\u{001B}[31m" // red
        }

        var out = "\n\(bold)Accessibility Score:\(reset) "
        out += "\(gradeColor)\(bold)\(String(format: "%.1f", score.score)) / 100  (\(score.grade))\(reset)\n"

        let principles: [(String, WCAGPrinciple)] = [
            ("Perceivable", .perceivable), ("Operable", .operable),
            ("Understandable", .understandable), ("Robust", .robust)
        ]
        for (name, principle) in principles {
            let pScore = score.principleScores[principle] ?? 100.0
            let pColor = pScore >= 80 ? "\u{001B}[32m" : (pScore >= 50 ? "\u{001B}[33m" : "\u{001B}[31m")
            let filled = Int(pScore / 5.0)
            let empty = 20 - filled
            let bar = String(repeating: "█", count: filled) + String(repeating: "░", count: empty)
            out += "  \(name.padding(toLength: 16, withPad: " ", startingAt: 0))\(pColor)[\(bar)]\(reset)  \(String(format: "%5.1f", pScore))%\n"
        }

        out += "  Criteria: \(score.criteriaPassed) passed, \(score.criteriaFailed) failed"
        out += " (\(score.criteriaPassed + score.criteriaFailed) / \(score.criteriaPassed + score.criteriaFailed + score.criteriaNotChecked) checked)\n"

        return out
    }
}

/// Formats diagnostics for Xcode build phase scripts.
/// Each diagnostic becomes a single line in the format Xcode recognizes:
///   file:line:column: warning: message
public struct XcodeFormatter {

    public init() {}

    public func format(_ diagnostics: [A11yDiagnostic], score: A11yScore? = nil) -> String {
        var output = ""
        for diag in diagnostics {
            let xcodeSeverity: String
            switch diag.severity {
            case .error:   xcodeSeverity = "error"
            case .warning: xcodeSeverity = "warning"
            case .info:    xcodeSeverity = "note"
            }
            let wcag = diag.wcagCriteria.isEmpty ? "" : " [WCAG \(diag.wcagCriteria.joined(separator: ", "))]"
            output += "\(diag.filePath):\(diag.line):\(diag.column): \(xcodeSeverity): [\(diag.ruleID)] \(diag.message)\(wcag)\n"
        }
        if let score = score {
            let severity = score.score >= 80 ? "note" : (score.score >= 50 ? "warning" : "error")
            output += ": \(severity): [a11y-score] Accessibility Score: \(String(format: "%.1f", score.score))/100 (\(score.grade)) — P:\(String(format: "%.0f", score.principleScores[.perceivable] ?? 100))% O:\(String(format: "%.0f", score.principleScores[.operable] ?? 100))% U:\(String(format: "%.0f", score.principleScores[.understandable] ?? 100))% R:\(String(format: "%.0f", score.principleScores[.robust] ?? 100))%\n"
        }
        return output
    }
}

/// Formats diagnostics as JSON for machine consumption.
public struct JSONFormatter {

    public init() {}

    public func format(_ diagnostics: [A11yDiagnostic], score: A11yScore? = nil) throws -> String {
        let items = diagnostics.map { diag -> [String: Any] in
            var dict: [String: Any] = [
                "ruleID": diag.ruleID,
                "severity": diag.severity.rawValue,
                "message": diag.message,
                "filePath": diag.filePath,
                "line": diag.line,
                "column": diag.column,
                "wcagCriteria": diag.wcagCriteria,
            ]
            if let fix = diag.fix {
                dict["fix"] = [
                    "description": fix.description,
                    "replacementText": fix.replacementText,
                ]
            }
            return dict
        }

        let root: Any
        if let score = score {
            var principleDict: [String: Double] = [:]
            for (principle, pScore) in score.principleScores {
                principleDict[principle.rawValue] = pScore
            }
            let scoreDict: [String: Any] = [
                "score": score.score,
                "grade": score.grade,
                "totalErrors": score.totalErrors,
                "totalWarnings": score.totalWarnings,
                "totalInfo": score.totalInfo,
                "criteriaPassed": score.criteriaPassed,
                "criteriaFailed": score.criteriaFailed,
                "criteriaNotChecked": score.criteriaNotChecked,
                "principleScores": principleDict,
            ]
            root = [
                "diagnostics": items,
                "score": scoreDict,
            ] as [String: Any]
        } else {
            root = items
        }

        let data = try JSONSerialization.data(withJSONObject: root, options: [.prettyPrinted, .sortedKeys])
        return String(data: data, encoding: .utf8) ?? "[]"
    }
}
