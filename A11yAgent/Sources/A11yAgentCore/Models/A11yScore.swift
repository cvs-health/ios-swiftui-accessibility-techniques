import Foundation

/// WCAG 2.2 conformance level.
public enum WCAGLevel: String, Codable, Sendable {
    case a = "A"
    case aa = "AA"
    case aaa = "AAA"
}

/// WCAG 2.2 principle grouping.
public enum WCAGPrinciple: String, Codable, Sendable, CaseIterable {
    case perceivable = "Perceivable"
    case operable = "Operable"
    case understandable = "Understandable"
    case robust = "Robust"

    /// Map a WCAG criterion number (e.g. "1.4.3") to its principle.
    public static func from(criterion: String) -> WCAGPrinciple {
        guard let first = criterion.first else { return .perceivable }
        switch first {
        case "1": return .perceivable
        case "2": return .operable
        case "3": return .understandable
        case "4": return .robust
        default:  return .perceivable
        }
    }
}

/// Status for a single WCAG criterion check.
public enum CriterionStatus: String, Codable, Sendable {
    case pass
    case fail
    case review
    case notChecked = "not_checked"
}

/// Score result for a single WCAG criterion.
public struct CriterionScore: Sendable {
    /// WCAG criterion number, e.g. "1.1.1".
    public let criterion: String
    /// Human-readable name.
    public let name: String
    /// WCAG principle.
    public let principle: WCAGPrinciple
    /// Conformance level.
    public let level: WCAGLevel
    /// Status based on diagnostics.
    public let status: CriterionStatus
    /// Number of errors found for this criterion.
    public let errorCount: Int
    /// Number of warnings found for this criterion.
    public let warningCount: Int
    /// Rule IDs that checked this criterion.
    public let ruleIDs: [String]

    public init(
        criterion: String,
        name: String,
        principle: WCAGPrinciple,
        level: WCAGLevel,
        status: CriterionStatus,
        errorCount: Int,
        warningCount: Int,
        ruleIDs: [String]
    ) {
        self.criterion = criterion
        self.name = name
        self.principle = principle
        self.level = level
        self.status = status
        self.errorCount = errorCount
        self.warningCount = warningCount
        self.ruleIDs = ruleIDs
    }
}

/// Per-file accessibility score.
public struct FileScore: Sendable {
    /// Path to the file.
    public let filePath: String
    /// Overall score 0–100.
    public let score: Double
    /// Number of errors in this file.
    public let errorCount: Int
    /// Number of warnings in this file.
    public let warningCount: Int
    /// Number of info diagnostics in this file.
    public let infoCount: Int

    public init(filePath: String, score: Double, errorCount: Int, warningCount: Int, infoCount: Int) {
        self.filePath = filePath
        self.score = score
        self.errorCount = errorCount
        self.warningCount = warningCount
        self.infoCount = infoCount
    }
}

/// Aggregate accessibility score for one or more files.
public struct A11yScore: Sendable {
    /// Overall score from 0 (worst) to 100 (best).
    public let score: Double
    /// Letter grade (A+ through F).
    public let grade: String
    /// Per-WCAG-criterion breakdown.
    public let criteriaScores: [CriterionScore]
    /// Per-principle scores (0–100).
    public let principleScores: [WCAGPrinciple: Double]
    /// Per-file scores.
    public let fileScores: [FileScore]
    /// Total diagnostics counted.
    public let totalErrors: Int
    public let totalWarnings: Int
    public let totalInfo: Int
    /// Total files analyzed.
    public let filesAnalyzed: Int
    /// Number of WCAG criteria that passed.
    public let criteriaPassed: Int
    /// Number of WCAG criteria that failed.
    public let criteriaFailed: Int
    /// Number of WCAG criteria not checked (no rules cover them).
    public let criteriaNotChecked: Int

    public init(
        score: Double,
        grade: String,
        criteriaScores: [CriterionScore],
        principleScores: [WCAGPrinciple: Double],
        fileScores: [FileScore],
        totalErrors: Int,
        totalWarnings: Int,
        totalInfo: Int,
        filesAnalyzed: Int,
        criteriaPassed: Int,
        criteriaFailed: Int,
        criteriaNotChecked: Int
    ) {
        self.score = score
        self.grade = grade
        self.criteriaScores = criteriaScores
        self.principleScores = principleScores
        self.fileScores = fileScores
        self.totalErrors = totalErrors
        self.totalWarnings = totalWarnings
        self.totalInfo = totalInfo
        self.filesAnalyzed = filesAnalyzed
        self.criteriaPassed = criteriaPassed
        self.criteriaFailed = criteriaFailed
        self.criteriaNotChecked = criteriaNotChecked
    }

    /// Map a numeric score to a letter grade.
    public static func letterGrade(for score: Double) -> String {
        switch score {
        case 97...100: return "A+"
        case 93..<97:  return "A"
        case 90..<93:  return "A-"
        case 87..<90:  return "B+"
        case 83..<87:  return "B"
        case 80..<83:  return "B-"
        case 77..<80:  return "C+"
        case 73..<77:  return "C"
        case 70..<73:  return "C-"
        case 67..<70:  return "D+"
        case 63..<67:  return "D"
        case 60..<63:  return "D-"
        default:       return "F"
        }
    }
}
