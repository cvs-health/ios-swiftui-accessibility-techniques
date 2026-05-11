import Foundation

/// Stores and retrieves historical accessibility scores for trend tracking.
public struct TrendTracker {

    /// A single recorded score entry.
    public struct Entry: Codable, Sendable {
        public let date: String
        public let score: Double
        public let grade: String
        public let errors: Int
        public let warnings: Int
        public let criteriaPassed: Int
        public let criteriaFailed: Int
        public let filesAnalyzed: Int
        public let gitCommit: String?

        public init(
            date: String, score: Double, grade: String,
            errors: Int, warnings: Int,
            criteriaPassed: Int, criteriaFailed: Int,
            filesAnalyzed: Int, gitCommit: String?
        ) {
            self.date = date
            self.score = score
            self.grade = grade
            self.errors = errors
            self.warnings = warnings
            self.criteriaPassed = criteriaPassed
            self.criteriaFailed = criteriaFailed
            self.filesAnalyzed = filesAnalyzed
            self.gitCommit = gitCommit
        }
    }

    /// History file contents.
    public struct History: Codable, Sendable {
        public var entries: [Entry]

        public init(entries: [Entry] = []) {
            self.entries = entries
        }
    }

    private let filePath: String

    public init(directory: String, fileName: String = ".a11y-scores.json") {
        self.filePath = (directory as NSString).appendingPathComponent(fileName)
    }

    /// Load existing history.
    public func load() -> History {
        guard let data = FileManager.default.contents(atPath: filePath),
              let history = try? JSONDecoder().decode(History.self, from: data) else {
            return History()
        }
        return history
    }

    /// Record a new score entry.
    public func record(score: A11yScore) {
        var history = load()

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withFullTime, .withTimeZone]

        let entry = Entry(
            date: formatter.string(from: Date()),
            score: score.score,
            grade: score.grade,
            errors: score.totalErrors,
            warnings: score.totalWarnings,
            criteriaPassed: score.criteriaPassed,
            criteriaFailed: score.criteriaFailed,
            filesAnalyzed: score.filesAnalyzed,
            gitCommit: currentGitCommit()
        )
        history.entries.append(entry)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let data = try? encoder.encode(history) {
            FileManager.default.createFile(atPath: filePath, contents: data)
        }
    }

    /// Format trend output for terminal display.
    public func formatTrend(currentScore: A11yScore, lastN: Int = 10) -> String {
        let history = load()
        let reset = "\u{001B}[0m"
        let bold = "\u{001B}[1m"
        let blue = "\u{001B}[34m"
        let red = "\u{001B}[31m"

        var out = "\n\(bold)Score Trend:\(reset)\n"

        if history.entries.isEmpty {
            out += "  \(reset)No previous scores recorded. Run with --trend again to start tracking.\(reset)\n"
            return out
        }

        let recent = Array(history.entries.suffix(lastN))

        // Show delta from last entry
        if let last = recent.last {
            let delta = currentScore.score - last.score
            let deltaStr: String
            if delta > 0 {
                deltaStr = "\(blue)+\(String(format: "%.1f", delta))\(reset)"
            } else if delta < 0 {
                deltaStr = "\(red)\(String(format: "%.1f", delta))\(reset)"
            } else {
                deltaStr = "\(reset)±0.0\(reset)"
            }
            out += "  Change from last run: \(deltaStr)\n"
        }

        // Sparkline
        let allScores = recent.map(\.score) + [currentScore.score]
        out += "  \(bold)History:\(reset) \(formatSparkline(allScores))\n"

        // Table of recent entries
        out += "\n  \(reset)Date                          Score  Grade  Errors  Δ\(reset)\n"
        var prevScore: Double? = nil
        for entry in recent {
            let delta: String
            if let prev = prevScore {
                let d = entry.score - prev
                if d > 0 { delta = "\(blue)+\(String(format: "%.1f", d))\(reset)" }
                else if d < 0 { delta = "\(red)\(String(format: "%.1f", d))\(reset)" }
                else { delta = "\(reset) 0.0\(reset)" }
            } else {
                delta = "\(reset)  —\(reset)"
            }

            let gradeColor: String
            switch entry.grade.prefix(1) {
            case "A", "B": gradeColor = blue
            case "C", "D": gradeColor = bold
            default: gradeColor = red
            }

            let dateShort = String(entry.date.prefix(25))
            out += "  \(dateShort.padding(toLength: 30, withPad: " ", startingAt: 0))"
            out += "\(String(format: "%5.1f", entry.score))  "
            out += "\(gradeColor)\(entry.grade.padding(toLength: 5, withPad: " ", startingAt: 0))\(reset)  "
            out += "\(entry.errors > 0 ? red : reset)\(String(entry.errors).padding(toLength: 6, withPad: " ", startingAt: 0))\(reset)  "
            out += delta
            out += "\n"
            prevScore = entry.score
        }

        // Current run
        let currentDelta: String
        if let prev = prevScore {
            let d = currentScore.score - prev
            if d > 0 { currentDelta = "\(blue)+\(String(format: "%.1f", d))\(reset)" }
            else if d < 0 { currentDelta = "\(red)\(String(format: "%.1f", d))\(reset)" }
            else { currentDelta = "\(reset) 0.0\(reset)" }
        } else {
            currentDelta = "\(reset)  —\(reset)"
        }
        let gradeColor: String
        switch currentScore.grade.prefix(1) {
        case "A", "B": gradeColor = blue
        case "C", "D": gradeColor = bold
        default: gradeColor = red
        }
        out += "  \(bold)→ now".padding(toLength: 36, withPad: " ", startingAt: 0)
        out += "\(String(format: "%5.1f", currentScore.score))  "
        out += "\(gradeColor)\(currentScore.grade.padding(toLength: 5, withPad: " ", startingAt: 0))\(reset)  "
        out += "\(currentScore.totalErrors > 0 ? red : reset)\(String(currentScore.totalErrors).padding(toLength: 6, withPad: " ", startingAt: 0))\(reset)  "
        out += currentDelta
        out += "\(reset)\n"

        return out
    }

    /// Format trend as JSON.
    public func formatTrendJSON(currentScore: A11yScore) throws -> String {
        let history = load()
        var entries = history.entries.map { entry -> [String: Any] in
            var dict: [String: Any] = [
                "date": entry.date,
                "score": entry.score,
                "grade": entry.grade,
                "errors": entry.errors,
                "warnings": entry.warnings,
                "criteriaPassed": entry.criteriaPassed,
                "criteriaFailed": entry.criteriaFailed,
                "filesAnalyzed": entry.filesAnalyzed,
            ]
            if let commit = entry.gitCommit { dict["gitCommit"] = commit }
            return dict
        }

        let currentEntry: [String: Any] = [
            "date": "now",
            "score": currentScore.score,
            "grade": currentScore.grade,
            "errors": currentScore.totalErrors,
            "warnings": currentScore.totalWarnings,
            "criteriaPassed": currentScore.criteriaPassed,
            "criteriaFailed": currentScore.criteriaFailed,
            "filesAnalyzed": currentScore.filesAnalyzed,
        ]
        entries.append(currentEntry)

        let root: [String: Any] = [
            "trend": entries,
            "delta": history.entries.last.map { currentScore.score - $0.score } ?? 0.0,
        ]

        let data = try JSONSerialization.data(withJSONObject: root, options: [.prettyPrinted, .sortedKeys])
        return String(data: data, encoding: .utf8) ?? "{}"
    }

    private func formatSparkline(_ values: [Double]) -> String {
        let blocks = ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"]
        guard let minVal = values.min(), let maxVal = values.max() else { return "" }
        let range = maxVal - minVal
        return values.map { value in
            if range == 0 { return blocks[4] }
            let idx = Int(((value - minVal) / range) * Double(blocks.count - 1))
            return blocks[min(idx, blocks.count - 1)]
        }.joined()
    }

    private func currentGitCommit() -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["rev-parse", "--short", "HEAD"]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return nil
        }
    }
}
