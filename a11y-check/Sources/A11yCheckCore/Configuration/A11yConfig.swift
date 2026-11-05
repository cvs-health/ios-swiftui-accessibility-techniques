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
    /// Problems found in the config file itself: keys that were not recognised, and keys placed
    /// at the wrong nesting level.
    ///
    /// These are reported rather than thrown, because an unparseable key should not stop a scan.
    /// They must be *reported* though: a key the parser does not recognise is silently ignored,
    /// which makes a typo indistinguishable from a correct config. Three of the four mistakes in
    /// a config written by hand during real adoption — `heading_font_deny` at the top level
    /// instead of under `options:`, `excluded_paths` for `exclude_paths`, and two misspelled
    /// option names — would each have silently made a CI gate *stricter* than intended, with
    /// nothing on stdout to say so.
    public let configWarnings: [String]

    public struct ConfigOptions: Sendable {
        public let minTouchTarget: Double?
        public let contrastRatio: Double?
        /// Whether to assume the system background when a text view declares a foreground
        /// colour but no background exists anywhere up the view tree. Defaults to `true`.
        /// Set `false` for views drawn over images, gradients, or materials, where the
        /// assumption does not hold.
        public let assumeDefaultBackground: Bool?
        /// Extra design-system font tokens to treat as heading styles, beyond the built-in
        /// styles and the name heuristic. Match the token only, without a leading dot:
        /// `brandJumbo` for `.font(.brandJumbo)`. Case-insensitive.
        public let headingFonts: [String]
        /// Font tokens to never treat as heading styles, even when the heuristic matches.
        /// Takes precedence over `headingFonts`. Same token form.
        public let headingFontDeny: [String]
        /// Design-system wrapper name → the SwiftUI view it stands in for, e.g.
        /// `["IconView": "Image", "NavigationButton": "Button"]`.
        ///
        /// Rules only examine calls whose name is in `ViewHierarchyVisitor.recognizedViews`,
        /// which lists SwiftUI's own types. An app that wraps those types in its own components
        /// is therefore invisible to every rule — in one real codebase `IconView(` appears 437
        /// times and `NavigationButton(` 206, and no image or button rule ever looked at them.
        /// Mapping a wrapper to the view it renders lets the existing rules see it unchanged.
        public let viewAliases: [String: String]
        /// Extra modifier names that carry a font, beyond `.font()`.
        ///
        /// Design systems commonly ship their own typography modifier — `.pulseFont(.headingXL)`,
        /// `.themeFont(.display)` — and a rule that only reads `.font()` sees none of it. Name the
        /// modifier here and the font rules read it as they read `.font`. `font` is always
        /// included, so listing it is harmless.
        ///
        /// A font supplied as an **initialiser argument** is also read, using these same names as
        /// the argument label: `PSText("Title", font: .headingXXL)` is matched by `font`. That form
        /// is how a text wrapper usually takes its style, and it is invisible to a modifier-only
        /// scan.
        public let fontModifiers: [String]

        /// The modifier/argument names to search for a font, always including `font`.
        public var fontModifierNames: Set<String> {
            Set(fontModifiers).union(["font"])
        }

        public init(
            minTouchTarget: Double? = nil,
            contrastRatio: Double? = nil,
            assumeDefaultBackground: Bool? = nil,
            headingFonts: [String] = [],
            headingFontDeny: [String] = [],
            viewAliases: [String: String] = [:],
            fontModifiers: [String] = []
        ) {
            self.minTouchTarget = minTouchTarget
            self.contrastRatio = contrastRatio
            self.assumeDefaultBackground = assumeDefaultBackground
            self.headingFonts = headingFonts
            self.headingFontDeny = headingFontDeny
            self.viewAliases = viewAliases
            self.fontModifiers = fontModifiers
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
        excludePaths: [String],
        configWarnings: [String] = []
    ) {
        self.severityOverrides = severityOverrides
        self.disabledRules = disabledRules
        self.enabledOnly = enabledOnly
        self.options = options
        self.excludePaths = excludePaths
        self.configWarnings = configWarnings
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

    /// Keys recognised at the top level of `.a11ycheck.yml`.
    static let topLevelKeys: Set<String> = [
        "severity_overrides", "disabled_rules", "enabled_only", "options", "exclude_paths",
    ]

    /// Keys recognised under `options:`.
    static let optionKeys: Set<String> = [
        "min_touch_target", "contrast_ratio", "assume_default_background",
        "heading_fonts", "heading_font_deny", "view_aliases", "font_modifiers",
    ]

    /// Flags keys the parser will ignore, so a typo cannot pass for a working config.
    ///
    /// Two shapes are called out separately, because the fix differs. A key that belongs under
    /// `options:` but was written at the top level is a *nesting* mistake and the message says
    /// where to move it. Anything else is an unknown key, and gets a "did you mean" when a
    /// recognised key is within two edits of it.
    static func validate(_ dict: [String: Any]) -> [String] {
        var warnings: [String] = []

        for key in dict.keys.sorted() where !topLevelKeys.contains(key) {
            if optionKeys.contains(key) {
                warnings.append("`\(key)` is a rule option and was ignored at the top level. "
                    + "Move it under `options:`.")
            } else if let suggestion = closestKey(to: key, in: topLevelKeys) {
                warnings.append("Unknown top-level key `\(key)` was ignored. Did you mean `\(suggestion)`?")
            } else {
                warnings.append("Unknown top-level key `\(key)` was ignored. "
                    + "Valid keys: \(topLevelKeys.sorted().joined(separator: ", ")).")
            }
        }

        if let opts = dict["options"] as? [String: Any] {
            for key in opts.keys.sorted() where !optionKeys.contains(key) {
                if let suggestion = closestKey(to: key, in: optionKeys) {
                    warnings.append("Unknown option `options.\(key)` was ignored. Did you mean `\(suggestion)`?")
                } else {
                    warnings.append("Unknown option `options.\(key)` was ignored. "
                        + "Valid options: \(optionKeys.sorted().joined(separator: ", ")).")
                }
            }
        } else if dict["options"] != nil {
            warnings.append("`options:` must be a mapping of option names to values; it was ignored.")
        }

        return warnings
    }

    /// The recognised key within two edits of `key`, if exactly that is unambiguous.
    static func closestKey(to key: String, in candidates: Set<String>) -> String? {
        let scored = candidates
            .map { ($0, editDistance(key, $0)) }
            .filter { $0.1 <= 2 }
            .sorted { $0.1 < $1.1 }
        guard let best = scored.first else { return nil }
        // Two equally-close candidates is not a suggestion, it is a guess.
        if scored.count > 1, scored[1].1 == best.1 { return nil }
        return best.0
    }

    static func editDistance(_ a: String, _ b: String) -> Int {
        let a = Array(a), b = Array(b)
        if a.isEmpty { return b.count }
        if b.isEmpty { return a.count }
        var prev = Array(0...b.count)
        var cur = [Int](repeating: 0, count: b.count + 1)
        for i in 1...a.count {
            cur[0] = i
            for j in 1...b.count {
                cur[j] = min(
                    prev[j] + 1,
                    cur[j - 1] + 1,
                    prev[j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1)
                )
            }
            swap(&prev, &cur)
        }
        return prev[b.count]
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
        var assumeDefaultBackground: Bool?
        var headingFonts: [String] = []
        var headingFontDeny: [String] = []
        var viewAliases: [String: String] = [:]
        var fontModifiers: [String] = []
        if let opts = dict["options"] as? [String: Any] {
            if let v = opts["min_touch_target"] as? Double {
                minTouchTarget = v
            } else if let v = opts["min_touch_target"] as? Int {
                minTouchTarget = Double(v)
            }
            if let v = opts["contrast_ratio"] as? Double {
                contrastRatio = v
            }
            if let v = opts["assume_default_background"] as? Bool {
                assumeDefaultBackground = v
            }
            if let v = opts["heading_fonts"] as? [String] {
                headingFonts = v
            }
            if let v = opts["heading_font_deny"] as? [String] {
                headingFontDeny = v
            }
            if let v = opts["view_aliases"] as? [String: String] {
                // Only aliases pointing at a type the rules actually know are useful; a typo
                // on the right-hand side would otherwise silently do nothing.
                viewAliases = v.filter { ViewHierarchyVisitor.recognizedViews.contains($0.value) }
            }
            if let v = opts["font_modifiers"] as? [String] {
                fontModifiers = v
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
                contrastRatio: contrastRatio,
                assumeDefaultBackground: assumeDefaultBackground,
                headingFonts: headingFonts,
                headingFontDeny: headingFontDeny,
                viewAliases: viewAliases,
                fontModifiers: fontModifiers
            ),
            excludePaths: excludePaths,
            configWarnings: validate(dict)
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

    /// Whether an explicit file argument should be skipped.
    ///
    /// Directory scans already apply `exclude_paths` to enumerator-relative paths.
    /// File arguments must be matched the same way: resolve against `root`
    /// (typically the process working directory), strip a leading `./`, and
    /// also try the raw argument so CI paths like `./Modules/Foo/Bar.swift` work.
    public func shouldExclude(filePath: String, relativeTo root: String) -> Bool {
        for candidate in Self.exclusionPathCandidates(filePath: filePath, relativeTo: root) {
            if shouldExclude(relativePath: candidate) {
                return true
            }
        }
        return false
    }

    /// Path forms to try against `exclude_paths` for an explicit file argument.
    public static func exclusionPathCandidates(filePath: String, relativeTo root: String) -> [String] {
        var seen = Set<String>()
        var result: [String] = []
        func add(_ path: String) {
            guard !path.isEmpty, !seen.contains(path) else { return }
            seen.insert(path)
            result.append(path)
        }

        add(filePath)
        if filePath.hasPrefix("./") {
            add(String(filePath.dropFirst(2)))
        }

        let stdFile = (filePath as NSString).standardizingPath
        let stdRoot = (root as NSString).standardizingPath
        add(stdFile)
        if stdFile == stdRoot {
            add(".")
        } else if stdFile.hasPrefix(stdRoot + "/") {
            add(String(stdFile.dropFirst(stdRoot.count + 1)))
        }
        return result
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
