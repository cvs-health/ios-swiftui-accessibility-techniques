import Foundation

/// Generates a self-contained HTML report with WCAG conformance summary.
public struct HTMLFormatter {

    public init() {}

    public func format(_ diagnostics: [A11yDiagnostic], allRules: [any A11yRule], score: A11yScore? = nil, trendEntries: [TrendTracker.Entry] = []) -> String {
        let errorCount = diagnostics.filter { $0.severity == .error }.count
        let warningCount = diagnostics.filter { $0.severity == .warning }.count
        let infoCount = diagnostics.filter { $0.severity == .info }.count
        let fileCount = Set(diagnostics.map(\.filePath)).count
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "M/d/yy h:mm a"
        let timestamp = dateFmt.string(from: Date())

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
          --error: #b02a37; --error-bg: #f8d7da; --warning: #856404; --warning-bg: #fff3cd;
          --info: #0c5460; --info-bg: #d1ecf1; --pass: #155724; --pass-bg: #d4edda;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: var(--bg); color: var(--text); line-height: 1.6; padding: 2rem; max-width: 1200px; margin: 0 auto; }
        h1 { font-size: 1.75rem; margin-bottom: 0.5rem; }
        a { text-decoration: underline; }
        .timestamp { color: #595f64; font-size: 0.875rem; margin-bottom: 1.5rem; }
        .summary { display: flex; gap: 1rem; flex-wrap: wrap; margin-bottom: 2rem; }
        .stat { background: var(--card-bg); border: 1px solid var(--border); border-radius: 8px; padding: 1rem 1.5rem; min-width: 120px; text-align: center; }
        .stat .number { font-size: 2rem; font-weight: 700; }
        .stat .label { font-size: 0.875rem; color: #595f64; }
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
        .diag-title { font-size: 0.9375rem; font-weight: 700; margin: 0 0 0.375rem 0; color: #212529; }
        .diag:last-child { border-bottom: none; }
        .diag-loc { color: #595f64; font-family: monospace; }
        .diag-rule { color: #595f64; font-style: italic; }
        .diag-wcag { font-size: 0.75rem; font-weight: 600; color: #495057; }
        .diag-wcag a { color: #0b5ed7; }
        .badge-critical { background: #f8d7da; color: #6b1520; }
        .badge-serious { background: #ffe0b2; color: #8a4000; }
        .badge-moderate { background: #fff3cd; color: #664d03; }
        .badge-minor { background: #e2e3e5; color: #2b2f33; }
        .code-label { font-size: 0.6875rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 0.5rem; padding: 0.15rem 0.5rem; border-radius: 3px 3px 0 0; display: block; width: fit-content; }
        .bad-label { background: var(--error); color: white; }
        .good-label { background: #1a7e34; color: white; }
        .code-block { background: #1e1e2e; color: #cdd6f4; border-radius: 0 6px 6px 6px; padding: 0.625rem 0.75rem; margin: 0 0 0.375rem 0; font-family: "SF Mono", Menlo, Consolas, monospace; font-size: 0.75rem; overflow-x: auto; line-height: 1.5; white-space: pre; }
        .code-block .line-bad { color: #f38ba8; }
        .code-block .line-num { color: #6c7086; user-select: none; }
        .code-block .line-marker { color: #f38ba8; font-weight: 700; user-select: none; }
        .suggestion { background: var(--pass-bg); color: var(--pass); border-radius: 4px; padding: 0.375rem 0.625rem; margin: 0.375rem 0; font-size: 0.75rem; display: inline-block; }
        .suggestion::before { content: "Fix: "; font-weight: 600; }
        .fix-block { background: #1e3a1e; color: #a6e3a1; border-radius: 0 6px 6px 6px; padding: 0.625rem 0.75rem; margin: 0 0 0.375rem 0; font-family: "SF Mono", Menlo, Consolas, monospace; font-size: 0.75rem; overflow-x: auto; line-height: 1.5; white-space: pre; }
        .fix-block .line-good { color: #40e040; font-weight: 600; }
        .score-bar-row { display: flex; gap: 1.5rem; margin-bottom: 2rem; align-items: flex-start; }
        .score-bar-row > .score-section { flex: 0 0 auto; min-width: 320px; margin-bottom: 0; }
        .score-bar-row .bar-chart { margin-bottom: 0; }
        .score-bar-row .summary { margin-bottom: 1rem; }
        @media (max-width: 900px) { .score-bar-row { flex-direction: column; } .score-bar-row > .score-section { min-width: unset; } }
        .score-section { background: var(--card-bg); border: 1px solid var(--border); border-radius: 8px; padding: 1.5rem; margin-bottom: 2rem; }
        .score-header { display: flex; align-items: center; gap: 1.5rem; margin-bottom: 1rem; flex-wrap: wrap; }
        .score-big { font-size: 3rem; font-weight: 800; line-height: 1; }
        .score-grade { font-size: 2rem; font-weight: 700; padding: 0.25rem 0.75rem; border-radius: 8px; }
        .grade-a { background: var(--pass-bg); color: var(--pass); }
        .grade-b { background: #d4edda; color: #155724; }
        .grade-c { background: var(--warning-bg); color: var(--warning); }
        .grade-d { background: #ffe0b2; color: #8a4000; }
        .grade-f { background: var(--error-bg); color: var(--error); }
        .score-subtitle { color: #595f64; font-size: 0.875rem; }
        .score-stats { display: flex; gap: 1.5rem; flex-wrap: wrap; font-size: 0.875rem; color: #595f64; margin-bottom: 1rem; }
        .score-stats span { white-space: nowrap; }
        .failed-criteria { margin-top: 0.75rem; }
        .failed-criteria h3 { font-size: 0.9375rem; margin-bottom: 0.5rem; }
        .failed-criteria ul { list-style: none; padding: 0; }
        .failed-criteria li { padding: 0.25rem 0; font-size: 0.875rem; }
        .failed-criteria .criterion-id { font-weight: 600; }
        .failed-criteria .criterion-counts { color: #595f64; font-size: 0.75rem; }
        .criteria-table td.status-cell { text-align: center; }
        .trend-section { background: var(--card-bg); border: 1px solid var(--border); border-radius: 8px; padding: 1.5rem; margin-bottom: 2rem; }
        .trend-section h2 { margin-top: 0; border-bottom: none; padding-bottom: 0; font-size: 1.125rem; margin-bottom: 0.75rem; }
        .trend-content { display: flex; gap: 1.5rem; align-items: flex-start; }
        .trend-chart { flex: 1; min-width: 0; }
        .trend-chart svg { width: 100%; }
        .trend-chart .chart-line { fill: none; stroke: #0d6efd; stroke-width: 2.5; stroke-linecap: round; stroke-linejoin: round; }
        .trend-chart .chart-area { fill: rgba(13, 110, 253, 0.1); }
        .trend-chart .chart-dot { fill: #0d6efd; }
        .trend-chart .chart-dot-current { fill: #198754; stroke: #fff; stroke-width: 2; }
        .trend-chart .chart-grid { stroke: #e9ecef; stroke-width: 1; }
        .trend-chart .chart-label { fill: #595f64; font-size: 11px; font-family: -apple-system, sans-serif; }
        .trend-meta { flex: 0 0 auto; min-width: 200px; }
        .trend-delta { font-size: 1.125rem; font-weight: 700; margin-bottom: 0.75rem; }
        .trend-delta.positive { color: var(--pass); }
        .trend-delta.negative { color: var(--error); }
        .trend-delta.neutral { color: #595f64; }
        .trend-table { width: 100%; font-size: 0.8125rem; }
        .trend-table th { background: #f1f3f5; }
        .trend-table th, .trend-table td { padding: 0.375rem 0.625rem; }
        @media (max-width: 900px) { .trend-content { flex-direction: column; } .trend-meta { min-width: unset; } }
        .bar-chart { background: var(--card-bg); border: 1px solid var(--border); border-radius: 8px; padding: 1.5rem; margin-bottom: 2rem; }
        .bar-chart h2 { margin-top: 0; border-bottom: none; padding-bottom: 0; margin-bottom: 1rem; }
        .bar-row { display: flex; align-items: center; margin-bottom: 0.5rem; gap: 0.5rem; }
        .bar-label { min-width: 220px; font-size: 0.8125rem; text-align: right; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .bar-label a { color: var(--text); text-decoration: none; }
        .bar-label a:hover { text-decoration: underline; }
        .bar-track { flex: 1; height: 22px; background: #f1f3f5; border-radius: 4px; overflow: hidden; position: relative; }
        .bar-fill-error { height: 100%; background: var(--error); border-radius: 4px 0 0 4px; position: absolute; left: 0; top: 0; }
        .bar-fill-warning { height: 100%; position: absolute; top: 0; background: repeating-linear-gradient(135deg, #e6a817, #e6a817 4px, #d4960a 4px, #d4960a 8px); }
        .bar-fill-info { height: 100%; position: absolute; top: 0; border-radius: 0 4px 4px 0; background: #0c8599; background-image: radial-gradient(circle, rgba(255,255,255,0.35) 1.5px, transparent 1.5px); background-size: 6px 6px; }
        .bar-count { min-width: 40px; font-size: 0.8125rem; font-weight: 600; color: #595f64; }
        .bar-legend { display: flex; gap: 1.25rem; margin-bottom: 1rem; font-size: 0.75rem; color: #595f64; }
        .bar-legend-item { display: flex; align-items: center; gap: 0.375rem; }
        .bar-legend-swatch { width: 14px; height: 14px; border-radius: 2px; }
        .bar-legend-swatch.swatch-error { background: var(--error); }
        .bar-legend-swatch.swatch-warning { background: repeating-linear-gradient(135deg, #e6a817, #e6a817 3px, #d4960a 3px, #d4960a 6px); }
        .bar-legend-swatch.swatch-info { background: #0c8599; background-image: radial-gradient(circle, rgba(255,255,255,0.35) 1px, transparent 1px); background-size: 4px 4px; }
        </style>
        </head>
        <body>
        <h1>a11y-check Accessibility Report</h1>
        <p class="timestamp">Generated: \(escapeHTML(timestamp))</p>
        """

        // Score Section + Bar Chart side by side
        html += "<div class=\"score-bar-row\">\n"
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
                    var counts: [String] = []
                    if cs.warningCount > 0 { counts.append("\(cs.warningCount) warnings") }
                    if cs.infoCount > 0 { counts.append("\(cs.infoCount) info") }
                    html += "<span class=\"criterion-counts\">\(counts.joined(separator: ", "))</span></li>\n"
                }
                html += "</ul></div>\n"
            }

            html += "</div>\n"
        }

        // Right column: summary stats + bar chart
        html += "<div style=\"flex:1 1 0;min-width:0\">\n"
        html += """
        <div class="summary">
          <div class="stat error"><div class="number">\(errorCount)</div><div class="label">Errors</div></div>
          <div class="stat warning"><div class="number">\(warningCount)</div><div class="label">Warnings</div></div>
          <div class="stat info"><div class="number">\(infoCount)</div><div class="label">Info</div></div>
          <div class="stat"><div class="number">\(fileCount)</div><div class="label">Files</div></div>
        </div>
        """

        // Bar Chart — issues by WCAG criterion, sorted by total count
        do {
            let criteriaWithIssues = flatCriterionDiags
                .map { criterion, diags -> (id: String, errors: Int, warnings: Int, infos: Int, total: Int) in
                    let e = diags.filter { $0.severity == .error }.count
                    let w = diags.filter { $0.severity == .warning }.count
                    let i = diags.filter { $0.severity == .info }.count
                    return (id: criterion, errors: e, warnings: w, infos: i, total: e + w + i)
                }
                .sorted { $0.total > $1.total }

            if !criteriaWithIssues.isEmpty {
                let maxCount = criteriaWithIssues.first?.total ?? 1

                let criterionNames: [String: String] = [
                    "1.1.1": "Non-text Content", "1.3.1": "Info and Relationships",
                    "1.3.2": "Meaningful Sequence", "1.3.4": "Orientation",
                    "1.3.5": "Identify Input Purpose", "1.4.3": "Contrast (Minimum)",
                    "1.4.4": "Resize Text", "2.1.1": "Keyboard", "2.1.2": "No Keyboard Trap",
                    "2.2.1": "Timing Adjustable", "2.3.1": "Three Flashes",
                    "2.4.2": "Page Titled", "2.4.3": "Focus Order",
                    "2.4.4": "Link Purpose", "2.4.6": "Headings and Labels",
                    "2.5.1": "Pointer Gestures", "2.5.3": "Label in Name",
                    "2.5.8": "Target Size", "3.3.2": "Labels or Instructions",
                    "4.1.2": "Name, Role, Value",
                ]

                html += "<div class=\"bar-chart\">\n"
                html += "<h2>Issues by WCAG Criterion</h2>\n"
                html += "<div class=\"bar-legend\">"
                html += "<div class=\"bar-legend-item\"><div class=\"bar-legend-swatch swatch-error\"></div> Errors</div>"
                html += "<div class=\"bar-legend-item\"><div class=\"bar-legend-swatch swatch-warning\"></div> Warnings</div>"
                html += "<div class=\"bar-legend-item\"><div class=\"bar-legend-swatch swatch-info\"></div> Info</div>"
                html += "</div>\n"

                for c in criteriaWithIssues {
                    let name = criterionNames[c.id] ?? c.id
                    let wcagURL = "https://www.w3.org/WAI/WCAG22/Understanding/" + wcagAnchor(c.id)
                    let errPct = Double(c.errors) / Double(maxCount) * 100.0
                    let warnPct = Double(c.warnings) / Double(maxCount) * 100.0
                    let infoPct = Double(c.infos) / Double(maxCount) * 100.0
                    let warnLeft = errPct

                    html += "<div class=\"bar-row\">"
                    html += "<div class=\"bar-label\"><a href=\"\(wcagURL)\">\(escapeHTML(c.id)) \(escapeHTML(name))</a></div>"
                    html += "<div class=\"bar-track\">"
                    if c.errors > 0 {
                        html += "<div class=\"bar-fill-error\" style=\"width:\(String(format: "%.1f", errPct))%\"></div>"
                    }
                    if c.warnings > 0 {
                        html += "<div class=\"bar-fill-warning\" style=\"left:\(String(format: "%.1f", warnLeft))%;width:\(String(format: "%.1f", warnPct))%\"></div>"
                    }
                    if c.infos > 0 {
                        let infoLeft = warnLeft + warnPct
                        html += "<div class=\"bar-fill-info\" style=\"left:\(String(format: "%.1f", infoLeft))%;width:\(String(format: "%.1f", infoPct))%\"></div>"
                    }
                    html += "</div>"
                    html += "<div class=\"bar-count\">\(c.total)</div>"
                    html += "</div>\n"
                }
                html += "</div>\n"
            }
        }
        html += "</div>\n" // close right column wrapper
        html += "</div>\n" // close score-bar-row

        // Trend Section — SVG chart + history table
        if !trendEntries.isEmpty, let currentScore = score {
            // Build data points: historical + current
            let trendDateFmt = DateFormatter()
            trendDateFmt.dateFormat = "yyyy-MM-dd"
            let trendShortFmt = DateFormatter()
            trendShortFmt.dateFormat = "M/d/yy"
            var allPoints: [(label: String, score: Double, errors: Int, grade: String)] = trendEntries.map { entry in
                let shortDate: String
                if let parsed = trendDateFmt.date(from: String(entry.date.prefix(10))) {
                    shortDate = trendShortFmt.string(from: parsed)
                } else {
                    shortDate = String(entry.date.prefix(10))
                }
                return (label: shortDate, score: entry.score, errors: entry.errors, grade: entry.grade)
            }
            allPoints.append((label: "Now", score: currentScore.score, errors: currentScore.totalErrors, grade: currentScore.grade))

            let maxDataPoints = 20
            if allPoints.count > maxDataPoints {
                allPoints = Array(allPoints.suffix(maxDataPoints))
            }

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
            html += "<div class=\"trend-content\">\n"

            // SVG Line Chart
            let chartW = 500.0
            let chartH = 210.0
            let padL = 40.0
            let padR = 20.0
            let padT = 20.0
            let padB = 60.0
            let plotW = chartW - padL - padR
            let plotH = chartH - padT - padB

            let minScore = 0.0
            let maxScore = 100.0
            let scoreRange = 100.0

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
                html += "<text x=\"\(cx)\" y=\"\(Int(padT + plotH + 12))\" class=\"chart-label\" text-anchor=\"end\" transform=\"rotate(-45, \(cx), \(Int(padT + plotH + 12)))\">\(escapeHTML(pt.label))</text>\n"
                html += "<text x=\"\(cx)\" y=\"\(cy - 10)\" class=\"chart-label\" text-anchor=\"middle\">\(String(format: "%.0f", pt.score))</text>\n"
            }

            html += "</svg>\n</div>\n"

            // Meta: delta + history table
            html += "<div class=\"trend-meta\">\n"
            html += "<div class=\"trend-delta \(deltaClass)\">Change: \(deltaStr)</div>\n"
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
            html += "</div>\n" // close trend-meta
            html += "</div>\n" // close trend-content
            html += "</div>\n" // close trend-section
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
                    let impactBadgeClass: String
                    switch diag.impact {
                    case .critical: impactBadgeClass = "badge-critical"
                    case .serious: impactBadgeClass = "badge-serious"
                    case .moderate: impactBadgeClass = "badge-moderate"
                    case .minor: impactBadgeClass = "badge-minor"
                    }
                    let ruleName = allRules.first(where: { $0.id == diag.ruleID })?.name ?? diag.ruleID
                    html += "<div class=\"diag\">"
                    html += "<div class=\"diag-title\">\(escapeHTML(ruleName))</div>"
                    html += "<span class=\"badge \(badgeClass)\">\(diag.severity.rawValue)</span> "
                    html += "<span class=\"badge \(impactBadgeClass)\">\(diag.impact.rawValue)</span> "
                    html += "<span class=\"diag-loc\">\(diag.line):\(diag.column)</span> "
                    html += "\(escapeHTML(diag.message)) "
                    html += "<span class=\"diag-rule\">\(escapeHTML(diag.ruleID))</span>"
                    if !diag.wcagCriteria.isEmpty {
                        let wcagLinks = diag.wcagCriteria.map { c in
                            let url = "https://www.w3.org/WAI/WCAG22/Understanding/" + wcagAnchor(c)
                            return "<a href=\"\(url)\">\(escapeHTML(c))</a>"
                        }.joined(separator: ", ")
                        html += " <span class=\"diag-wcag\">WCAG \(wcagLinks)</span>"
                    }

                    if let snippet = diag.sourceSnippet {
                        html += "\n<div class=\"code-label bad-label\">Current code</div>"
                        html += "\n<div class=\"code-block\">"
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
                                html += "\n<div class=\"code-label good-label\">Fixed code</div>"
                                html += "\n<div class=\"fix-block\">"
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
        html += "<h2>Issues by Rule</h2>\n<table>\n<tr><th>Rule</th><th>Severity</th><th>Impact</th><th>Count</th><th>WCAG</th></tr>\n"
        for rule in allRules.sorted(by: { $0.id < $1.id }) {
            let count = diagsByRule[rule.id]?.count ?? 0
            let badgeClass: String
            switch rule.severity {
            case .error: badgeClass = "badge-error"
            case .warning: badgeClass = "badge-warning"
            case .info: badgeClass = "badge-info"
            }
            let impactBadge: String
            switch rule.impact {
            case .critical: impactBadge = "badge-critical"
            case .serious: impactBadge = "badge-serious"
            case .moderate: impactBadge = "badge-moderate"
            case .minor: impactBadge = "badge-minor"
            }
            html += "<tr><td>\(escapeHTML(rule.id))</td>"
            html += "<td><span class=\"badge \(badgeClass)\">\(rule.severity.rawValue)</span></td>"
            html += "<td><span class=\"badge \(impactBadge)\">\(rule.impact.rawValue)</span></td>"
            html += "<td>\(count)</td>"
            html += "<td>\(escapeHTML(rule.wcagCriteria.joined(separator: ", ")))</td></tr>\n"
        }
        html += "</table>\n"

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
                let issueText: String
                if cs.errorCount + cs.warningCount + cs.infoCount > 0 {
                    var parts: [String] = []
                    if cs.errorCount > 0 { parts.append("\(cs.errorCount)E") }
                    if cs.warningCount > 0 { parts.append("\(cs.warningCount)W") }
                    if cs.infoCount > 0 { parts.append("\(cs.infoCount)I") }
                    issueText = parts.joined(separator: " ")
                } else {
                    issueText = "—"
                }
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

        html += "</body>\n</html>"
        return html
    }

    /// Attempt to generate a corrected version of the offending snippet by
    /// inserting views above the flagged line and/or appending modifiers.
    /// Returns nil if the suggestion doesn't map to a recognisable pattern.
    private func generateCorrectedSnippet(snippet: String, suggestion: String) -> String? {
        var modifier: String? = nil
        var callAlternative: String? = nil
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
                // "Replace X with Y" — the replacement to apply is Y, not X
                let source: String
                if pattern == "Replace ", let withRange = rest.range(of: " with ") {
                    let afterWith = String(rest[withRange.upperBound...])
                    source = afterWith.components(separatedBy: " or ").first ?? afterWith
                } else {
                    source = rest
                }
                if let dotIndex = source.firstIndex(of: ".") {
                    let candidate = String(source[dotIndex...])
                    if let parenClose = candidate.lastIndex(of: ")") {
                        modifier = String(candidate[...parenClose])
                    }
                }
                // Detect a function-call alternative before "; or .modifier"
                // e.g. "Add Toggle("Label", isOn: $binding) — desc; or .accessibilityLabel("Label") ..."
                if pattern == "Add ", modifier != nil {
                    for sep in ["; or .", " or ."] {
                        if let sepRange = source.range(of: sep) {
                            let before = String(source[..<sepRange.lowerBound]).trimmingCharacters(in: .whitespaces)
                            let callPart = (before.components(separatedBy: " — ").first ?? before).trimmingCharacters(in: .whitespaces)
                            if let firstChar = callPart.first, firstChar.isUppercase, callPart.contains("("),
                               let closeIndex = callPart.lastIndex(of: ")") {
                                callAlternative = String(callPart[...closeIndex])
                            }
                            break
                        }
                    }
                }
                break
            }
        }

        // Also handle suggestions that start with "Choose ", "Use ", or "Remove " and contain a modifier
        if modifier == nil {
            for kw in ["Choose ", "Use ", "Remove "] where suggestion.hasPrefix(kw) {
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
                    var stripped = code.trimmingCharacters(in: .whitespaces)
                    var prefix = String(trimmed[...pipeIndex])
                    if prefix.hasPrefix(">") {
                        prefix = String(prefix.dropFirst())
                    }

                    // If the modifier already exists on this line, replace it in-place
                    // e.g. .frame(width:18, height:18) → .frame(width: 24, height: 24)
                    if let mod = modifier {
                        let modName = String(mod.prefix(while: { $0 != "(" }))
                        if !modName.isEmpty, stripped.contains(modName + "(") {
                            if let existingRange = stripped.range(of: #"\#(NSRegularExpression.escapedPattern(for: modName))\([^)]*\)"#, options: .regularExpression) {
                                stripped = stripped.replacingCharacters(in: existingRange, with: mod)
                                result.append(">\(prefix) \(indent)\(stripped)")
                                continue
                            }
                        }
                    }

                    // Insert a Text label on the line above if the suggestion calls for it
                    if let view = viewToInsertAbove {
                        result.append(">\(prefix) \(indent)\(view)")
                    }

                    if let call = callAlternative, let mod = modifier {
                        // Dual-option: show preferred call-replacement first, then modifier alternative
                        result.append(">\(prefix) \(indent)\(call)")
                        result.append(">\(prefix) \(indent)// — or, if the visible label is a separate Text view:")
                        result.append(">\(prefix) \(indent)\(stripped)")
                        result.append(">\(prefix)     \(indent)\(mod)")
                    } else {
                        result.append(">\(prefix) \(indent)\(stripped)")
                        // Append modifier on the line below
                        if let mod = modifier {
                            result.append(">\(prefix)     \(indent)\(mod)")
                        }
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

