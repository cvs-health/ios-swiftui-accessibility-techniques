/*
   Copyright 2023 CVS Health and/or one of its affiliates

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

import UIKit
import SwiftUI

// MARK: - UIKit Implementation
class LinksViewController: UIViewController {
    
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    private let darkGreen = UIColor(red: 0/255, green: 102/255, blue: 0/255, alpha: 1.0)
    private let darkRed = UIColor(red: 220/255, green: 20/255, blue: 60/255, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Links"
        view.backgroundColor = .systemBackground
        
        setupScrollView()
        setupContentStackView()
        addAllContent()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupContentStackView() {
        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.alignment = .fill
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
    
    private func addAllContent() {
        // Introduction Text
        let introText = createLabel(text: "Links are used to open a URL in the user's web browser. The \"Link\" trait indicates to VoiceOver users that it will exit the app and open in their web browser. Link text must be specific to its purpose. Link text style must be discernable without using color alone when placed inline with static text, e.g. using `.underline()`. Link text color must have 4.5:1 contrast ratio in light and dark modes. Choose an `AccentColor` with sufficient contrast for light and dark appearance in the assets catalog `Assets.xcassets` file. Use `.accessibilityRemoveTraits(.isButton)` to remove the Button trait from `Link` elements.")
        contentStackView.addArrangedSubview(introText)
        
        // Good Examples Header
        let goodExamplesHeader = createHeaderLabel(text: "Good Examples", isGood: true)
        contentStackView.addArrangedSubview(goodExamplesHeader)
        
        let goodDivider = createDivider(isGood: true)
        contentStackView.addArrangedSubview(goodDivider)
        
        // Good Example Standalone Link
        let goodStandaloneLinkHeader = createHeaderLabel(text: "Good Example Standalone Link", isSubheader: true)
        contentStackView.addArrangedSubview(goodStandaloneLinkHeader)
        
        // Good standalone link
        let goodStandaloneLink = createLink(text: "View Weekly Ad", url: "https://www.example.com/weekly-ad", isGood: true)
        goodStandaloneLink.accessibilityTraits.remove(.button)
        goodStandaloneLink.accessibilityIdentifier = "goodLink2"
        contentStackView.addArrangedSubview(goodStandaloneLink)
        
        // Details disclosure for good standalone link
        let goodStandaloneLinkDetails = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The good standalone link example is correctly coded as a `Link` element which speaks a \"Link\" trait to VoiceOver. The color contrast is corrected using an `AccentColor` with sufficient contrast for light and dark appearance in the assets catalog `Assets.xcassets` file. The Button is trait removed so that VoiceOver does not speak \"Button, Link\".",
            accessibilityHint: "Good Example Standalone Link"
        )
        contentStackView.addArrangedSubview(goodStandaloneLinkDetails)
        
        // Good Example Inline Links
        let goodInlineLinkHeader = createHeaderLabel(text: "Good Example Inline Links", isSubheader: true)
        contentStackView.addArrangedSubview(goodInlineLinkHeader)
        
        // Create container for inline links
        let inlineLinksContainer = UIView()
        
        // Create text and links for inline container
        let startText = createLabel(text: "To get started")
        startText.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let loginLink = createLink(text: "Log In", url: "https://www.example.com/login", isGood: true)
        addUnderline(to: loginLink)
        loginLink.accessibilityTraits.remove(.button)
        loginLink.accessibilityIdentifier = "goodLink1a"
        
        let orText = createLabel(text: "or")
        
        let createAccountLink = createLink(text: "Create Account", url: "https://www.example.com/create-account", isGood: true)
        addUnderline(to: createAccountLink)
        createAccountLink.accessibilityTraits.remove(.button)
        createAccountLink.accessibilityIdentifier = "goodLink1b"
        
        // Add all elements to the container
        inlineLinksContainer.addSubview(startText)
        inlineLinksContainer.addSubview(loginLink)
        inlineLinksContainer.addSubview(orText)
        inlineLinksContainer.addSubview(createAccountLink)
        
        // Configure layout
        startText.translatesAutoresizingMaskIntoConstraints = false
        loginLink.translatesAutoresizingMaskIntoConstraints = false
        orText.translatesAutoresizingMaskIntoConstraints = false
        createAccountLink.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            startText.leadingAnchor.constraint(equalTo: inlineLinksContainer.leadingAnchor),
            startText.topAnchor.constraint(equalTo: inlineLinksContainer.topAnchor),
            
            loginLink.leadingAnchor.constraint(equalTo: startText.trailingAnchor, constant: 4),
            loginLink.centerYAnchor.constraint(equalTo: startText.centerYAnchor),
            
            orText.leadingAnchor.constraint(equalTo: loginLink.trailingAnchor, constant: 4),
            orText.centerYAnchor.constraint(equalTo: startText.centerYAnchor),
            
            createAccountLink.leadingAnchor.constraint(equalTo: orText.trailingAnchor, constant: 4),
            createAccountLink.centerYAnchor.constraint(equalTo: startText.centerYAnchor),
            createAccountLink.trailingAnchor.constraint(lessThanOrEqualTo: inlineLinksContainer.trailingAnchor),
            
            inlineLinksContainer.bottomAnchor.constraint(equalTo: startText.bottomAnchor, constant: 4)
        ])
        
        contentStackView.addArrangedSubview(inlineLinksContainer)
        
        // Details disclosure for good inline links
        let goodInlineLinkDetails = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The good inline links example uses unique and specific link text. `.underline()` is used to make the inline links visually distinct without using color alone. An `AccentColor` with sufficient contrast for light and dark appearance is specified in the assets catalog `Assets.xcassets` file. Additionally `.accessibilityRemoveTraits(.isButton)` is used to remove the Button trait so that VoiceOver users don't hear \"Button\" spoken.",
            accessibilityHint: "Good Example Inline Links"
        )
        contentStackView.addArrangedSubview(goodInlineLinkDetails)
        
        // Good Example AttributedString Inline Links
        let goodAttributedHeader = createHeaderLabel(text: "Good Example AttributedString Inline Links", isSubheader: true)
        contentStackView.addArrangedSubview(goodAttributedHeader)
        
        // Create attributed text with links
        let attributedLabel = UILabel()
        attributedLabel.numberOfLines = 0
        attributedLabel.attributedText = createGoodAttributedString()
        attributedLabel.isUserInteractionEnabled = true
        
        // Add tap gesture recognizer to handle link taps
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleAttributedLinkTap(_:)))
        attributedLabel.addGestureRecognizer(tapGesture)
        
        contentStackView.addArrangedSubview(attributedLabel)
        
        // Details disclosure for good attributed string links
        let goodAttributedDetails = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The good `AttributedString` inline links example uses `AttributedString` to set `.underlineStyle = Text.LineStyle(nsUnderlineStyle: .single)`. An `AccentColor` with sufficient contrast for light and dark appearance is specified in the assets catalog `Assets.xcassets` file. With `AttributedString` links VoiceOver users must use the Rotor to focus on each link invidiually.",
            accessibilityHint: "Good Example AttributedString Inline Links"
        )
        contentStackView.addArrangedSubview(goodAttributedDetails)
        
        // Markdown Inline Links Example
        let markdownHeader = createHeaderLabel(text: "Markdown Inline Links Example", isSubheader: true)
        contentStackView.addArrangedSubview(markdownHeader)
        
        // Create attributed text with links (markdown-like)
        let markdownLabel = UILabel()
        markdownLabel.numberOfLines = 0
        markdownLabel.attributedText = createMarkdownLikeAttributedString()
        markdownLabel.isUserInteractionEnabled = true
        
        // Add tap gesture recognizer to handle link taps
        let markdownTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleAttributedLinkTap(_:)))
        markdownLabel.addGestureRecognizer(markdownTapGesture)
        
        contentStackView.addArrangedSubview(markdownLabel)
        
        // Details disclosure for markdown links
        let markdownDetails = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The inline markdown links example uses markdown format links `[Name](https://www.example.com)` where each link must be focused invidually using the VoiceOver Rotor. The markdown links have a `AccentColor` applied with sufficient contrast but they cannot be underlined or have different text style than the surrounding inline text.",
            accessibilityHint: "Markdown Inline Links Example"
        )
        contentStackView.addArrangedSubview(markdownDetails)
        
        // Bad Examples Header
        let badExamplesHeader = createHeaderLabel(text: "Bad Examples", isGood: false)
        contentStackView.addArrangedSubview(badExamplesHeader)
        
        let badDivider = createDivider(isGood: false)
        contentStackView.addArrangedSubview(badDivider)
        
        // Bad Example Standalone Link
        let badStandaloneLinkHeader = createHeaderLabel(text: "Bad Example Standalone Link", isSubheader: true)
        contentStackView.addArrangedSubview(badStandaloneLinkHeader)
        
        // Bad standalone link (using button)
        let badStandaloneButton = UIButton(type: .system)
        badStandaloneButton.setTitle("View Weekly Ad", for: .normal)
        badStandaloneButton.tintColor = .systemBlue
        badStandaloneButton.contentHorizontalAlignment = .left
        badStandaloneButton.addTarget(self, action: #selector(openURL(_:)), for: .touchUpInside)
        badStandaloneButton.accessibilityIdentifier = "badLink2"
        
        contentStackView.addArrangedSubview(badStandaloneButton)
        
        // Details disclosure for bad standalone link
        let badStandaloneLinkDetails = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The bad standalone link example is incorrectly coded as a `Button` element which speaks a \"Button\" trait to VoiceOver rather than a \"Link\" trait. The `.tint(.blue)` color link contrast ratio is below the 4.5:1 WCAG minimum.",
            accessibilityHint: "Bad Example Standalone Link"
        )
        contentStackView.addArrangedSubview(badStandaloneLinkDetails)
        
        // Bad Example Inline Links
        let badInlineLinkHeader = createHeaderLabel(text: "Bad Example Inline Links", isSubheader: true)
        contentStackView.addArrangedSubview(badInlineLinkHeader)
        
        // Create container for bad inline links
        let badInlineLinksContainer = UIView()
        
        // Create text and links for inline container
        let clickHereLink = createLink(text: "Click here", url: "https://www.example.com/login", isGood: false)
        clickHereLink.tintColor = .systemBlue
        clickHereLink.accessibilityIdentifier = "badLink1a"
        
        let toLoginText = createLabel(text: "to login, or")
        
        let hereLink = createLink(text: "here", url: "https://www.example.com/create-account", isGood: false)
        hereLink.tintColor = .systemBlue
        hereLink.accessibilityIdentifier = "badLink1b"
        
        let toCreateAccountText = createLabel(text: "to create account.")
        
        // Add all elements to the container
        badInlineLinksContainer.addSubview(clickHereLink)
        badInlineLinksContainer.addSubview(toLoginText)
        badInlineLinksContainer.addSubview(hereLink)
        badInlineLinksContainer.addSubview(toCreateAccountText)
        
        // Configure layout
        clickHereLink.translatesAutoresizingMaskIntoConstraints = false
        toLoginText.translatesAutoresizingMaskIntoConstraints = false
        hereLink.translatesAutoresizingMaskIntoConstraints = false
        toCreateAccountText.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            clickHereLink.leadingAnchor.constraint(equalTo: badInlineLinksContainer.leadingAnchor),
            clickHereLink.topAnchor.constraint(equalTo: badInlineLinksContainer.topAnchor),
            
            toLoginText.leadingAnchor.constraint(equalTo: clickHereLink.trailingAnchor, constant: 4),
            toLoginText.centerYAnchor.constraint(equalTo: clickHereLink.centerYAnchor),
            
            hereLink.leadingAnchor.constraint(equalTo: toLoginText.trailingAnchor, constant: 4),
            hereLink.centerYAnchor.constraint(equalTo: clickHereLink.centerYAnchor),
            
            toCreateAccountText.leadingAnchor.constraint(equalTo: hereLink.trailingAnchor, constant: 4),
            toCreateAccountText.centerYAnchor.constraint(equalTo: clickHereLink.centerYAnchor),
            toCreateAccountText.trailingAnchor.constraint(lessThanOrEqualTo: badInlineLinksContainer.trailingAnchor),
            
            badInlineLinksContainer.bottomAnchor.constraint(equalTo: clickHereLink.bottomAnchor, constant: 4)
        ])
        
        contentStackView.addArrangedSubview(badInlineLinksContainer)
        
        // Details disclosure for bad inline links
        let badInlineLinkDetails = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The bad inline links example uses generic link text \"Click here\" and \"here\" and the links are not underlined to be visually distinct without using color alone. The bad link examples use the `.tint(.blue)` color which has an insufficient contrast ratio. The default Button trait remains causing VoiceOver to speak \"Button, Link\".",
            accessibilityHint: "Bad Example Inline Links"
        )
        contentStackView.addArrangedSubview(badInlineLinkDetails)
        
        // Bad Example AttributedString Inline Links
        let badAttributedHeader = createHeaderLabel(text: "Bad Example AttributedString Inline Links", isSubheader: true)
        contentStackView.addArrangedSubview(badAttributedHeader)
        
        // Create bad attributed text with links (no underline)
        let badAttributedLabel = UILabel()
        badAttributedLabel.numberOfLines = 0
        badAttributedLabel.attributedText = createBadAttributedString()
        badAttributedLabel.isUserInteractionEnabled = true
        
        // Add tap gesture recognizer to handle link taps
        let badAttributedTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleAttributedLinkTap(_:)))
        badAttributedLabel.addGestureRecognizer(badAttributedTapGesture)
        
        contentStackView.addArrangedSubview(badAttributedLabel)
        
        // Details disclosure for bad attributed string links
        let badAttributedDetails = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The bad `AttributedString` inline links example uses `AttributedString` with the default link style for each link inside the attributed string. The inline links are not underlined or made visually distinct without using color alone. VoiceOver users must focus each link invidiually using the Rotor.",
            accessibilityHint: "Bad Example AttributedString Inline Links"
        )
        contentStackView.addArrangedSubview(badAttributedDetails)
        
        // Bad Example Inline Markdown Links
        let badMarkdownHeader = createHeaderLabel(text: "Bad Example Inline Markdown Links", isSubheader: true)
        contentStackView.addArrangedSubview(badMarkdownHeader)
        
        // Create bad markdown-like attributed text with links (blue tint, no underline)
        let badMarkdownLabel = UILabel()
        badMarkdownLabel.numberOfLines = 0
        badMarkdownLabel.attributedText = createBadMarkdownLikeAttributedString()
        badMarkdownLabel.isUserInteractionEnabled = true
        
        // Add tap gesture recognizer to handle link taps
        let badMarkdownTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleAttributedLinkTap(_:)))
        badMarkdownLabel.addGestureRecognizer(badMarkdownTapGesture)
        
        contentStackView.addArrangedSubview(badMarkdownLabel)
        
        // Details disclosure for bad markdown links
        let badMarkdownDetails = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The bad inline markdown links example uses Markdown inline links with `.tint(.blue)` which have insufficient contrast and are not underlined.",
            accessibilityHint: "Bad Example Inline Markdown Links"
        )
        contentStackView.addArrangedSubview(badMarkdownDetails)
    }
    
    // MARK: - Helper Methods
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        return label
    }
    
    private func createHeaderLabel(text: String, isGood: Bool = true, isSubheader: Bool = false) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        
        if isSubheader {
            label.font = UIFont.boldSystemFont(ofSize: 15)
        } else {
            label.font = UIFont.boldSystemFont(ofSize: 17)
            label.textColor = isGood ? darkGreen : darkRed
        }
        
        label.accessibilityTraits = .header
        
        return label
    }
    
    private func createLink(text: String, url: String, isGood: Bool) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(text, for: .normal)
        
        if isGood {
            button.tintColor = UIColor(named: "AccentColor") // Using your app's accent color
        } else {
            button.tintColor = .systemBlue
        }
        
        button.contentHorizontalAlignment = .left
        button.tag = url.hashValue
        button.addTarget(self, action: #selector(linkTapped(_:)), for: .touchUpInside)
        
        // Set accessibility traits for links
        button.accessibilityTraits = [.button, .link]
        
        return button
    }
    
    private func addUnderline(to button: UIButton) {
        guard let title = button.title(for: .normal) else { return }
        
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttribute(
            .underlineStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: NSRange(location: 0, length: attributedString.length)
        )
        
        button.setAttributedTitle(attributedString, for: .normal)
    }
    
    private func createGoodAttributedString() -> NSAttributedString {
        let text = "To get started Login or Create Account. Contact Us if you need help."
        let attributedString = NSMutableAttributedString(string: text)
        
        // Find ranges of link text
        let loginRange = (text as NSString).range(of: "Login")
        let createAccountRange = (text as NSString).range(of: "Create Account")
        let contactUsRange = (text as NSString).range(of: "Contact Us")
        
        // Add links with underlines
        let linkAttributes: [NSAttributedString.Key: Any] = [
            .link: URL(string: "https://example.com/login")!,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor(named: "AccentColor") ?? .systemBlue
        ]
        attributedString.setAttributes(linkAttributes, range: loginRange)
        
        let createAccountAttributes: [NSAttributedString.Key: Any] = [
            .link: URL(string: "https://example.com/create-account")!,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor(named: "AccentColor") ?? .systemBlue
        ]
        attributedString.setAttributes(createAccountAttributes, range: createAccountRange)
        
        let contactUsAttributes: [NSAttributedString.Key: Any] = [
            .link: URL(string: "https://example.com/contact")!,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor(named: "AccentColor") ?? .systemBlue
        ]
        attributedString.setAttributes(contactUsAttributes, range: contactUsRange)
        
        return attributedString
    }
    
    private func createBadAttributedString() -> NSAttributedString {
        let text = "To get started Login or Create Account. Contact Us if you need help."
        let attributedString = NSMutableAttributedString(string: text)
        
        // Find ranges of link text
        let loginRange = (text as NSString).range(of: "Login")
        let createAccountRange = (text as NSString).range(of: "Create Account")
        let contactUsRange = (text as NSString).range(of: "Contact Us")
        
        // Add links without underlines
        let linkAttributes: [NSAttributedString.Key: Any] = [
            .link: URL(string: "https://example.com/login")!,
            .foregroundColor: UIColor.systemBlue
        ]
        attributedString.setAttributes(linkAttributes, range: loginRange)
        
        let createAccountAttributes: [NSAttributedString.Key: Any] = [
            .link: URL(string: "https://example.com/create-account")!,
            .foregroundColor: UIColor.systemBlue
        ]
        attributedString.setAttributes(createAccountAttributes, range: createAccountRange)
        
        let contactUsAttributes: [NSAttributedString.Key: Any] = [
            .link: URL(string: "https://example.com/contact")!,
            .foregroundColor: UIColor.systemBlue
        ]
        attributedString.setAttributes(contactUsAttributes, range: contactUsRange)
        
        return attributedString
    }
    
    private func createMarkdownLikeAttributedString() -> NSAttributedString {
        let text = "To get started [Log In](https://www.example.com/login) or [Create Account](https://www.example.com/create-account). [Contact Us](https://www.example.com/contact) if you need help."
        
        // Process markdown-like syntax to create attributed string
        let attributedString = NSMutableAttributedString(string: text)
        
        // Regular expression to find markdown links
        let linkPattern = "\\[(.*?)\\]\\((.*?)\\)"
        let regex = try! NSRegularExpression(pattern: linkPattern, options: [])
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
        
        // Process matches from end to start to avoid range issues
        for match in matches.reversed() {
            let fullRange = match.range
            let linkTextRange = match.range(at: 1)
            let urlRange = match.range(at: 2)
            
            let linkText = (text as NSString).substring(with: linkTextRange)
            let urlString = (text as NSString).substring(with: urlRange)
            
            // Create a replacement string (just the link text)
            let replacementString = NSMutableAttributedString(string: linkText)
            
            // Add link attributes
            let linkAttributes: [NSAttributedString.Key: Any] = [
                .link: URL(string: urlString)!,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: UIColor(named: "AccentColor") ?? .systemBlue
            ]
            replacementString.setAttributes(linkAttributes, range: NSRange(location: 0, length: linkText.count))
            
            // Replace the markdown syntax with the link text
            attributedString.replaceCharacters(in: fullRange, with: replacementString)
        }
        
        return attributedString
    }
    
    private func createBadMarkdownLikeAttributedString() -> NSAttributedString {
        let text = "To get started [Log In](https://www.example.com/login) or [Create Account](https://www.example.com/create-account). [Contact Us](https://www.example.com/contact) if you need help."
        
        // Process markdown-like syntax to create attributed string
        let attributedString = NSMutableAttributedString(string: text)
        
        // Regular expression to find markdown links
        let linkPattern = "\\[(.*?)\\]\\((.*?)\\)"
        let regex = try! NSRegularExpression(pattern: linkPattern, options: [])
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
        
        // Process matches from end to start to avoid range issues
        for match in matches.reversed() {
            let fullRange = match.range
            let linkTextRange = match.range(at: 1)
            let urlRange = match.range(at: 2)
            
            let linkText = (text as NSString).substring(with: linkTextRange)
            let urlString = (text as NSString).substring(with: urlRange)
            
            // Create a replacement string (just the link text)
            let replacementString = NSMutableAttributedString(string: linkText)
            
            // Add link attributes - BAD example without underline
            let linkAttributes: [NSAttributedString.Key: Any] = [
                .link: URL(string: urlString)!,
                .foregroundColor: UIColor.systemBlue
            ]
            replacementString.setAttributes(linkAttributes, range: NSRange(location: 0, length: linkText.count))
            
            // Replace the markdown syntax with the link text
            attributedString.replaceCharacters(in: fullRange, with: replacementString)
        }
        
        return attributedString
    }
    
    private func createDivider(isGood: Bool) -> UIView {
        let divider = UIView()
        divider.backgroundColor = isGood ? darkGreen : darkRed
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 2).isActive = true
        return divider
    }
    
    private func createDisclosureGroup(headerText: String, detailsText: String, accessibilityHint: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let disclosureButton = UIButton(type: .system)
        disclosureButton.setTitle(headerText, for: .normal)
        disclosureButton.contentHorizontalAlignment = .left
        disclosureButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        disclosureButton.translatesAutoresizingMaskIntoConstraints = false
        disclosureButton.accessibilityHint = accessibilityHint
        disclosureButton.tag = 0 // Closed state
        
        let detailsLabel = UILabel()
        detailsLabel.text = detailsText
        detailsLabel.numberOfLines = 0
        detailsLabel.isHidden = true
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(disclosureButton)
        containerView.addSubview(detailsLabel)
        
        NSLayoutConstraint.activate([
            disclosureButton.topAnchor.constraint(equalTo: containerView.topAnchor),
            disclosureButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            disclosureButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            detailsLabel.topAnchor.constraint(equalTo: disclosureButton.bottomAnchor, constant: 8),
            detailsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            detailsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            detailsLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        disclosureButton.addTarget(self, action: #selector(toggleDisclosure(_:)), for: .touchUpInside)
        
        return containerView
    }
    
    // MARK: - Actions
    
    @objc private func linkTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        
        var urlString: String
        
        // Determine URL based on link text or tag
        switch title {
        case "View Weekly Ad":
            urlString = "https://www.example.com/weekly-ad"
        case "Log In":
            urlString = "https://www.example.com/login"
        case "Create Account":
            urlString = "https://www.example.com/create-account"
        case "Click here":
            urlString = "https://www.example.com/login"
        case "here":
            urlString = "https://www.example.com/create-account"
        default:
            urlString = "https://www.example.com"
        }
        
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @objc private func openURL(_ sender: UIButton) {
        guard let url = URL(string: "https://www.example.com/weekly-ad") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @objc private func handleAttributedLinkTap(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel,
              let attributedText = label.attributedText else { return }
        
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: attributedText)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.size = label.bounds.size
        
        let tapLocation = gesture.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(
            x: (label.bounds.width - textBoundingBox.width) * 0.5 - textBoundingBox.minX,
            y: (label.bounds.height - textBoundingBox.height) * 0.5 - textBoundingBox.minY
        )
        let locationOfTouchInTextContainer = CGPoint(
            x: tapLocation.x - textContainerOffset.x,
            y: tapLocation.y - textContainerOffset.y
        )
        let indexOfCharacter = layoutManager.characterIndex(
            for: locationOfTouchInTextContainer,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // Check if the tap was on a link
        if indexOfCharacter < attributedText.length {
            if let url = attributedText.attribute(.link, at: indexOfCharacter, effectiveRange: nil) as? URL {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @objc private func toggleDisclosure(_ sender: UIButton) {
        if let containerView = sender.superview,
           let detailsLabel = containerView.subviews.compactMap({ $0 as? UILabel }).first {
            
            detailsLabel.isHidden.toggle()
            
            if detailsLabel.isHidden {
                sender.setImage(UIImage(systemName: "chevron.right"), for: .normal)
                sender.tag = 0
            } else {
                sender.setImage(UIImage(systemName: "chevron.down"), for: .normal)
                sender.tag = 1
            }
        }
    }
}

// MARK: - SwiftUI Wrapper
struct LinksView: View {
    var body: some View {
        LinksViewControllerRepresentable()
            .navigationTitle("Links")
    }
}

struct LinksViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> LinksViewController {
        return LinksViewController()
    }
    
    func updateUIViewController(_ uiViewController: LinksViewController, context: Context) {
        // Update the view controller if needed
    }
}

struct LinksView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LinksView()
        }
    }
}
