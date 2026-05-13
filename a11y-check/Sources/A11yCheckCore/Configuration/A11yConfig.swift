import Foundation
import Yams

/// Project-level configuration loaded from `.a11ycheck.yml`.
public struct A11yConfig: Sendable {
    /// Rule ID → overridden severity.
    public let severityOverrides: [String: A11ySeverity]
    /// Rule IDs to disable entirely.
    public let disabledRules: Set<String>
    /// If non-empty, only these rules run (allowlist mode).
    public let enabledOnly: Set<String>
    /// Rule-specific option overrides.
    public let options: ConfigOptions
    /// Glob patterns for paths to exclude from analysis.
    public let excludePaths: [String]

    public struct ConfigOptions: Sendable {
        public let minTouchTarget: Double?
        public let contrastRatio: Double?

        public init(minTouchTarget: Double? = nil, contrastRatio: Double? = nil) {
            self.minTouchTarget = minTouchTarget
            self.contrastRatio = contrastRatio
        }
    }

    public static let empty = A11yConfig(
        severityOverrides: [:],
        disabledRules: [],
        enabledOnly: [],
        options: ConfigOptions(),
        excludePaths: []
    )

    public init(
        severityOverrides: [String: A11ySeverity],
        disabledRules: Set<String>,
        enabledOnly: Set<String>,
        options: ConfigOptions,
        excludePaths: [String]
    ) {
        self.severityOverrides = severityOverrides
        self.disabledRules = disabledRules
        self.enabledOnly = enabledOnly
        self.options = options
        self.excludePaths = excludePaths
    }
}

// MARK: - Config Loader

public enum ConfigLoader {

    public static let fileName = ".a11ycheck.yml"

    /// Search upward from `directory` for `.a11ycheck.yml` and parse it.
    /// Returns `A11yConfig.empty` if no file is found.
    public static func load(from directory: String) throws -> A11yConfig {
        guard let path = findConfigFile(startingAt: directory) else {
            return .empty
        }
        let contents = try String(contentsOfFile: path, encoding: .utf8)
        return try parse(contents)
    }

    /// Load from an explicit path.
    public static func load(atPath path: String) throws -> A11yConfig {
        let contents = try String(contentsOfFile: path, encoding: .utf8)
        return try parse(contents)
    }

    /// Parse YAML string into config.
    public static func parse(_ yaml: String) throws -> A11yConfig {
        guard let dict = try Yams.load(yaml: yaml) as? [String: Any] else {
            return .empty
        }

        // severity_overrides
        var severityOverrides: [String: A11ySeverity] = [:]
        if let overrides = dict["severity_overrides"] as? [String: String] {
            for (ruleID, rawSeverity) in overrides {
                if let sev = A11ySeverity(rawValue: rawSeverity) {
                    severityOverrides[ruleID] = sev
                }
            }
        }

        // disabled_rules
        var disabledRules: Set<String> = []
        if let disabled = dict["disabled_rules"] as? [String] {
            disabledRules = Set(disabled)
        }

        // enabled_only
        var enabledOnly: Set<String> = []
        if let only = dict["enabled_only"] as? [String] {
            enabledOnly = Set(only)
        }

        // options
        var minTouchTarget: Double?
        var contrastRatio: Double?
        if let opts = dict["options"] as? [String: Any] {
            if let v = opts["min_touch_target"] as? Double {
                minTouchTarget = v
            } else if let v = opts["min_touch_target"] as? Int {
                minTouchTarget = Double(v)
            }
            if let v = opts["contrast_ratio"] as? Double {
                contrastRatio = v
            }
        }

        // exclude_paths
        var excludePaths: [String] = []
        if let paths = dict["exclude_paths"] as? [String] {
            excludePaths = paths
        }

        return A11yConfig(
            severityOverrides: severityOverrides,
            disabledRules: disabledRules,
            enabledOnly: enabledOnly,
            options: A11yConfig.ConfigOptions(
                minTouchTarget: minTouchTarget,
                contrastRatio: contrastRatio
            ),
            excludePaths: excludePaths
        )
    }

    /// Walk up the directory tree looking for `.a11ycheck.yml`.
    private static func findConfigFile(startingAt directory: String) -> String? {
        var dir = (directory as NSString).standardizingPath
        let fm = FileManager.default
        while true {
            let candidate = (dir as NSString).appendingPathComponent(fileName)
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

// MARK: - Glob matching for exclude_paths

extension A11yConfig {
    /// Returns true if `relativePath` matches any of the exclude patterns.
    public func shouldExclude(relativePath: String) -> Bool {
        for pattern in excludePaths {
            if fnmatchGlob(pattern: pattern, path: relativePath) {
                return true
            }
        }
        return false
    }
}

/// Simple glob matching supporting `*` (any segment chars) and `**` (any path segments).
/// Patterns without `/` match against any single path component (like .gitignore).
private func fnmatchGlob(pattern: String, path: String) -> Bool {
    // Patterns without slashes match against any path component
    if !pattern.contains("/") {
        let pathParts = path.split(separator: "/").map(String.init)
        return pathParts.contains { matchWildcard(pattern: pattern, string: $0) }
    }

    let patternParts = pattern.split(separator: "/", omittingEmptySubsequences: false).map(String.init)
    let pathParts = path.split(separator: "/", omittingEmptySubsequences: false).map(String.init)
    return matchParts(patternParts[...], pathParts[...])
}

private func matchParts(_ pattern: ArraySlice<String>, _ path: ArraySlice<String>) -> Bool {
    var pi = pattern.startIndex
    var pa = path.startIndex

    while pi < pattern.endIndex {
        if pattern[pi] == "**" {
            // Try matching ** against 0, 1, 2, ... path segments
            let nextPi = pattern.index(after: pi)
            for skip in 0...(path.endIndex - pa) {
                let nextPa = path.index(pa, offsetBy: skip)
                if matchParts(pattern[nextPi...], path[nextPa...]) {
                    return true
                }
            }
            return false
        }

        guard pa < path.endIndex else { return false }

        if !matchWildcard(pattern: pattern[pi], string: path[pa]) {
            return false
        }
        pi = pattern.index(after: pi)
        pa = path.index(after: pa)
    }
    return pa == path.endIndex
}

/// Match a single segment pattern with `*` wildcards against a string.
private func matchWildcard(pattern: String, string: String) -> Bool {
    if pattern == "*" { return true }

    let pChars = Array(pattern)
    let sChars = Array(string)
    var pi = 0, si = 0
    var starP = -1, starS = -1

    while si < sChars.count {
        if pi < pChars.count && (pChars[pi] == sChars[si] || pChars[pi] == "?") {
            pi += 1
            si += 1
        } else if pi < pChars.count && pChars[pi] == "*" {
            starP = pi
            starS = si
            pi += 1
        } else if starP >= 0 {
            pi = starP + 1
            starS += 1
            si = starS
        } else {
            return false
        }
    }
    while pi < pChars.count && pChars[pi] == "*" { pi += 1 }
    return pi == pChars.count
}
