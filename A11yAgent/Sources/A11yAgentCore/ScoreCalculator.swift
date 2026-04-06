import Foundation

/// Calculates WCAG 2.2 accessibility scores from diagnostics and rule metadata.
public struct ScoreCalculator {

    public init() {}

    // MARK: - WCAG 2.2 Criteria Catalog

    /// All WCAG 2.2 Level A and AA success criteria relevant to mobile/SwiftUI.
    /// Each entry: (criterion number, name, level).
    public static let wcagCatalog: [(criterion: String, name: String, level: WCAGLevel)] = [
        // Principle 1 — Perceivable
        ("1.1.1", "Non-text Content", .a),
        ("1.3.1", "Info and Relationships", .a),
        ("1.3.2", "Meaningful Sequence", .a),
        ("1.3.3", "Sensory Characteristics", .a),
        ("1.3.4", "Orientation", .aa),
        ("1.3.5", "Identify Input Purpose", .aa),
        ("1.4.1", "Use of Color", .a),
        ("1.4.2", "Audio Control", .a),
        ("1.4.3", "Contrast (Minimum)", .aa),
        ("1.4.4", "Resize Text", .aa),
        ("1.4.5", "Images of Text", .aa),
        ("1.4.10", "Reflow", .aa),
        ("1.4.11", "Non-text Contrast", .aa),
        ("1.4.12", "Text Spacing", .aa),
        ("1.4.13", "Content on Hover or Focus", .aa),
        // Principle 2 — Operable
        ("2.1.1", "Keyboard", .a),
        ("2.1.2", "No Keyboard Trap", .a),
        ("2.1.4", "Character Key Shortcuts", .a),
        ("2.2.1", "Timing Adjustable", .a),
        ("2.2.2", "Pause, Stop, Hide", .a),
        ("2.3.1", "Three Flashes or Below Threshold", .a),
        ("2.4.1", "Bypass Blocks", .a),
        ("2.4.2", "Page Titled", .a),
        ("2.4.3", "Focus Order", .a),
        ("2.4.4", "Link Purpose (In Context)", .a),
        ("2.4.5", "Multiple Ways", .aa),
        ("2.4.6", "Headings and Labels", .aa),
        ("2.4.7", "Focus Visible", .aa),
        ("2.4.11", "Focus Not Obscured (Minimum)", .aa),
        ("2.5.1", "Pointer Gestures", .a),
        ("2.5.2", "Pointer Cancellation", .a),
        ("2.5.3", "Label in Name", .a),
        ("2.5.4", "Motion Actuation", .a),
        ("2.5.7", "Dragging Movements", .aa),
        ("2.5.8", "Target Size (Minimum)", .aa),
        // Principle 3 — Understandable
        ("3.1.1", "Language of Page", .a),
        ("3.1.2", "Language of Parts", .aa),
        ("3.2.1", "On Focus", .a),
        ("3.2.2", "On Input", .a),
        ("3.2.6", "Consistent Help", .a),
        ("3.3.1", "Error Identification", .a),
        ("3.3.2", "Labels or Instructions", .a),
        ("3.3.3", "Error Suggestion", .aa),
        ("3.3.4", "Error Prevention (Legal, Financial, Data)", .aa),
        ("3.3.7", "Redundant Entry", .a),
        ("3.3.8", "Accessible Authentication (Minimum)", .aa),
        // Principle 4 — Robust
        ("4.1.2", "Name, Role, Value", .a),
        ("4.1.3", "Status Messages", .aa),
    ]

    /// Penalty weights per severity.
    private static let errorPenalty: Double = 5.0
    private static let warningPenalty: Double = 2.0
    private static let infoPenalty: Double = 0.5

    // MARK: - Public API

    /// Calculate the accessibility score for a set of diagnostics produced by the given rules.
    public func calculate(
        diagnostics: [A11yDiagnostic],
        rules: [any A11yRule],
        filePaths: [String]
    ) -> A11yScore {
        let totalErrors = diagnostics.filter { $0.severity == .error }.count
        let totalWarnings = diagnostics.filter { $0.severity == .warning }.count
        let totalInfo = diagnostics.filter { $0.severity == .info }.count

        // Build criterion → diagnostics mapping
        var diagsByCriterion: [String: [A11yDiagnostic]] = [:]
        for diag in diagnostics {
            for c in diag.wcagCriteria {
                diagsByCriterion[c, default: []].append(diag)
            }
        }

        // Build criterion → rule IDs mapping
        var rulesByCriterion: [String: [String]] = [:]
        for rule in rules {
            for c in rule.wcagCriteria {
                rulesByCriterion[c, default: []].append(rule.id)
            }
        }

        let checkedCriteria = Set(rules.flatMap(\.wcagCriteria))

        // Score each WCAG criterion
        var criteriaScores: [CriterionScore] = []
        var passCount = 0
        var failCount = 0
        var notCheckedCount = 0

        for entry in Self.wcagCatalog {
            let criterion = entry.criterion
            let isChecked = checkedCriteria.contains(criterion)
            let diags = diagsByCriterion[criterion] ?? []
            let errors = diags.filter { $0.severity == .error }.count
            let warnings = diags.filter { $0.severity == .warning }.count

            let status: CriterionStatus
            if !isChecked {
                status = .notChecked
                notCheckedCount += 1
            } else if errors > 0 {
                status = .fail
                failCount += 1
            } else if warnings > 0 {
                status = .review
                passCount += 1 // warnings count as conditional pass
            } else {
                status = .pass
                passCount += 1
            }

            criteriaScores.append(CriterionScore(
                criterion: criterion,
                name: entry.name,
                principle: WCAGPrinciple.from(criterion: criterion),
                level: entry.level,
                status: status,
                errorCount: errors,
                warningCount: warnings,
                ruleIDs: rulesByCriterion[criterion] ?? []
            ))
        }

        // Calculate principle-level scores (only among checked criteria)
        var principleScores: [WCAGPrinciple: Double] = [:]
        for principle in WCAGPrinciple.allCases {
            let critForPrinciple = criteriaScores.filter {
                $0.principle == principle && $0.status != .notChecked
            }
            if critForPrinciple.isEmpty {
                principleScores[principle] = 100.0
            } else {
                let passed = critForPrinciple.filter { $0.status == .pass || $0.status == .review }.count
                let total = critForPrinciple.count
                var base = (Double(passed) / Double(total)) * 100.0
                // Apply penalty for warnings on "review" criteria
                let reviewCriteria = critForPrinciple.filter { $0.status == .review }
                let warningPenalty = Double(reviewCriteria.reduce(0) { $0 + $1.warningCount }) * 1.0
                base = max(0, base - warningPenalty)
                principleScores[principle] = base
            }
        }

        // Calculate per-file scores
        let diagsByFile = Dictionary(grouping: diagnostics, by: \.filePath)
        var fileScores: [FileScore] = []
        for path in filePaths.sorted() {
            let fileDiags = diagsByFile[path] ?? []
            let fileErrors = fileDiags.filter { $0.severity == .error }.count
            let fileWarnings = fileDiags.filter { $0.severity == .warning }.count
            let fileInfo = fileDiags.filter { $0.severity == .info }.count
            let fileScore = Self.computeFileScore(errors: fileErrors, warnings: fileWarnings, info: fileInfo)
            fileScores.append(FileScore(
                filePath: path,
                score: fileScore,
                errorCount: fileErrors,
                warningCount: fileWarnings,
                infoCount: fileInfo
            ))
        }

        // Overall score: weighted combination of principle scores (50%) and issue-based deduction (50%)
        let principleAvg: Double
        let checkedPrinciples = principleScores.values.filter { _ in true }
        if checkedPrinciples.isEmpty {
            principleAvg = 100.0
        } else {
            principleAvg = checkedPrinciples.reduce(0, +) / Double(checkedPrinciples.count)
        }

        let issuePenalty = Double(totalErrors) * Self.errorPenalty
            + Double(totalWarnings) * Self.warningPenalty
            + Double(totalInfo) * Self.infoPenalty
        let filesCount = max(1, filePaths.count)
        // Normalize penalty per file, cap deduction at 100
        let normalizedPenalty = min(100.0, issuePenalty / Double(filesCount) * 2.0)
        let issueScore = max(0, 100.0 - normalizedPenalty)

        let overallScore = min(100.0, max(0, (principleAvg * 0.5 + issueScore * 0.5)))
        let grade = A11yScore.letterGrade(for: overallScore)

        return A11yScore(
            score: (overallScore * 10).rounded() / 10,
            grade: grade,
            criteriaScores: criteriaScores,
            principleScores: principleScores,
            fileScores: fileScores,
            totalErrors: totalErrors,
            totalWarnings: totalWarnings,
            totalInfo: totalInfo,
            filesAnalyzed: filePaths.count,
            criteriaPassed: passCount,
            criteriaFailed: failCount,
            criteriaNotChecked: notCheckedCount
        )
    }

    /// Compute a score for a single file based on issue counts.
    /// Starts at 100, deducts per issue. Clamped to 0–100.
    public static func computeFileScore(errors: Int, warnings: Int, info: Int) -> Double {
        let penalty = Double(errors) * errorPenalty
            + Double(warnings) * warningPenalty
            + Double(info) * infoPenalty
        return max(0, min(100, 100.0 - penalty))
    }
}
