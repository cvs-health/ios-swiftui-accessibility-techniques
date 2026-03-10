import Foundation

/// Formats diagnostics for terminal output with ANSI colors.
public struct TerminalFormatter {

    public init() {}

    /// Format a list of diagnostics for colored terminal output.
    public func format(_ diagnostics: [A11yDiagnostic], relativeTo basePath: String? = nil) -> String {
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

        return output
    }
}

/// Formats diagnostics as JSON for machine consumption.
public struct JSONFormatter {

    public init() {}

    public func format(_ diagnostics: [A11yDiagnostic]) throws -> String {
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
        let data = try JSONSerialization.data(withJSONObject: items, options: [.prettyPrinted, .sortedKeys])
        return String(data: data, encoding: .utf8) ?? "[]"
    }
}
