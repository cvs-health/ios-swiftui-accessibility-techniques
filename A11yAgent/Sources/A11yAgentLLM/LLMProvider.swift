import Foundation
import A11yAgentCore

/// Protocol for LLM providers that perform context-aware accessibility analysis.
public protocol LLMProvider {
    /// Analyze code with additional context from static rule results.
    /// Returns additional diagnostics that static rules can't detect.
    func analyze(
        code: String,
        filePath: String,
        staticDiagnostics: [A11yDiagnostic],
        documentationContext: String
    ) async throws -> [A11yDiagnostic]
}

/// Prompt builder that constructs LLM prompts with relevant documentation context.
public struct PromptBuilder {

    /// Documentation content indexed by topic.
    public var documentationIndex: [String: String] = [:]

    public init() {}

    /// Load documentation from a directory of .md files.
    public mutating func loadDocumentation(from directoryPath: String) throws {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(atPath: directoryPath) else { return }

        while let relativePath = enumerator.nextObject() as? String {
            guard relativePath.hasSuffix(".md") else { continue }
            let fullPath = (directoryPath as NSString).appendingPathComponent(relativePath)
            let content = try String(contentsOfFile: fullPath, encoding: .utf8)
            let key = (relativePath as NSString).deletingPathExtension
            documentationIndex[key] = content
        }
    }

    /// Build the system prompt for LLM analysis.
    public func buildSystemPrompt() -> String {
        """
        You are an iOS SwiftUI accessibility expert. Analyze the provided SwiftUI code \
        for accessibility issues based on WCAG 2.2 guidelines and iOS-specific best practices.

        Focus on context-dependent issues that require semantic understanding:

        1. Whether an Image is decorative or informative (check surrounding context)
        2. Whether accessibility labels are meaningful and descriptive
        3. Whether related elements should be combined with .accessibilityElement(children: .combine)
        4. Whether reading order matches visual order (especially in complex layouts)
        5. Whether foreign-language text needs .accessibilityLanguage()
        6. Whether error handling provides accessible feedback
        7. Whether color is used as the sole means of conveying information
        8. Whether custom controls properly convey their state to VoiceOver

        For each issue found, respond in JSON format:
        [
          {
            "line": <1-based line number>,
            "column": <1-based column number>,
            "severity": "error" | "warning" | "info",
            "message": "<clear description of the issue>",
            "wcagCriteria": ["<criterion>"],
            "ruleID": "llm-<short-id>",
            "suggestion": "<how to fix it>"
          }
        ]

        If no additional issues are found beyond the static analysis results provided, return [].
        """
    }

    /// Build the user prompt for a specific file.
    public func buildUserPrompt(
        code: String,
        filePath: String,
        staticDiagnostics: [A11yDiagnostic],
        relevantDocs: [String]
    ) -> String {
        var prompt = "File: \(filePath)\n\n"

        // Include relevant documentation
        if !relevantDocs.isEmpty {
            prompt += "## Relevant Accessibility Guidelines\n\n"
            for docKey in relevantDocs {
                if let content = documentationIndex[docKey] {
                    prompt += content + "\n\n"
                }
            }
        }

        // Include static analysis results for context
        if !staticDiagnostics.isEmpty {
            prompt += "## Static Analysis Already Found These Issues\n\n"
            for diag in staticDiagnostics {
                prompt += "- Line \(diag.line): [\(diag.ruleID)] \(diag.message)\n"
            }
            prompt += "\nDo NOT re-report these. Only report NEW issues.\n\n"
        }

        prompt += "## Code to Analyze\n\n```swift\n\(code)\n```\n"

        return prompt
    }

    /// Determine which documentation files are relevant based on the code content.
    public func relevantDocKeys(for code: String) -> [String] {
        var relevant: [String] = []
        let lower = code.lowercased()

        let keywordMap: [(keywords: [String], docKey: String)] = [
            (["image(", "image(systemname:", "image(decorative:"], "InformativeImages"),
            (["image(decorative:", "accessibilityhidden"], "DecorativeImages"),
            ([".accessibilityaddtraits(.isheader)", ".font(.title", ".font(.headline", ".font(.largetitle"], "Headings"),
            (["button(", "button {"], "Buttons"),
            (["toggle("], "Toggles"),
            (["link("], "Links"),
            (["textfield(", "securefield("], "TextFields"),
            (["slider("], "Sliders"),
            (["stepper("], "Steppers"),
            (["picker(", "datepicker("], "Pickers"),
            ([".sheet(", ".fullscreencover("], "Sheets"),
            ([".alert("], "Alerts"),
            ([".ontapgesture"], "AccessibilityActions"),
            ([".accessibilityhidden"], "AccessibilityHidden"),
            (["navigationstack", "navigationview", ".navigationtitle"], "PageTitles"),
            ([".font(.system(size:"], "DynamicType"),
            (["colorscheme", ".foregroundcolor", ".background("], "DarkMode"),
            ([".accessibilityelement(children:"], "CombiningFocus"),
            ([".accessibilitysortpriority"], "ReadingOrder"),
            (["accessibilityfocusstate", ".accessibilityhint"], "ErrorValidation"),
            ([".accessibilitylanguage"], "Language"),
        ]

        for (keywords, docKey) in keywordMap {
            if keywords.contains(where: { lower.contains($0) }) {
                relevant.append(docKey)
            }
        }
        return relevant
    }
}

/// Stub LLM provider for direct API calls (OpenAI, Anthropic, etc.)
/// Replace with actual API implementation when ready.
public struct DirectAPIProvider: LLMProvider {
    public let apiKey: String
    public let model: String
    public let promptBuilder: PromptBuilder

    public init(apiKey: String, model: String = "gpt-4o", promptBuilder: PromptBuilder) {
        self.apiKey = apiKey
        self.model = model
        self.promptBuilder = promptBuilder
    }

    public func analyze(
        code: String,
        filePath: String,
        staticDiagnostics: [A11yDiagnostic],
        documentationContext: String
    ) async throws -> [A11yDiagnostic] {
        // TODO: Implement actual API call
        // 1. Build prompt using promptBuilder
        // 2. Call LLM API
        // 3. Parse JSON response into [A11yDiagnostic]
        return []
    }
}
