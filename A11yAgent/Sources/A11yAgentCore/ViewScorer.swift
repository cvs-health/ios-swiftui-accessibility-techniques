import Foundation
import SwiftSyntax
import SwiftParser

/// Detects SwiftUI View structs in source files and scores each independently.
public struct ViewScorer {

    /// A detected SwiftUI View with its line range.
    public struct DetectedView: Sendable {
        public let name: String
        public let filePath: String
        public let startLine: Int
        public let endLine: Int

        public init(name: String, filePath: String, startLine: Int, endLine: Int) {
            self.name = name
            self.filePath = filePath
            self.startLine = startLine
            self.endLine = endLine
        }
    }

    /// Score result for a single view.
    public struct ViewScore: Sendable {
        public let view: DetectedView
        public let score: Double
        public let grade: String
        public let errorCount: Int
        public let warningCount: Int
        public let diagnostics: [A11yDiagnostic]

        public init(view: DetectedView, score: Double, grade: String, errorCount: Int, warningCount: Int, diagnostics: [A11yDiagnostic]) {
            self.view = view
            self.score = score
            self.grade = grade
            self.errorCount = errorCount
            self.warningCount = warningCount
            self.diagnostics = diagnostics
        }
    }

    public init() {}

    /// Detect all SwiftUI View structs in a source file.
    public func detectViews(sourceText: String, filePath: String) -> [DetectedView] {
        let syntax = Parser.parse(source: sourceText)
        let converter = SourceLocationConverter(fileName: filePath, tree: syntax)
        let visitor = ViewFinder(converter: converter, filePath: filePath)
        visitor.walk(syntax)
        return visitor.views
    }

    /// Detect views across multiple files given their diagnostics.
    public func detectViews(filePaths: [String]) -> [DetectedView] {
        var allViews: [DetectedView] = []
        for path in filePaths {
            guard let source = try? String(contentsOfFile: path, encoding: .utf8) else { continue }
            allViews.append(contentsOf: detectViews(sourceText: source, filePath: path))
        }
        return allViews
    }

    /// Score each detected view using the diagnostics that fall within its line range.
    public func scoreViews(views: [DetectedView], diagnostics: [A11yDiagnostic], rules: [any A11yRule]) -> [ViewScore] {
        let calculator = ScoreCalculator()

        return views.map { view in
            let viewDiags = diagnostics.filter { diag in
                diag.filePath == view.filePath &&
                diag.line >= view.startLine &&
                diag.line <= view.endLine
            }

            let score = calculator.calculate(
                diagnostics: viewDiags,
                rules: rules,
                filePaths: [view.filePath]
            )

            return ViewScore(
                view: view,
                score: score.score,
                grade: score.grade,
                errorCount: viewDiags.filter { $0.severity == .error }.count,
                warningCount: viewDiags.filter { $0.severity == .warning }.count,
                diagnostics: viewDiags
            )
        }.sorted { $0.score < $1.score } // worst scores first
    }

    /// Format per-view scores for terminal output.
    public func formatViewScores(_ viewScores: [ViewScore], relativeTo basePath: String? = nil) -> String {
        let reset = "\u{001B}[0m"
        let bold = "\u{001B}[1m"
        let green = "\u{001B}[32m"
        let magenta = "\u{001B}[35m"
        let red = "\u{001B}[31m"

        guard !viewScores.isEmpty else {
            return "\(reset)No SwiftUI views detected.\(reset)\n"
        }

        var out = "\n\(bold)Per-View Scores:\(reset)\n"

        for vs in viewScores {
            let gradeColor: String
            switch vs.grade.prefix(1) {
            case "A": gradeColor = green
            case "B": gradeColor = green
            case "C": gradeColor = magenta
            case "D": gradeColor = magenta
            default:  gradeColor = red
            }

            var displayPath = vs.view.filePath
            if let base = basePath {
                displayPath = displayPath.replacingOccurrences(of: base + "/", with: "")
            }

            let filled = Int(vs.score / 5.0)
            let empty = 20 - filled
            let bar = String(repeating: "\u{2588}", count: filled) + String(repeating: "\u{2591}", count: empty)

            out += "  \(gradeColor)[\(bar)]\(reset) "
            out += "\(gradeColor)\(bold)\(String(format: "%5.1f", vs.score))\(reset) "
            out += "\(gradeColor)(\(vs.grade))\(reset) "
            out += "\(bold)\(vs.view.name)\(reset)"
            out += "  \(reset)\(displayPath):\(vs.view.startLine)-\(vs.view.endLine)\(reset)"

            if vs.errorCount > 0 || vs.warningCount > 0 {
                var counts: [String] = []
                if vs.errorCount > 0 { counts.append("\(vs.errorCount) \(vs.errorCount == 1 ? "error" : "errors")") }
                if vs.warningCount > 0 { counts.append("\(vs.warningCount) \(vs.warningCount == 1 ? "warning" : "warnings")") }
                out += "  \(reset)(\(counts.joined(separator: ", ")))\(reset)"
            }
            out += "\n"
        }

        return out
    }
}

/// SwiftSyntax visitor that finds structs conforming to View.
private class ViewFinder: SyntaxVisitor {
    var views: [ViewScorer.DetectedView] = []
    let converter: SourceLocationConverter
    let filePath: String

    init(converter: SourceLocationConverter, filePath: String) {
        self.converter = converter
        self.filePath = filePath
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        // Check if this struct conforms to View
        if let inheritedTypes = node.inheritanceClause?.inheritedTypes {
            let conformsToView = inheritedTypes.contains { inherited in
                inherited.type.trimmedDescription == "View"
            }
            if conformsToView {
                let startLoc = converter.location(for: node.positionAfterSkippingLeadingTrivia)
                let endLoc = converter.location(for: node.endPositionBeforeTrailingTrivia)

                views.append(ViewScorer.DetectedView(
                    name: node.name.text,
                    filePath: filePath,
                    startLine: startLoc.line,
                    endLine: endLoc.line
                ))
            }
        }
        return .visitChildren
    }
}
