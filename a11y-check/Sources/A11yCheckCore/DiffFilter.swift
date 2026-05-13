import Foundation

/// Filters diagnostics to only lines changed in a git diff.
public enum DiffFilter {

    /// Map of absolute file path → set of changed 1-based line numbers.
    public typealias ChangedLineMap = [String: Set<Int>]

    /// Run `git diff` and parse changed lines.
    /// - `directory`: working directory to run git in
    /// - `baseBranch`: git ref to diff against; nil means unstaged working tree changes (HEAD)
    public static func changedLines(in directory: String, baseBranch: String? = nil) -> ChangedLineMap {
        var args = ["diff", "--unified=0", "--no-color"]
        if let base = baseBranch {
            args.append(base)
        }
        args.append(contentsOf: ["--", "*.swift"])

        guard let output = runGit(args: args, in: directory) else { return [:] }
        return parseUnifiedDiff(output, workingDirectory: directory)
    }

    /// Filter diagnostics to only those on changed lines.
    public static func filter(_ diagnostics: [A11yDiagnostic], changedLines: ChangedLineMap) -> [A11yDiagnostic] {
        guard !changedLines.isEmpty else { return [] }
        return diagnostics.filter { diag in
            guard let lines = changedLines[diag.filePath] else { return false }
            return lines.contains(diag.line)
        }
    }

    // MARK: - Git execution

    private static func runGit(args: [String], in directory: String) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = args
        process.currentDirectoryURL = URL(fileURLWithPath: directory)

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return nil
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Unified diff parsing

    /// Parse unified diff output to extract changed line numbers per file.
    /// Handles the `+++ b/path` and `@@ -old,count +new,count @@` format.
    static func parseUnifiedDiff(_ diff: String, workingDirectory: String) -> ChangedLineMap {
        var result: ChangedLineMap = [:]
        var currentFile: String?

        for line in diff.components(separatedBy: "\n") {
            // New file header: +++ b/Sources/MyView.swift
            if line.hasPrefix("+++ b/") {
                let relativePath = String(line.dropFirst(6))
                currentFile = (workingDirectory as NSString).appendingPathComponent(relativePath)
                if result[currentFile!] == nil {
                    result[currentFile!] = []
                }
                continue
            }

            // Hunk header: @@ -old,count +new,count @@ optional context
            if line.hasPrefix("@@"), let file = currentFile {
                if let range = parseHunkHeader(line) {
                    for lineNum in range {
                        result[file, default: []].insert(lineNum)
                    }
                }
            }
        }

        return result
    }

    /// Parse `@@ -A,B +C,D @@` and return the range of new-side line numbers C...(C+D-1).
    /// Also handles `@@ -A +C @@` (single line, no count).
    private static func parseHunkHeader(_ line: String) -> ClosedRange<Int>? {
        // Find the +N,M or +N part
        guard let plusIdx = line.range(of: "+", range: line.index(line.startIndex, offsetBy: 2)..<line.endIndex) else {
            return nil
        }

        let afterPlus = line[plusIdx.upperBound...]
        // Find end: either a comma, space, or @
        let numberPart: String
        let countPart: String

        if let commaIdx = afterPlus.firstIndex(of: ",") {
            numberPart = String(afterPlus[..<commaIdx])
            let afterComma = afterPlus[afterPlus.index(after: commaIdx)...]
            let endIdx = afterComma.firstIndex(of: " ") ?? afterComma.firstIndex(of: "@") ?? afterComma.endIndex
            countPart = String(afterComma[..<endIdx])
        } else {
            let endIdx = afterPlus.firstIndex(of: " ") ?? afterPlus.firstIndex(of: "@") ?? afterPlus.endIndex
            numberPart = String(afterPlus[..<endIdx])
            countPart = "1"
        }

        guard let start = Int(numberPart), let count = Int(countPart), count > 0 else {
            return nil
        }

        return start...(start + count - 1)
    }
}
