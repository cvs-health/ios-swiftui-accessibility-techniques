import Foundation

/// Manages a baseline file (`.a11y-baseline.json`) to suppress known accessibility issues.
/// Issues in the baseline are filtered from results so CI only flags **new** regressions.
public struct Baseline: Codable, Sendable {

    /// A fingerprint for a single diagnostic — identifies it uniquely by rule, file, and message.
    public struct Entry: Codable, Hashable, Sendable {
        public let ruleID: String
        public let filePath: String
        public let line: Int
        public let message: String

        /// Fingerprint that identifies this issue ignoring line numbers (which shift as code changes).
        public var fingerprint: String {
            "\(ruleID)|\(filePath)|\(message)"
        }
    }

    public var entries: [Entry]
    public var createdAt: String
    public var score: Double?

    public init(entries: [Entry], score: Double? = nil) {
        self.entries = entries
        self.createdAt = ISO8601DateFormatter().string(from: Date())
        self.score = score
    }

    // MARK: - File I/O

    public static let defaultFileName = ".a11y-baseline.json"

    /// Save baseline to a file.
    public func save(to directory: String) throws {
        let path = (directory as NSString).appendingPathComponent(Self.defaultFileName)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(self)
        try data.write(to: URL(fileURLWithPath: path))
    }

    /// Load baseline from a directory (searches upward like config).
    public static func load(from directory: String) -> Baseline? {
        guard let path = findFile(startingAt: directory) else { return nil }
        return load(atPath: path)
    }

    /// Load baseline from an explicit path.
    public static func load(atPath path: String) -> Baseline? {
        guard let data = FileManager.default.contents(atPath: path) else { return nil }
        return try? JSONDecoder().decode(Baseline.self, from: data)
    }

    /// Filter diagnostics against the baseline — return only **new** issues not in the baseline.
    public func filterNew(diagnostics: [A11yDiagnostic]) -> [A11yDiagnostic] {
        let baselineFingerprints = Set(entries.map { $0.fingerprint })
        return diagnostics.filter { diag in
            let fp = "\(diag.ruleID)|\(diag.filePath)|\(diag.message)"
            return !baselineFingerprints.contains(fp)
        }
    }

    /// Create a baseline from current diagnostics.
    public static func from(diagnostics: [A11yDiagnostic], score: Double? = nil) -> Baseline {
        let entries = diagnostics.map { diag in
            Entry(
                ruleID: diag.ruleID,
                filePath: diag.filePath,
                line: diag.line,
                message: diag.message
            )
        }
        return Baseline(entries: entries, score: score)
    }

    // MARK: - File discovery

    private static func findFile(startingAt directory: String) -> String? {
        var dir = (directory as NSString).standardizingPath
        let fm = FileManager.default
        while true {
            let candidate = (dir as NSString).appendingPathComponent(defaultFileName)
            if fm.fileExists(atPath: candidate) {
                return candidate
            }
            let parent = (dir as NSString).deletingLastPathComponent
            if parent == dir { break }
            dir = parent
        }
        return nil
    }
}
