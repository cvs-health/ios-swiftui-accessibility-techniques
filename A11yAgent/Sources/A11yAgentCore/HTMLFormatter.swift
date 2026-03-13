import Foundation

/// Generates a self-contained HTML report with WCAG conformance summary.
public struct HTMLFormatter {

    public init() {}

    public func format(_ diagnostics: [A11yDiagnostic], allRules: [any A11yRule]) -> String {
        let errorCount = diagnostics.filter { $0.severity == .error }.count
        let warningCount = diagnostics.filter { $0.severity == .warning }.count
        let infoCount = diagnostics.filter { $0.severity == .info }.count
        let fileCount = Set(diagnostics.map(\.filePath)).count
        let timestamp = ISO8601DateFormatter().string(from: Date())

        // Group by WCAG criteria
        let allCriteria = Set(allRules.flatMap(\.wcagCriteria)).sorted()
        let diagsByCriterion = Dictionary(grouping: diagnostics) { diag -> [String] in
            diag.wcagCriteria
        }
        let flatCriterionDiags: [String: [A11yDiagnostic]] = {
            var result: [String: [A11yDiagnostic]] = [:]
            for (criteria, diags) in diagsByCriterion {
                for c in criteria {
                    result[c, default: []].append(contentsOf: diags)
                }
            }
            return result
        }()

        // Group by file
        let diagsByFile = Dictionary(grouping: diagnostics, by: \.filePath)

        // Group by rule
        let diagsByRule = Dictionary(grouping: diagnostics, by: \.ruleID)

        var html = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>a11y-check Report</title>
        <style>
        :root {
          --bg: #f8f9fa; --card-bg: #fff; --text: #1a1a2e; --border: #dee2e6;
          --error: #dc3545; --error-bg: #f8d7da; --warning: #856404; --warning-bg: #fff3cd;
          --info: #0c5460; --info-bg: #d1ecf1; --pass: #155724; --pass-bg: #d4edda;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: var(--bg); color: var(--text); line-height: 1.6; padding: 2rem; max-width: 1200px; margin: 0 auto; }
        h1 { font-size: 1.75rem; margin-bottom: 0.5rem; }
        .timestamp { color: #6c757d; font-size: 0.875rem; margin-bottom: 1.5rem; }
        .summary { display: flex; gap: 1rem; flex-wrap: wrap; margin-bottom: 2rem; }
        .stat { background: var(--card-bg); border: 1px solid var(--border); border-radius: 8px; padding: 1rem 1.5rem; min-width: 120px; text-align: center; }
        .stat .number { font-size: 2rem; font-weight: 700; }
        .stat .label { font-size: 0.875rem; color: #6c757d; }
        .stat.error .number { color: var(--error); }
        .stat.warning .number { color: var(--warning); }
        .stat.info .number { color: var(--info); }
        h2 { font-size: 1.25rem; margin: 2rem 0 1rem; border-bottom: 2px solid var(--border); padding-bottom: 0.5rem; }
        table { width: 100%; border-collapse: collapse; background: var(--card-bg); border-radius: 8px; overflow: hidden; border: 1px solid var(--border); margin-bottom: 1.5rem; }
        th, td { padding: 0.625rem 1rem; text-align: left; border-bottom: 1px solid var(--border); font-size: 0.875rem; }
        th { background: #f1f3f5; font-weight: 600; }
        .badge { display: inline-block; padding: 0.125rem 0.5rem; border-radius: 4px; font-size: 0.75rem; font-weight: 600; }
        .badge-pass { background: var(--pass-bg); color: var(--pass); }
        .badge-fail { background: var(--error-bg); color: var(--error); }
        .badge-error { background: var(--error-bg); color: var(--error); }
        .badge-warning { background: var(--warning-bg); color: var(--warning); }
        .badge-info { background: var(--info-bg); color: var(--info); }
        details { background: var(--card-bg); border: 1px solid var(--border); border-radius: 8px; margin-bottom: 0.75rem; }
        summary { padding: 0.75rem 1rem; cursor: pointer; font-weight: 500; font-size: 0.875rem; }
        summary:hover { background: #f1f3f5; }
        .diag-list { padding: 0.5rem 1rem 1rem; }
        .diag { padding: 0.75rem 0; border-bottom: 1px solid #e9ecef; font-size: 0.8125rem; }
        .diag:last-child { border-bottom: none; }
        .diag-loc { color: #6c757d; font-family: monospace; }
        .diag-rule { color: #6c757d; font-style: italic; }
        .code-block { background: #1e1e2e; color: #cdd6f4; border-radius: 6px; padding: 0.625rem 0.75rem; margin: 0.5rem 0; font-family: "SF Mono", Menlo, Consolas, monospace; font-size: 0.75rem; overflow-x: auto; line-height: 1.5; white-space: pre; }
        .code-block .line-bad { color: #f38ba8; }
        .code-block .line-num { color: #6c7086; user-select: none; }
        .code-block .line-marker { color: #f38ba8; font-weight: 700; user-select: none; }
        .suggestion { background: var(--pass-bg); color: var(--pass); border-radius: 4px; padding: 0.375rem 0.625rem; margin: 0.375rem 0; font-size: 0.75rem; display: inline-block; }
        .suggestion::before { content: "Fix: "; font-weight: 600; }
        .fix-block { background: #1e3a1e; color: #a6e3a1; border-radius: 6px; padding: 0.625rem 0.75rem; margin: 0.375rem 0; font-family: "SF Mono", Menlo, Consolas, monospace; font-size: 0.75rem; overflow-x: auto; line-height: 1.5; white-space: pre; }
        </style>
        </head>
        <body>
        <h1>a11y-check Accessibility Report</h1>
        <p class="timestamp">Generated: \(escapeHTML(timestamp))</p>
        """

        // Summary
        html += """
        <div class="summary">
          <div class="stat error"><div class="number">\(errorCount)</div><div class="label">Errors</div></div>
          <div class="stat warning"><div class="number">\(warningCount)</div><div class="label">Warnings</div></div>
          <div class="stat info"><div class="number">\(infoCount)</div><div class="label">Info</div></div>
          <div class="stat"><div class="number">\(fileCount)</div><div class="label">Files</div></div>
        </div>
        """

        // WCAG Conformance Table
        html += "<h2>WCAG 2.2 Conformance</h2>\n<table>\n<tr><th>Criterion</th><th>Status</th><th>Issues</th><th>Rules</th></tr>\n"
        for criterion in allCriteria {
            let criterionDiags = flatCriterionDiags[criterion] ?? []
            let hasErrors = criterionDiags.contains { $0.severity == .error }
            let status = criterionDiags.isEmpty ? "Pass" : (hasErrors ? "Fail" : "Review")
            let badgeClass = criterionDiags.isEmpty ? "badge-pass" : (hasErrors ? "badge-fail" : "badge-warning")
            let ruleNames = allRules.filter { $0.wcagCriteria.contains(criterion) }.map(\.id).joined(separator: ", ")
            let wcagURL = "https://www.w3.org/TR/WCAG22/#" + wcagAnchor(criterion)
            html += "<tr><td><a href=\"\(wcagURL)\">\(escapeHTML(criterion))</a></td>"
            html += "<td><span class=\"badge \(badgeClass)\">\(status)</span></td>"
            html += "<td>\(criterionDiags.count)</td>"
            html += "<td>\(escapeHTML(ruleNames))</td></tr>\n"
        }
        html += "</table>\n"

        // By-file detail
        html += "<h2>Issues by File</h2>\n"
        if diagnostics.isEmpty {
            html += "<p>No accessibility issues found.</p>\n"
        } else {
            for filePath in diagsByFile.keys.sorted() {
                let fileDiags = diagsByFile[filePath]!
                let fileErrors = fileDiags.filter { $0.severity == .error }.count
                let fileWarnings = fileDiags.filter { $0.severity == .warning }.count
                let shortPath = (filePath as NSString).lastPathComponent
                html += "<details>\n<summary>\(escapeHTML(shortPath)) — \(fileDiags.count) issue\(fileDiags.count == 1 ? "" : "s")"
                if fileErrors > 0 { html += " <span class=\"badge badge-error\">\(fileErrors) error\(fileErrors == 1 ? "" : "s")</span>" }
                if fileWarnings > 0 { html += " <span class=\"badge badge-warning\">\(fileWarnings) warning\(fileWarnings == 1 ? "" : "s")</span>" }
                html += "</summary>\n<div class=\"diag-list\">\n"
                for diag in fileDiags {
                    let badgeClass: String
                    switch diag.severity {
                    case .error: badgeClass = "badge-error"
                    case .warning: badgeClass = "badge-warning"
                    case .info: badgeClass = "badge-info"
                    }
                    html += "<div class=\"diag\">"
                    html += "<span class=\"badge \(badgeClass)\">\(diag.severity.rawValue)</span> "
                    html += "<span class=\"diag-loc\">\(diag.line):\(diag.column)</span> "
                    html += "\(escapeHTML(diag.message)) "
                    html += "<span class=\"diag-rule\">\(escapeHTML(diag.ruleID))</span>"

                    if let snippet = diag.sourceSnippet {
                        html += "<div class=\"code-block\">"
                        for snippetLine in snippet.components(separatedBy: "\n") {
                            let escaped = escapeHTML(snippetLine)
                            if snippetLine.hasPrefix(">") {
                                html += "<span class=\"line-bad\">\(escaped)</span>\n"
                            } else {
                                html += "\(escaped)\n"
                            }
                        }
                        html += "</div>"
                    }

                    if let suggestion = diag.suggestion {
                        html += "<div class=\"suggestion\">\(escapeHTML(suggestion))</div>"

                        if let snippet = diag.sourceSnippet {
                            let corrected = generateCorrectedSnippet(snippet: snippet, suggestion: suggestion)
                            if let corrected = corrected {
                                html += "<div class=\"fix-block\">\(escapeHTML(corrected))</div>"
                            }
                        }
                    }

                    html += "</div>\n"
                }
                html += "</div>\n</details>\n"
            }
        }

        // By-rule summary
        html += "<h2>Issues by Rule</h2>\n<table>\n<tr><th>Rule</th><th>Severity</th><th>Count</th><th>WCAG</th></tr>\n"
        for rule in allRules.sorted(by: { $0.id < $1.id }) {
            let count = diagsByRule[rule.id]?.count ?? 0
            let badgeClass: String
            switch rule.severity {
            case .error: badgeClass = "badge-error"
            case .warning: badgeClass = "badge-warning"
            case .info: badgeClass = "badge-info"
            }
            html += "<tr><td>\(escapeHTML(rule.id))</td>"
            html += "<td><span class=\"badge \(badgeClass)\">\(rule.severity.rawValue)</span></td>"
            html += "<td>\(count)</td>"
            html += "<td>\(escapeHTML(rule.wcagCriteria.joined(separator: ", ")))</td></tr>\n"
        }
        html += "</table>\n"

        html += "</body>\n</html>"
        return html
    }

    /// Attempt to generate a corrected version of the offending line by appending
    /// the suggestion as a modifier. Returns nil if the suggestion doesn't map to
    /// a simple modifier append.
    private func generateCorrectedSnippet(snippet: String, suggestion: String) -> String? {
        // Extract the modifier from the suggestion (text after "Add " that starts with ".")
        let addPatterns = ["Add ", "Replace "]
        var modifier: String? = nil

        for pattern in addPatterns {
            if suggestion.hasPrefix(pattern) {
                let rest = String(suggestion.dropFirst(pattern.count))
                // Look for a modifier like .accessibilityLabel("...") or .disabled(true)
                if let dotIndex = rest.firstIndex(of: ".") {
                    let candidate = String(rest[dotIndex...])
                    // Take up to the end or first space after closing paren
                    if let parenClose = candidate.lastIndex(of: ")") {
                        modifier = String(candidate[...parenClose])
                    }
                }
                break
            }
        }

        guard let mod = modifier else { return nil }

        // Find the flagged line (the one starting with ">") and append the modifier
        let lines = snippet.components(separatedBy: "\n")
        var result: [String] = []
        for line in lines {
            if line.hasPrefix(">") {
                // Extract the code part after "> NNN | "
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if let pipeIndex = trimmed.firstIndex(of: "|") {
                    let codeStart = trimmed.index(after: pipeIndex)
                    let code = String(trimmed[codeStart...])
                    let stripped = code.trimmingCharacters(in: .whitespaces)
                    let indent = String(code.prefix(while: { $0 == " " || $0 == "\t" }))
                    let prefix = String(trimmed[...pipeIndex])
                    result.append("  \(prefix) \(indent)\(stripped)")
                    // Add modifier on next line with extra indent
                    result.append("  \(prefix)     \(indent)\(mod)")
                } else {
                    result.append(line)
                }
            } else {
                result.append(line)
            }
        }
        return result.joined(separator: "\n")
    }

    private func escapeHTML(_ text: String) -> String {
        text.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }

    /// Map WCAG criterion numbers to their spec anchor IDs.
    private func wcagAnchor(_ criterion: String) -> String {
        let map: [String: String] = [
            "1.1.1": "non-text-content",
            "1.3.1": "info-and-relationships",
            "1.4.3": "contrast-minimum",
            "1.4.4": "resize-text",
            "2.1.2": "no-keyboard-trap",
            "2.4.2": "page-titled",
            "2.4.3": "focus-order",
            "2.4.4": "link-purpose-in-context",
            "2.5.8": "target-size-minimum",
            "4.1.2": "name-role-value",
        ]
        return map[criterion] ?? criterion.replacingOccurrences(of: ".", with: "-")
    }
}
