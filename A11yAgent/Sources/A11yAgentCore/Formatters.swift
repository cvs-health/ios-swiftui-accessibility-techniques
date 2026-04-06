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
        let dim = "\u{001B}[2m"
        let red = "\u{001B}[31m"
        let gradeColor: String
        switch score.grade.prefix(1) {
        case "A": gradeColor = "\u{001B}[32m" // green
        case "B": gradeColor = "\u{001B}[32m"
        case "C": gradeColor = "\u{001B}[33m" // yellow
        case "D": gradeColor = "\u{001B}[33m"
        default:  gradeColor = "\u{001B}[31m" // red
        }

        var out = "\n\(bold)WCAG Score:\(reset) "
        out += "\(gradeColor)\(bold)\(String(format: "%.1f", score.score)) / 100  (\(score.grade))\(reset)\n"
        let filled = Int(score.score / 5.0)
        let empty = 20 - filled
        let bar = String(repeating: "\u{2588}", count: filled) + String(repeating: "\u{2591}", count: empty)
        out += "  \(gradeColor)[\(bar)]\(reset)  \(String(format: "%5.1f", score.score))%"
        out += "  \(dim)\(score.criteriaPassed) criteria passed, \(score.criteriaFailed) failed"
        out += " — \(score.totalErrors) errors, \(score.totalWarnings) warnings\(reset)\n"

        // Show failed criteria
        let failed = score.criteriaScores.filter { $0.status == .fail }
        if !failed.isEmpty {
            out += "\n\(red)\(bold)Failed WCAG criteria:\(reset)\n"
            for cs in failed {
                var counts: [String] = []
                if cs.errorCount > 0 { counts.append("\(cs.errorCount) \(cs.errorCount == 1 ? "error" : "errors")") }
                if cs.warningCount > 0 { counts.append("\(cs.warningCount) \(cs.warningCount == 1 ? "warning" : "warnings")") }
                out += "  \(red)\u{2717}\(reset) \(bold)\(cs.criterion)\(reset) \(cs.name)"
                out += "  \(dim)(\(counts.joined(separator: ", ")))\(reset)\n"
            }
        }

        // Show review criteria
        let review = score.criteriaScores.filter { $0.status == .review }
        if !review.isEmpty {
            let yellow = "\u{001B}[33m"
            out += "\(yellow)\(bold)Needs review:\(reset)\n"
            for cs in review {
                out += "  \(yellow)\u{26a0}\(reset) \(bold)\(cs.criterion)\(reset) \(cs.name)"
                out += "  \(dim)(\(cs.warningCount) \(cs.warningCount == 1 ? "warning" : "warnings"))\(reset)\n"
            }
        }

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
            let failed = score.criteriaScores.filter { $0.status == .fail }.map { $0.criterion }
            let failedStr = failed.isEmpty ? "none" : failed.joined(separator: ", ")
            output += ": \(severity): [a11y-score] WCAG Score: \(String(format: "%.1f", score.score))/100 (\(score.grade)) \u{2014} Failed: \(failedStr)\n"
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
            let failed = score.criteriaScores.filter { $0.status == .fail }.map { cs -> [String: Any] in
                ["criterion": cs.criterion, "name": cs.name, "errors": cs.errorCount, "warnings": cs.warningCount]
            }
            let review = score.criteriaScores.filter { $0.status == .review }.map { cs -> [String: Any] in
                ["criterion": cs.criterion, "name": cs.name, "warnings": cs.warningCount]
            }
            let scoreDict: [String: Any] = [
                "score": score.score,
                "grade": score.grade,
                "totalErrors": score.totalErrors,
                "totalWarnings": score.totalWarnings,
                "totalInfo": score.totalInfo,
                "criteriaPassed": score.criteriaPassed,
                "criteriaFailed": score.criteriaFailed,
                "failedCriteria": failed,
                "reviewCriteria": review,
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
