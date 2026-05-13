import Foundation

/// Formats diagnostics as SARIF (Static Analysis Results Interchange Format)
/// for GitHub code scanning and other SARIF-compatible tools.
/// Spec: https://docs.oasis-open.org/sarif/sarif/v2.1.0/sarif-v2.1.0.html
public struct SARIFFormatter {

    public init() {}

    public func format(
        _ diagnostics: [A11yDiagnostic],
        rules: [any A11yRule],
        score: A11yScore? = nil
    ) throws -> String {
        // Build rules array for the tool component
        let ruleEntries: [[String: Any]] = rules.map { rule in
            var entry: [String: Any] = [
                "id": rule.id,
                "name": rule.name,
                "shortDescription": ["text": rule.name],
                "fullDescription": ["text": rule.description],
                "defaultConfiguration": ["level": sarifLevel(for: rule.severity)],
                "helpUri": wcagHelpUri(for: rule.wcagCriteria.first ?? ""),
            ]
            entry["properties"] = [
                "impact": rule.impact.rawValue,
                "wcagCriteria": rule.wcagCriteria,
                "tags": ["accessibility", "wcag"] + rule.wcagCriteria.map { "wcag-\($0)" },
            ] as [String: Any]
            return entry
        }

        // Build results array
        let results: [[String: Any]] = diagnostics.map { diag in
            var result: [String: Any] = [
                "ruleId": diag.ruleID,
                "level": sarifLevel(for: diag.severity),
                "message": ["text": diag.message],
                "locations": [
                    [
                        "physicalLocation": [
                            "artifactLocation": [
                                "uri": diag.filePath,
                                "uriBaseId": "%SRCROOT%",
                            ],
                            "region": [
                                "startLine": diag.line,
                                "startColumn": diag.column,
                            ],
                        ] as [String: Any],
                    ] as [String: Any],
                ],
            ]
            if let fix = diag.fix {
                result["fixes"] = [
                    [
                        "description": ["text": fix.description],
                    ] as [String: Any],
                ]
            }
            result["properties"] = [
                "impact": diag.impact.rawValue,
                "wcagCriteria": diag.wcagCriteria,
            ] as [String: Any]
            return result
        }

        // Build invocation with score
        var invocationProps: [String: Any] = [:]
        if let score = score {
            invocationProps["a11yScore"] = score.score
            invocationProps["a11yGrade"] = score.grade
            invocationProps["criteriaPassed"] = score.criteriaPassed
            invocationProps["criteriaFailed"] = score.criteriaFailed
        }

        let invocations: [[String: Any]] = [
            [
                "executionSuccessful": true,
                "properties": invocationProps,
            ] as [String: Any],
        ]

        let sarif: [String: Any] = [
            "$schema": "https://raw.githubusercontent.com/oasis-tcs/sarif-spec/main/sarif-2.1/schema/sarif-schema-2.1.0.json",
            "version": "2.1.0",
            "runs": [
                [
                    "tool": [
                        "driver": [
                            "name": "a11y-check",
                            "informationUri": "https://github.com/cvs-health/ios-swiftui-accessibility-techniques",
                            "version": "0.3.0",
                            "rules": ruleEntries,
                        ] as [String: Any],
                    ],
                    "results": results,
                    "invocations": invocations,
                ] as [String: Any],
            ],
        ]

        let data = try JSONSerialization.data(withJSONObject: sarif, options: [.prettyPrinted, .sortedKeys])
        return String(data: data, encoding: .utf8) ?? "{}"
    }

    private func sarifLevel(for severity: A11ySeverity) -> String {
        switch severity {
        case .error:   return "error"
        case .warning: return "warning"
        case .info:    return "note"
        }
    }

    private func wcagHelpUri(for criterion: String) -> String {
        guard !criterion.isEmpty else { return "https://www.w3.org/TR/WCAG22/" }
        let parts = criterion.split(separator: ".")
        guard parts.count == 3 else { return "https://www.w3.org/TR/WCAG22/" }
        return "https://www.w3.org/TR/WCAG22/#:\(criterion)"
    }
}
