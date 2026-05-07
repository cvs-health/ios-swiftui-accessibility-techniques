import Foundation

/// Applies auto-fixes from diagnostics to source files.
public struct AutoFixer {

    /// Result of applying fixes to a single file.
    public struct FileResult: Sendable {
        public let filePath: String
        public let fixesApplied: Int
        public let fixDescriptions: [String]

        public init(filePath: String, fixesApplied: Int, fixDescriptions: [String]) {
            self.filePath = filePath
            self.fixesApplied = fixesApplied
            self.fixDescriptions = fixDescriptions
        }
    }

    /// Result of an auto-fix run.
    public struct Result: Sendable {
        public let fileResults: [FileResult]
        public let totalFixesApplied: Int
        public let totalFilesModified: Int

        public init(fileResults: [FileResult], totalFixesApplied: Int, totalFilesModified: Int) {
            self.fileResults = fileResults
            self.totalFixesApplied = totalFixesApplied
            self.totalFilesModified = totalFilesModified
        }
    }

    public init() {}

    /// Apply all available fixes from diagnostics. Returns the result.
    /// Only applies fixes when `dryRun` is false.
    public func applyFixes(diagnostics: [A11yDiagnostic], dryRun: Bool = false) -> Result {
        // Group diagnostics by file
        var byFile: [String: [A11yDiagnostic]] = [:]
        for diag in diagnostics {
            guard diag.fix != nil else { continue }
            byFile[diag.filePath, default: []].append(diag)
        }

        var fileResults: [FileResult] = []

        for (filePath, diags) in byFile.sorted(by: { $0.key < $1.key }) {
            guard let sourceData = FileManager.default.contents(atPath: filePath),
                  var source = String(data: sourceData, encoding: .utf8) else {
                continue
            }

            // Sort fixes by offset descending so we apply from end to start
            // This prevents earlier fixes from invalidating later offsets
            let fixable = diags
                .compactMap { diag -> (A11yDiagnostic, A11yFix)? in
                    guard let fix = diag.fix else { return nil }
                    return (diag, fix)
                }
                .sorted { $0.1.startOffset > $1.1.startOffset }

            // Deduplicate overlapping fixes (keep the first one encountered per region)
            var appliedRanges: [Range<Int>] = []
            var fixesToApply: [(A11yDiagnostic, A11yFix)] = []

            for (diag, fix) in fixable {
                let range = fix.startOffset..<fix.endOffset
                let overlaps = appliedRanges.contains { existingRange in
                    range.overlaps(existingRange)
                }
                if !overlaps {
                    appliedRanges.append(range)
                    fixesToApply.append((diag, fix))
                }
            }

            var descriptions: [String] = []

            if !dryRun {
                let utf8 = Array(source.utf8)
                // Apply fixes from end to start
                for (_, fix) in fixesToApply {
                    guard fix.startOffset >= 0,
                          fix.endOffset <= utf8.count,
                          fix.startOffset <= fix.endOffset else { continue }

                    let startIdx = source.utf8.index(source.utf8.startIndex, offsetBy: fix.startOffset)
                    let endIdx = source.utf8.index(source.utf8.startIndex, offsetBy: fix.endOffset)
                    source.replaceSubrange(startIdx..<endIdx, with: fix.replacementText)
                    descriptions.append(fix.description)
                }

                // Write back
                try? source.write(toFile: filePath, atomically: true, encoding: .utf8)
            } else {
                descriptions = fixesToApply.map { $0.1.description }
            }

            if !fixesToApply.isEmpty {
                fileResults.append(FileResult(
                    filePath: filePath,
                    fixesApplied: fixesToApply.count,
                    fixDescriptions: descriptions
                ))
            }
        }

        let totalFixes = fileResults.reduce(0) { $0 + $1.fixesApplied }
        return Result(
            fileResults: fileResults,
            totalFixesApplied: totalFixes,
            totalFilesModified: fileResults.count
        )
    }

    /// Format fix results for terminal output.
    public func formatResult(_ result: Result, dryRun: Bool) -> String {
        let reset = "\u{001B}[0m"
        let bold = "\u{001B}[1m"
        let green = "\u{001B}[32m"

        if result.totalFixesApplied == 0 {
            return "No auto-fixes available for the reported issues.\n"
        }

        let verb = dryRun ? "would fix" : "fixed"
        var out = "\n\(green)\(bold)Auto-fix: \(verb) \(result.totalFixesApplied) \(result.totalFixesApplied == 1 ? "issue" : "issues") in \(result.totalFilesModified) \(result.totalFilesModified == 1 ? "file" : "files")\(reset)\n"

        if dryRun {
            out += "  (dry run — no files modified. Remove --dry-run to apply.)\n"
        }

        for fr in result.fileResults {
            out += "\n  \(bold)\(fr.filePath)\(reset) — \(fr.fixesApplied) \(fr.fixesApplied == 1 ? "fix" : "fixes")\n"
            for desc in fr.fixDescriptions {
                out += "    \(green)✓\(reset) \(desc)\n"
            }
        }

        return out
    }
}
