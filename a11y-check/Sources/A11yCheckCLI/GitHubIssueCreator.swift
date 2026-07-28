/*
   Copyright 2026 CVS Health and/or one of its affiliates

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */

import ArgumentParser
import Foundation
import A11yCheckCore

/// Strategy for grouping diagnostics into GitHub issues.
public enum GitHubGroupBy: String, ExpressibleByArgument, CaseIterable {
    /// One issue per individual finding (default).
    case diagnostic
    /// One issue per source file, listing all findings in that file.
    case file
    /// One issue per rule ID, listing every occurrence across all files.
    case rule
}

/// Creates GitHub issues for accessibility diagnostics using the `gh` CLI.
public struct GitHubIssueCreator {

    public struct Options {
        /// GitHub repo in `owner/repo` form. Auto-detected from git remote when nil.
        public var repo: String?
        /// Assign each issue to the `copilot` user so Copilot can create a fix PR.
        public var assignCopilot: Bool
        /// Labels applied to every created issue.
        public var labels: [String]
        /// How diagnostics are grouped into issues.
        public var groupBy: GitHubGroupBy
        /// Preview without calling the GitHub API.
        public var dryRun: Bool
        /// Working directory used for git-remote detection.
        public var workingDirectory: String?

        public init(
            repo: String? = nil,
            assignCopilot: Bool = true,
            labels: [String] = ["accessibility", "a11y"],
            groupBy: GitHubGroupBy = .diagnostic,
            dryRun: Bool = false,
            workingDirectory: String? = nil
        ) {
            self.repo = repo
            self.assignCopilot = assignCopilot
            self.labels = labels
            self.groupBy = groupBy
            self.dryRun = dryRun
            self.workingDirectory = workingDirectory
        }
    }

    public struct IssueResult {
        public let created: Int
        public let skipped: Int
        public let urls: [String]
        public let errors: [String]
    }

    private struct IssueGroup {
        let diagnostics: [A11yDiagnostic]
        let groupKey: String
    }

    private struct CommandResult {
        let success: Bool
        let output: String
        let error: String
    }

    public init() {}

    // MARK: - Public API

    /// Returns true when the `gh` CLI is available on PATH.
    public func isGHAvailable() -> Bool {
        runCommand("/usr/bin/env", args: ["gh", "--version"]).success
    }

    /// Infers the GitHub `owner/repo` from the current git remote, or nil if not a GitHub remote.
    public func detectRepo(workingDirectory: String? = nil) -> String? {
        let result = runCommand("/usr/bin/env", args: ["git", "remote", "get-url", "origin"], workingDirectory: workingDirectory)
        guard result.success else { return nil }
        return parseGitHubRepo(from: result.output)
    }

    /// Creates GitHub issues for the given diagnostics and returns a summary.
    public func createIssues(for diagnostics: [A11yDiagnostic], options: Options) -> IssueResult {
        var created = 0
        var skipped = 0
        var urls: [String] = []
        var errors: [String] = []

        let repo = options.repo ?? detectRepo(workingDirectory: options.workingDirectory)
        let groups = group(diagnostics: diagnostics, by: options.groupBy)

        for group in groups {
            let (title, body) = formatIssue(group: group, groupBy: options.groupBy)

            if options.dryRun {
                print("[dry-run] Would create issue: \(title)")
                skipped += 1
                continue
            }

            var args = ["issue", "create", "--title", title, "--body", body]
            if let repo { args += ["--repo", repo] }
            if options.assignCopilot { args += ["--assignee", "copilot"] }
            if !options.labels.isEmpty { args += ["--label", options.labels.joined(separator: ",")] }

            let result = runCommand("/usr/bin/env", args: ["gh"] + args, workingDirectory: options.workingDirectory)
            if result.success {
                created += 1
                let url = result.output.trimmingCharacters(in: .whitespacesAndNewlines)
                if !url.isEmpty { urls.append(url) }
            } else {
                let msg = result.error.trimmingCharacters(in: .whitespacesAndNewlines)
                errors.append(msg.isEmpty ? "Unknown gh error" : msg)
                skipped += 1
            }
        }

        return IssueResult(created: created, skipped: skipped, urls: urls, errors: errors)
    }

    // MARK: - Grouping

    private func group(diagnostics: [A11yDiagnostic], by strategy: GitHubGroupBy) -> [IssueGroup] {
        switch strategy {
        case .diagnostic:
            return diagnostics.map {
                IssueGroup(diagnostics: [$0], groupKey: "\($0.ruleID)|\($0.filePath)|\($0.line)")
            }

        case .file:
            var byFile: [String: [A11yDiagnostic]] = [:]
            for d in diagnostics { byFile[d.filePath, default: []].append(d) }
            return byFile
                .map { IssueGroup(diagnostics: $0.value.sorted { $0.line < $1.line }, groupKey: $0.key) }
                .sorted { $0.groupKey < $1.groupKey }

        case .rule:
            var byRule: [String: [A11yDiagnostic]] = [:]
            for d in diagnostics { byRule[d.ruleID, default: []].append(d) }
            return byRule
                .map { key, value in
                    let sorted = value.sorted {
                        $0.filePath == $1.filePath ? $0.line < $1.line : $0.filePath < $1.filePath
                    }
                    return IssueGroup(diagnostics: sorted, groupKey: key)
                }
                .sorted { $0.groupKey < $1.groupKey }
        }
    }

    // MARK: - Issue formatting

    private func formatIssue(group: IssueGroup, groupBy: GitHubGroupBy) -> (title: String, body: String) {
        switch groupBy {
        case .diagnostic: return formatDiagnosticIssue(group.diagnostics[0])
        case .file:       return formatFileIssue(diagnostics: group.diagnostics, filePath: group.groupKey)
        case .rule:       return formatRuleIssue(diagnostics: group.diagnostics, ruleID: group.groupKey)
        }
    }

    private func formatDiagnosticIssue(_ d: A11yDiagnostic) -> (title: String, body: String) {
        let fileName = (d.filePath as NSString).lastPathComponent
        let title = "[\(d.ruleID)] \(d.message) — \(fileName):\(d.line)"

        var body = """
        ## Accessibility Issue

        | Field | Value |
        |-------|-------|
        | **Rule** | `\(d.ruleID)` |
        | **Severity** | \(d.severity.rawValue) |
        | **Impact** | \(d.impact.rawValue) |
        | **WCAG** | \(d.wcagCriteria.joined(separator: ", ")) |
        | **File** | `\(d.filePath)` |
        | **Location** | Line \(d.line), Column \(d.column) |

        **\(d.message)**
        """

        if let suggestion = d.suggestion {
            body += "\n\n### Suggested Fix\n\n\(suggestion)"
        }
        if let snippet = d.sourceSnippet {
            body += "\n\n### Source\n\n```swift\n\(snippet)\n```"
        }
        body += copilotHint() + footer()
        return (title, body)
    }

    private func formatFileIssue(diagnostics: [A11yDiagnostic], filePath: String) -> (title: String, body: String) {
        let fileName = (filePath as NSString).lastPathComponent
        let n = diagnostics.count
        let errors = diagnostics.filter { $0.severity == .error }.count
        let warnings = diagnostics.filter { $0.severity == .warning }.count
        let title = "Accessibility issues in \(fileName) (\(n) issue\(n == 1 ? "" : "s"))"

        var body = """
        ## Accessibility Issues in `\(fileName)`

        **File:** `\(filePath)`
        **Issues:** \(n) total (\(errors) error\(errors == 1 ? "" : "s"), \(warnings) warning\(warnings == 1 ? "" : "s"))

        """

        for d in diagnostics {
            body += "### Line \(d.line): `\(d.ruleID)`\n\n"
            body += "- **Severity:** \(d.severity.rawValue) · **Impact:** \(d.impact.rawValue)\n"
            body += "- **WCAG:** \(d.wcagCriteria.joined(separator: ", "))\n"
            body += "- \(d.message)\n"
            if let suggestion = d.suggestion { body += "- **Fix:** \(suggestion)\n" }
            if let snippet = d.sourceSnippet { body += "\n```swift\n\(snippet)\n```\n" }
            body += "\n"
        }

        body += copilotHint() + footer()
        return (title, body)
    }

    private func formatRuleIssue(diagnostics: [A11yDiagnostic], ruleID: String) -> (title: String, body: String) {
        let first = diagnostics[0]
        let n = diagnostics.count
        let title = "[\(ruleID)] \(n) instance\(n == 1 ? "" : "s") — \(first.message)"

        var body = """
        ## Accessibility Rule Violation: `\(ruleID)`

        **\(first.message)**

        | Field | Value |
        |-------|-------|
        | **Severity** | \(first.severity.rawValue) |
        | **Impact** | \(first.impact.rawValue) |
        | **WCAG** | \(first.wcagCriteria.joined(separator: ", ")) |
        | **Occurrences** | \(n) |

        """

        if let suggestion = first.suggestion {
            body += "### Suggested Fix\n\n\(suggestion)\n\n"
        }

        body += "### Affected Locations\n\n"
        for d in diagnostics {
            let fileName = (d.filePath as NSString).lastPathComponent
            body += "- `\(fileName)` line \(d.line), col \(d.column)\n"
            if let snippet = d.sourceSnippet {
                body += "  ```swift\n  \(snippet.split(separator: "\n").joined(separator: "\n  "))\n  ```\n"
            }
        }

        body += copilotHint() + footer()
        return (title, body)
    }

    private func copilotHint() -> String {
        """


        ### For Copilot

        Fix the accessibility issue described above. Refer to the WCAG success criteria \
        linked in the table and the suggested fix (if provided). \
        Ensure the change does not break existing functionality.
        """
    }

    private func footer() -> String {
        "\n\n---\n*Created by [a11y-check](https://github.com/cvs-health/ios-swiftui-accessibility-techniques/tree/main/a11y-check)*"
    }

    // MARK: - Helpers

    private func parseGitHubRepo(from remoteURL: String) -> String? {
        var url = remoteURL.trimmingCharacters(in: .whitespacesAndNewlines)
        // git@github.com:owner/repo.git  →  owner/repo
        // https://github.com/owner/repo.git  →  owner/repo
        if let range = url.range(of: "github.com:") {
            url = String(url[range.upperBound...])
        } else if let range = url.range(of: "github.com/") {
            url = String(url[range.upperBound...])
        } else {
            return nil
        }
        url = url.replacingOccurrences(of: ".git", with: "")
        let parts = url.split(separator: "/")
        guard parts.count >= 2 else { return nil }
        return "\(parts[0])/\(parts[1])"
    }

    private func runCommand(_ executable: String, args: [String], workingDirectory: String? = nil) -> CommandResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = args
        if let wd = workingDirectory {
            process.currentDirectoryURL = URL(fileURLWithPath: wd)
        }

        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe

        do {
            try process.run()
            process.waitUntilExit()
            let out = String(data: outPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            let err = String(data: errPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            return CommandResult(success: process.terminationStatus == 0, output: out, error: err)
        } catch {
            return CommandResult(success: false, output: "", error: error.localizedDescription)
        }
    }
}
