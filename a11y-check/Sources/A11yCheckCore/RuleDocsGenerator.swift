import Foundation

/// Generates Markdown documentation for all registered rules.
public struct RuleDocsGenerator {

    public init() {}

    /// Generate a full Markdown document listing all rules with metadata.
    public func generate(rules: [any A11yRule]) -> String {
        var md = "# a11y-check Rules Reference\n\n"
        md += "Generated automatically. \(rules.count) rules across \(uniqueCriteria(rules).count) WCAG criteria.\n\n"
        md += "| # | Rule ID | Severity | WCAG | Description |\n"
        md += "|---|---------|----------|------|-------------|\n"

        for (i, rule) in rules.enumerated() {
            let wcag = rule.wcagCriteria.joined(separator: ", ")
            let severity = rule.severity.rawValue
            md += "| \(i + 1) | `\(rule.id)` | \(severity) | \(wcag) | \(rule.description) |\n"
        }

        md += "\n---\n\n"

        // Group by WCAG criterion
        md += "## By WCAG Criterion\n\n"
        let criteria = groupByCriteria(rules)
        for (criterion, rulesForCriterion) in criteria.sorted(by: { $0.key < $1.key }) {
            md += "### WCAG \(criterion)\n\n"
            for rule in rulesForCriterion {
                md += "- **`\(rule.id)`** (\(rule.severity.rawValue)) — \(rule.name)\n"
            }
            md += "\n"
        }

        // Severity breakdown
        md += "## By Severity\n\n"
        let errors = rules.filter { $0.severity == .error }
        let warnings = rules.filter { $0.severity == .warning }
        let infos = rules.filter { $0.severity == .info }

        if !errors.isEmpty {
            md += "### Errors (\(errors.count))\n\n"
            for rule in errors {
                md += "- `\(rule.id)` — \(rule.name)\n"
            }
            md += "\n"
        }
        if !warnings.isEmpty {
            md += "### Warnings (\(warnings.count))\n\n"
            for rule in warnings {
                md += "- `\(rule.id)` — \(rule.name)\n"
            }
            md += "\n"
        }
        if !infos.isEmpty {
            md += "### Info (\(infos.count))\n\n"
            for rule in infos {
                md += "- `\(rule.id)` — \(rule.name)\n"
            }
            md += "\n"
        }

        return md
    }

    private func uniqueCriteria(_ rules: [any A11yRule]) -> Set<String> {
        var criteria = Set<String>()
        for rule in rules {
            criteria.formUnion(rule.wcagCriteria)
        }
        return criteria
    }

    private func groupByCriteria(_ rules: [any A11yRule]) -> [String: [any A11yRule]] {
        var groups: [String: [any A11yRule]] = [:]
        for rule in rules {
            for criterion in rule.wcagCriteria {
                groups[criterion, default: []].append(rule)
            }
        }
        return groups
    }
}
