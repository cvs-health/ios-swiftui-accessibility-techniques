import Foundation

/// Generates a self-contained HTML report with WCAG conformance summary.
public struct HTMLFormatter {

    public init() {}

    public func format(_ diagnostics: [A11yDiagnostic], allRules: [any A11yRule], score: A11yScore? = nil, trendEntries: [TrendTracker.Entry] = []) -> String {
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
        .fix-block .line-good { color: #40e040; font-weight: 600; }
        .score-section { background: var(--card-bg); border: 1px solid var(--border); border-radius: 8px; padding: 1.5rem; margin-bottom: 2rem; }
        .score-header { display: flex; align-items: center; gap: 1.5rem; margin-bottom: 1rem; flex-wrap: wrap; }
        .score-big { font-size: 3rem; font-weight: 800; line-height: 1; }
        .score-grade { font-size: 2rem; font-weight: 700; padding: 0.25rem 0.75rem; border-radius: 8px; }
        .grade-a { background: var(--pass-bg); color: var(--pass); }
        .grade-b { background: #d4edda; color: #155724; }
        .grade-c { background: var(--warning-bg); color: var(--warning); }
        .grade-d { background: #ffe0b2; color: #e65100; }
        .grade-f { background: var(--error-bg); color: var(--error); }
        .score-subtitle { color: #6c757d; font-size: 0.875rem; }
        .score-stats { display: flex; gap: 1.5rem; flex-wrap: wrap; font-size: 0.875rem; color: #6c757d; margin-bottom: 1rem; }
        .score-stats span { white-space: nowrap; }
        .failed-criteria { margin-top: 0.75rem; }
        .failed-criteria h3 { font-size: 0.9375rem; margin-bottom: 0.5rem; }
        .failed-criteria ul { list-style: none; padding: 0; }
        .failed-criteria li { padding: 0.25rem 0; font-size: 0.875rem; }
        .failed-criteria .criterion-id { font-weight: 600; }
        .failed-criteria .criterion-counts { color: #6c757d; font-size: 0.75rem; }
        .criteria-table td.status-cell { text-align: center; }
        .trend-section { background: var(--card-bg); border: 1px solid var(--border); border-radius: 8px; padding: 1.5rem; margin-bottom: 2rem; }
        .trend-section h2 { margin-top: 0; border-bottom: none; padding-bottom: 0; }
        .trend-chart { margin: 1rem 0; }
        .trend-chart svg { width: 100%; max-width: 700px; }
        .trend-chart .chart-line { fill: none; stroke: #0d6efd; stroke-width: 2.5; stroke-linecap: round; stroke-linejoin: round; }
        .trend-chart .chart-area { fill: rgba(13, 110, 253, 0.1); }
        .trend-chart .chart-dot { fill: #0d6efd; }
        .trend-chart .chart-dot-current { fill: #198754; stroke: #fff; stroke-width: 2; }
        .trend-chart .chart-grid { stroke: #e9ecef; stroke-width: 1; }
        .trend-chart .chart-label { fill: #6c757d; font-size: 11px; font-family: -apple-system, sans-serif; }
        .trend-delta { font-size: 1.25rem; font-weight: 700; margin-bottom: 0.5rem; }
        .trend-delta.positive { color: var(--pass); }
        .trend-delta.negative { color: var(--error); }
        .trend-delta.neutral { color: #6c757d; }
        .trend-table { width: 100%; max-width: 700px; }
        .trend-table th { background: #f1f3f5; }
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

        // Score Section
        if let score = score {
            let gradeClass: String
            switch score.grade.prefix(1) {
            case "A": gradeClass = "grade-a"
            case "B": gradeClass = "grade-b"
            case "C": gradeClass = "grade-c"
            case "D": gradeClass = "grade-d"
            default:  gradeClass = "grade-f"
            }

            html += """
            <div class="score-section">
              <div class="score-header">
                <div class="score-big">\(String(format: "%.1f", score.score))</div>
                <div>
                  <div class="score-grade \(gradeClass)">\(escapeHTML(score.grade))</div>
                  <div class="score-subtitle">WCAG 2.2 Accessibility Score</div>
                </div>
              </div>
              <div class="score-stats">
                <span>\(score.criteriaPassed) criteria passed</span>
                <span>\(score.criteriaFailed) failed</span>
                <span>\(score.fileScores.count) files analyzed</span>
              </div>
            """

            let failed = score.criteriaScores.filter { $0.status == .fail }
            if !failed.isEmpty {
                html += "<div class=\"failed-criteria\"><h3><span class=\"badge badge-fail\">Failed WCAG Criteria</span></h3><ul>\n"
                for cs in failed {
                    let wcagURL = "https://www.w3.org/WAI/WCAG22/Understanding/" + wcagAnchor(cs.criterion)
                    html += "<li><span class=\"badge badge-fail\">\u{2717}</span> "
                    html += "<a href=\"\(wcagURL)\"><span class=\"criterion-id\">\(escapeHTML(cs.criterion))</span></a> "
                    html += "\(escapeHTML(cs.name)) "
                    html += "<span class=\"criterion-counts\">\(cs.errorCount) errors, \(cs.warningCount) warnings</span></li>\n"
                }
                html += "</ul></div>\n"
            }

            let review = score.criteriaScores.filter { $0.status == .review }
            if !review.isEmpty {
                html += "<div class=\"failed-criteria\"><h3><span class=\"badge badge-warning\">Needs Review</span></h3><ul>\n"
                for cs in review {
                    let wcagURL = "https://www.w3.org/WAI/WCAG22/Understanding/" + wcagAnchor(cs.criterion)
                    html += "<li><span class=\"badge badge-warning\">\u{26a0}</span> "
                    html += "<a href=\"\(wcagURL)\"><span class=\"criterion-id\">\(escapeHTML(cs.criterion))</span></a> "
                    html += "\(escapeHTML(cs.name)) "
                    html += "<span class=\"criterion-counts\">\(cs.warningCount) warnings</span></li>\n"
                }
                html += "</ul></div>\n"
            }

            html += "</div>\n"
        }

        // Trend Section — SVG chart + history table
        if !trendEntries.isEmpty, let currentScore = score {
            // Build data points: historical + current
            var allPoints: [(label: String, score: Double, errors: Int, grade: String)] = trendEntries.map { entry in
                let shortDate = String(entry.date.prefix(10))
                return (label: shortDate, score: entry.score, errors: entry.errors, grade: entry.grade)
            }
            allPoints.append((label: "Now", score: currentScore.score, errors: currentScore.totalErrors, grade: currentScore.grade))

            // Delta
            let delta = currentScore.score - trendEntries.last!.score
            let deltaClass: String
            let deltaStr: String
            if delta > 0 {
                deltaClass = "positive"
                deltaStr = "+\(String(format: "%.1f", delta))"
            } else if delta < 0 {
                deltaClass = "negative"
                deltaStr = String(format: "%.1f", delta)
            } else {
                deltaClass = "neutral"
                deltaStr = "±0.0"
            }

            html += "<div class=\"trend-section\">\n"
            html += "<h2>Score Trend</h2>\n"
            html += "<div class=\"trend-delta \(deltaClass)\">Change from last run: \(deltaStr)</div>\n"

            // SVG Line Chart
            let chartW = 680.0
            let chartH = 200.0
            let padL = 40.0
            let padR = 20.0
            let padT = 20.0
            let padB = 40.0
            let plotW = chartW - padL - padR
            let plotH = chartH - padT - padB

            let scores = allPoints.map(\.score)
            let minScore = max(0, (scores.min() ?? 0) - 10)
            let maxScore = min(100, (scores.max() ?? 100) + 10)
            let scoreRange = max(maxScore - minScore, 1)

            func xPos(_ i: Int) -> Double {
                let count = allPoints.count
                if count <= 1 { return padL + plotW / 2 }
                return padL + (Double(i) / Double(count - 1)) * plotW
            }
            func yPos(_ val: Double) -> Double {
                return padT + plotH - ((val - minScore) / scoreRange) * plotH
            }

            html += "<div class=\"trend-chart\">\n"
            html += "<svg viewBox=\"0 0 \(Int(chartW)) \(Int(chartH))\" xmlns=\"http://www.w3.org/2000/svg\">\n"

            // Grid lines
            let gridSteps = [0.0, 25.0, 50.0, 75.0, 100.0].filter { $0 >= minScore && $0 <= maxScore }
            for step in gridSteps {
                let y = yPos(step)
                html += "<line x1=\"\(Int(padL))\" y1=\"\(Int(y))\" x2=\"\(Int(chartW - padR))\" y2=\"\(Int(y))\" class=\"chart-grid\"/>\n"
                html += "<text x=\"\(Int(padL - 5))\" y=\"\(Int(y + 4))\" class=\"chart-label\" text-anchor=\"end\">\(Int(step))</text>\n"
            }

            // Area fill
            var areaPath = "M \(Int(xPos(0))) \(Int(yPos(allPoints[0].score)))"
            for i in 1..<allPoints.count {
                areaPath += " L \(Int(xPos(i))) \(Int(yPos(allPoints[i].score)))"
            }
            areaPath += " L \(Int(xPos(allPoints.count - 1))) \(Int(padT + plotH))"
            areaPath += " L \(Int(xPos(0))) \(Int(padT + plotH)) Z"
            html += "<path d=\"\(areaPath)\" class=\"chart-area\"/>\n"

            // Line
            var linePath = "M \(Int(xPos(0))) \(Int(yPos(allPoints[0].score)))"
            for i in 1..<allPoints.count {
                linePath += " L \(Int(xPos(i))) \(Int(yPos(allPoints[i].score)))"
            }
            html += "<path d=\"\(linePath)\" class=\"chart-line\"/>\n"

            // Dots + labels
            for (i, pt) in allPoints.enumerated() {
                let cx = Int(xPos(i))
                let cy = Int(yPos(pt.score))
                let dotClass = i == allPoints.count - 1 ? "chart-dot-current" : "chart-dot"
                let r = i == allPoints.count - 1 ? 5 : 4
                html += "<circle cx=\"\(cx)\" cy=\"\(cy)\" r=\"\(r)\" class=\"\(dotClass)\"/>\n"
                html += "<text x=\"\(cx)\" y=\"\(Int(padT + plotH + 20))\" class=\"chart-label\" text-anchor=\"middle\">\(escapeHTML(pt.label))</text>\n"
                html += "<text x=\"\(cx)\" y=\"\(cy - 10)\" class=\"chart-label\" text-anchor=\"middle\">\(String(format: "%.0f", pt.score))</text>\n"
            }

            html += "</svg>\n</div>\n"

            // History table
            html += "<table class=\"trend-table\">\n"
            html += "<tr><th>Date</th><th>Score</th><th>Grade</th><th>Errors</th><th>Change</th></tr>\n"
            var prevScore: Double? = nil
            for pt in allPoints {
                let changeStr: String
                if let prev = prevScore {
                    let d = pt.score - prev
                    if d > 0 { changeStr = "<span style=\"color:var(--pass)\">+\(String(format: "%.1f", d))</span>" }
                    else if d < 0 { changeStr = "<span style=\"color:var(--error)\">\(String(format: "%.1f", d))</span>" }
                    else { changeStr = "±0.0" }
                } else {
                    changeStr = "—"
                }
                let isCurrent = pt.label == "Now"
                let rowStyle = isCurrent ? " style=\"font-weight:700\"" : ""
                html += "<tr\(rowStyle)><td>\(escapeHTML(pt.label))</td><td>\(String(format: "%.1f", pt.score))</td><td>\(escapeHTML(pt.grade))</td><td>\(pt.errors)</td><td>\(changeStr)</td></tr>\n"
                prevScore = pt.score
            }
            html += "</table>\n"
            html += "</div>\n"
        }

        // WCAG Conformance Table — use score data if available for full 48-criteria view
        html += "<h2>WCAG 2.2 Conformance</h2>\n"
        if let score = score {
            html += "<table class=\"criteria-table\">\n<tr><th>Criterion</th><th>Name</th><th>Level</th><th>Status</th><th>Issues</th></tr>\n"
            for cs in score.criteriaScores {
                let statusIcon: String
                let badgeClass: String
                switch cs.status {
                case .pass:       statusIcon = "✓ Pass";   badgeClass = "badge-pass"
                case .fail:       statusIcon = "✗ Fail";   badgeClass = "badge-fail"
                case .review:     statusIcon = "⚠ Review"; badgeClass = "badge-warning"
                case .notChecked: statusIcon = "· N/A";    badgeClass = "badge-info"
                }
                let issueText = (cs.errorCount + cs.warningCount) > 0 ? "\(cs.errorCount)E \(cs.warningCount)W" : "—"
                let wcagURL = "https://www.w3.org/WAI/WCAG22/Understanding/" + wcagAnchor(cs.criterion)
                html += "<tr><td><a href=\"\(wcagURL)\">\(escapeHTML(cs.criterion))</a></td>"
                html += "<td>\(escapeHTML(cs.name))</td>"
                html += "<td>\(cs.level.rawValue)</td>"
                html += "<td class=\"status-cell\"><span class=\"badge \(badgeClass)\">\(statusIcon)</span></td>"
                html += "<td>\(issueText)</td></tr>\n"
            }
            html += "</table>\n"
        } else {
            html += "<table>\n<tr><th>Criterion</th><th>Status</th><th>Issues</th><th>Rules</th></tr>\n"
            for criterion in allCriteria {
                let criterionDiags = flatCriterionDiags[criterion] ?? []
                let hasErrors = criterionDiags.contains { $0.severity == .error }
                let status = criterionDiags.isEmpty ? "Pass" : (hasErrors ? "Fail" : "Review")
                let badgeClass = criterionDiags.isEmpty ? "badge-pass" : (hasErrors ? "badge-fail" : "badge-warning")
                let ruleNames = allRules.filter { $0.wcagCriteria.contains(criterion) }.map(\.id).joined(separator: ", ")
                let wcagURL = "https://www.w3.org/WAI/WCAG22/Understanding/" + wcagAnchor(criterion)
                html += "<tr><td><a href=\"\(wcagURL)\">\(escapeHTML(criterion))</a></td>"
                html += "<td><span class=\"badge \(badgeClass)\">\(status)</span></td>"
                html += "<td>\(criterionDiags.count)</td>"
                html += "<td>\(escapeHTML(ruleNames))</td></tr>\n"
            }
            html += "</table>\n"
        }

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
                                html += "<div class=\"fix-block\">"
                                for fixLine in corrected.components(separatedBy: "\n") {
                                    let escaped = escapeHTML(fixLine)
                                    if fixLine.hasPrefix(">") {
                                        html += "<span class=\"line-good\">\(escaped)</span>\n"
                                    } else {
                                        html += "\(escaped)\n"
                                    }
                                }
                                html += "</div>"
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

    /// Attempt to generate a corrected version of the offending snippet by
    /// inserting views above the flagged line and/or appending modifiers.
    /// Returns nil if the suggestion doesn't map to a recognisable pattern.
    private func generateCorrectedSnippet(snippet: String, suggestion: String) -> String? {
        var modifier: String? = nil
        var viewToInsertAbove: String? = nil

        // Look for a Text("...") view to add above the field
        // Pattern: "Add a visible Text(\"Label\") label above..."
        //      or: "Add a Text label above..."
        if let textRange = suggestion.range(of: #"Text\("[^"]*"\)"#, options: .regularExpression) {
            viewToInsertAbove = String(suggestion[textRange])
        }

        // Look for a modifier like .accessibilityLabel("...") to append
        let addPatterns = ["Add ", "Replace "]
        for pattern in addPatterns {
            if suggestion.hasPrefix(pattern) {
                let rest = String(suggestion.dropFirst(pattern.count))
                if let dotIndex = rest.firstIndex(of: ".") {
                    let candidate = String(rest[dotIndex...])
                    if let parenClose = candidate.lastIndex(of: ")") {
                        modifier = String(candidate[...parenClose])
                    }
                }
                break
            }
        }

        // Also handle suggestions that start with "Choose " or "Use " and contain a modifier
        if modifier == nil {
            for kw in ["Choose ", "Use "] where suggestion.hasPrefix(kw) {
                let rest = String(suggestion.dropFirst(kw.count))
                if let dotIndex = rest.firstIndex(of: ".") {
                    let candidate = String(rest[dotIndex...])
                    if let parenClose = candidate.lastIndex(of: ")") {
                        modifier = String(candidate[...parenClose])
                    }
                }
            }
        }

        guard modifier != nil || viewToInsertAbove != nil else { return nil }

        let lines = snippet.components(separatedBy: "\n")
        var result: [String] = []
        for line in lines {
            if line.hasPrefix(">") {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if let pipeIndex = trimmed.firstIndex(of: "|") {
                    let codeStart = trimmed.index(after: pipeIndex)
                    let code = String(trimmed[codeStart...])
                    let indent = String(code.prefix(while: { $0 == " " || $0 == "\t" }))
                    let stripped = code.trimmingCharacters(in: .whitespaces)
                    let prefix = String(trimmed[...pipeIndex])

                    // Insert a Text label on the line above if the suggestion calls for it
                    if let view = viewToInsertAbove {
                        result.append("> \(prefix) \(indent)\(view)")
                    }

                    result.append("> \(prefix) \(indent)\(stripped)")

                    // Append modifier on the line below
                    if let mod = modifier {
                        result.append("> \(prefix)     \(indent)\(mod)")
                    }
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

    /// Map WCAG criterion numbers to their Understanding page slugs.
    private func wcagAnchor(_ criterion: String) -> String {
        let map: [String: String] = [
            "1.1.1": "non-text-content",
            "1.2.1": "audio-only-and-video-only-prerecorded",
            "1.2.2": "captions-prerecorded",
            "1.2.3": "audio-description-or-media-alternative-prerecorded",
            "1.2.4": "captions-live",
            "1.2.5": "audio-description-prerecorded",
            "1.3.1": "info-and-relationships",
            "1.3.2": "meaningful-sequence",
            "1.3.3": "sensory-characteristics",
            "1.3.4": "orientation",
            "1.3.5": "identify-input-purpose",
            "1.4.1": "use-of-color",
            "1.4.2": "audio-control",
            "1.4.3": "contrast-minimum",
            "1.4.4": "resize-text",
            "1.4.5": "images-of-text",
            "1.4.10": "reflow",
            "1.4.11": "non-text-contrast",
            "1.4.12": "text-spacing",
            "1.4.13": "content-on-hover-or-focus",
            "2.1.1": "keyboard",
            "2.1.2": "no-keyboard-trap",
            "2.1.4": "character-key-shortcuts",
            "2.2.1": "timing-adjustable",
            "2.2.2": "pause-stop-hide",
            "2.3.1": "three-flashes-or-below-threshold",
            "2.4.1": "bypass-blocks",
            "2.4.2": "page-titled",
            "2.4.3": "focus-order",
            "2.4.4": "link-purpose-in-context",
            "2.4.5": "multiple-ways",
            "2.4.6": "headings-and-labels",
            "2.4.7": "focus-visible",
            "2.4.11": "focus-not-obscured-minimum",
            "2.5.1": "pointer-gestures",
            "2.5.2": "pointer-cancellation",
            "2.5.3": "label-in-name",
            "2.5.4": "motion-actuation",
            "2.5.7": "dragging-movements",
            "2.5.8": "target-size-minimum",
            "3.1.1": "language-of-page",
            "3.1.2": "language-of-parts",
            "3.2.1": "on-focus",
            "3.2.2": "on-input",
            "3.2.6": "consistent-help",
            "3.3.1": "error-identification",
            "3.3.2": "labels-or-instructions",
            "3.3.3": "error-suggestion",
            "3.3.4": "error-prevention-legal-financial-data",
            "3.3.7": "redundant-entry",
            "3.3.8": "accessible-authentication-minimum",
            "4.1.2": "name-role-value",
            "4.1.3": "status-messages",
        ]
        return map[criterion] ?? criterion.replacingOccurrences(of: ".", with: "-")
    }
}
