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
import SafariServices
import WebKit

// MARK: - UIKit Implementation

class InformativeViewController: UIViewController {
    
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    private let darkGreen = UIColor(red: 0/255, green: 102/255, blue: 0/255, alpha: 1.0)
    private let darkRed = UIColor(red: 220/255, green: 20/255, blue: 60/255, alpha: 1.0)
    
    private var documentationButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Informative Images"
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
        let introText = createTextViewWithSelectableText(text: "Informative images provide information or convey meaning to sighted users that must be accessible to VoiceOver users. Give informative images an accessibility label either through `Label(\"text\")` or `.accessibilityLabel(\"text\")`. Use `.accessibilityElement(children: .combine)` to combine an image and text into a single focusable element with VoiceOver.")
        contentStackView.addArrangedSubview(introText)
        
        // Documentation Button
        documentationButton = UIButton(type: .system)
        documentationButton.setTitle("Informative Images Documentation", for: .normal)
        documentationButton.contentHorizontalAlignment = .left
        documentationButton.addTarget(self, action: #selector(openDocumentation), for: .touchUpInside)
        contentStackView.addArrangedSubview(documentationButton)
        
        // Good Examples Header
        let goodExamplesHeader = createHeaderLabel(text: "Good Examples", isGood: true)
        contentStackView.addArrangedSubview(goodExamplesHeader)
        
        let goodDivider = createDivider(isGood: true)
        contentStackView.addArrangedSubview(goodDivider)
        
        // Good Example Image().accessibilityLabel
        let goodImageHeader = createHeaderLabel(text: "Good Example `Image().accessibilityLabel`", isSubheader: true)
        contentStackView.addArrangedSubview(goodImageHeader)
        
        // Good image with accessibility label
        let goodImage = UIImageView(image: UIImage(named: "get10off"))
        goodImage.contentMode = .scaleAspectFit
        goodImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        goodImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        goodImage.isAccessibilityElement = true
        goodImage.accessibilityLabel = "Get 10% off"
        goodImage.accessibilityIdentifier = "goodImage"
        
        // Center the image
        let goodImageContainer = UIView()
        goodImageContainer.addSubview(goodImage)
        goodImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            goodImage.centerXAnchor.constraint(equalTo: goodImageContainer.centerXAnchor),
            goodImage.topAnchor.constraint(equalTo: goodImageContainer.topAnchor),
            goodImage.bottomAnchor.constraint(equalTo: goodImageContainer.bottomAnchor)
        ])
        contentStackView.addArrangedSubview(goodImageContainer)
        
        // Newsletter text
        let newsletterText = createLabel(text: "Sign up for our newsletter.")
        contentStackView.addArrangedSubview(newsletterText)
        
        // Details disclosure for good image
        let goodImageDetails = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The good informative image example uses `.accessibilityLabel(\"Get 10% off\")` to give it an accessibility label that matches the visible text shown in the image.",
            accessibilityHint: "Good Example `Image().accessibilityLabel`"
        )
        contentStackView.addArrangedSubview(goodImageDetails)
        
        // Good Example Label with SystemImage
        let goodLabelSystemImageHeader = createHeaderLabel(text: "Good Example `Label(\"Text\", systemImage:).accessibilityRemoveTraits(.isImage)` `HStack {}.accessibilityElement(children: .combine)`", isSubheader: true)
        contentStackView.addArrangedSubview(goodLabelSystemImageHeader)
        
        // Hello World with globe
        let helloWorldContainer = UIView()
        let helloLabel = createLabel(text: "Hello,")
        let globeImageView = UIImageView(image: UIImage(systemName: "globe"))
        globeImageView.tintColor = .label
        globeImageView.contentMode = .scaleAspectFit
        globeImageView.isAccessibilityElement = false
        globeImageView.accessibilityIdentifier = "goodIcon"
        let exclamationLabel = createLabel(text: "!")
        
        helloWorldContainer.addSubview(helloLabel)
        helloWorldContainer.addSubview(globeImageView)
        helloWorldContainer.addSubview(exclamationLabel)
        
        helloLabel.translatesAutoresizingMaskIntoConstraints = false
        globeImageView.translatesAutoresizingMaskIntoConstraints = false
        exclamationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            helloLabel.leadingAnchor.constraint(equalTo: helloWorldContainer.leadingAnchor),
            helloLabel.centerYAnchor.constraint(equalTo: helloWorldContainer.centerYAnchor),
            
            globeImageView.leadingAnchor.constraint(equalTo: helloLabel.trailingAnchor, constant: 4),
            globeImageView.centerYAnchor.constraint(equalTo: helloWorldContainer.centerYAnchor),
            globeImageView.heightAnchor.constraint(equalToConstant: 24),
            globeImageView.widthAnchor.constraint(equalToConstant: 24),
            
            exclamationLabel.leadingAnchor.constraint(equalTo: globeImageView.trailingAnchor, constant: 4),
            exclamationLabel.centerYAnchor.constraint(equalTo: helloWorldContainer.centerYAnchor),
            
            helloWorldContainer.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        // Make the whole container accessible as a single element
        helloWorldContainer.isAccessibilityElement = true
        helloWorldContainer.accessibilityLabel = "Hello, World!"
        
        contentStackView.addArrangedSubview(helloWorldContainer)
        
        // Details disclosure for good label with system image
        let goodLabelSystemImageDetails = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The good informative icon image example uses `Label(\"World\", systemImage: \"globe\").labelStyle(IconOnlyLabelStyle())` to give the informative icon an accessibility label that is not displayed visually. Additionally `.accessibilityRemoveTraits(.isImage)` must be used on the icon image so that the accessibility label is spoken to VoiceOver when the `HStack` is combined into a single focusable element using `.accessibilityElement(children: .combine)`.",
            accessibilityHint: "Good Example `Label(\"Text\", systemImage:).accessibilityRemoveTraits(.isImage)` `HStack {}.accessibilityElement(children: .combine)`"
        )
        contentStackView.addArrangedSubview(goodLabelSystemImageDetails)
        
        // Good Example Image combined with Text
        let goodImageTextHeader = createHeaderLabel(text: "Good Example `Image` combined with `Text`", isSubheader: true)
        contentStackView.addArrangedSubview(goodImageTextHeader)
        
        // Error message with exclamation circle
        let errorContainer = UIView()
        let exclamationImageView = UIImageView(image: UIImage(systemName: "exclamationmark.circle"))
        exclamationImageView.tintColor = darkRed
        exclamationImageView.contentMode = .scaleAspectFit
        exclamationImageView.isAccessibilityElement = false
        
        let errorLabel = createLabel(text: "We're sorry. We can't show the offer details right now.")
        errorLabel.font = UIFont.boldSystemFont(ofSize: 16) // 16 is typically close to callout size
        errorLabel.textColor = darkRed
        
        errorContainer.addSubview(exclamationImageView)
        errorContainer.addSubview(errorLabel)
        
        exclamationImageView.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            exclamationImageView.leadingAnchor.constraint(equalTo: errorContainer.leadingAnchor),
            exclamationImageView.centerYAnchor.constraint(equalTo: errorContainer.centerYAnchor),
            exclamationImageView.heightAnchor.constraint(equalToConstant: 24),
            exclamationImageView.widthAnchor.constraint(equalToConstant: 24),
            
            errorLabel.leadingAnchor.constraint(equalTo: exclamationImageView.trailingAnchor, constant: 8),
            errorLabel.trailingAnchor.constraint(equalTo: errorContainer.trailingAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: errorContainer.centerYAnchor),
            
            errorContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 30)
        ])
        
        // Make the whole container accessible as a single element
        errorContainer.isAccessibilityElement = true
        errorContainer.accessibilityLabel = "Error: We're sorry. We can't show the offer details right now."
        
        contentStackView.addArrangedSubview(errorContainer)
        
        // Details disclosure for good image with text
        let goodImageTextDetails = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The good `Image` combined with `Text` example uses `Image(systemName: \"exclamationmark.circle\").accessibilityLabel(\"Error:\")` to give the error icon alt text. `.accessibilityElement(children: .combine)` is used on the `HStack` to combine the image and text into a single focusable element with VoiceOver.",
            accessibilityHint: "Good Example `Image` combined with `Text`"
        )
        contentStackView.addArrangedSubview(goodImageTextDetails)
        
        // Good Example Label combined with Text
        let goodLabelTextHeader = createHeaderLabel(text: "Good Example `Label` combined with `Text`", isSubheader: true)
        contentStackView.addArrangedSubview(goodLabelTextHeader)
        
        // Another error message with exclamation circle (Label version)
        let errorLabelContainer = UIView()
        let exclamationLabelImageView = UIImageView(image: UIImage(systemName: "exclamationmark.circle"))
        exclamationLabelImageView.tintColor = darkRed
        exclamationLabelImageView.contentMode = .scaleAspectFit
        exclamationLabelImageView.isAccessibilityElement = false
        
        let errorLabelText = createLabel(text: "We're sorry. We can't show the offer details right now.")
        errorLabel.font = UIFont.boldSystemFont(ofSize: 16) // 16 is typically close to callout size
        errorLabelText.textColor = darkRed
        
        errorLabelContainer.addSubview(exclamationLabelImageView)
        errorLabelContainer.addSubview(errorLabelText)
        
        exclamationLabelImageView.translatesAutoresizingMaskIntoConstraints = false
        errorLabelText.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            exclamationLabelImageView.leadingAnchor.constraint(equalTo: errorLabelContainer.leadingAnchor),
            exclamationLabelImageView.centerYAnchor.constraint(equalTo: errorLabelContainer.centerYAnchor),
            exclamationLabelImageView.heightAnchor.constraint(equalToConstant: 24),
            exclamationLabelImageView.widthAnchor.constraint(equalToConstant: 24),
            
            errorLabelText.leadingAnchor.constraint(equalTo: exclamationLabelImageView.trailingAnchor, constant: 8),
            errorLabelText.trailingAnchor.constraint(equalTo: errorLabelContainer.trailingAnchor),
            errorLabelText.centerYAnchor.constraint(equalTo: errorLabelContainer.centerYAnchor),
            
            errorLabelContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 30)
        ])
        
        // Make the whole container accessible as a single element
        errorLabelContainer.isAccessibilityElement = true
        errorLabelContainer.accessibilityLabel = "Error: We're sorry. We can't show the offer details right now."
        
        contentStackView.addArrangedSubview(errorLabelContainer)
        
        // Details disclosure for good label with text
        let goodLabelTextDetails = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The good `Label` combined with `Text` example uses `Label(\"Error:\", systemImage: \"exclamationmark.circle\").labelStyle(IconOnlyLabelStyle())` to give the icon an accessibility `Label` that is not displayed visually. Additionally `.accessibilityRemoveTraits(.isImage)` must be used on the `Label` icon image so that the accessibility label is spoken to VoiceOver when the `HStack` is combined into a single focusable element using `.accessibilityElement(children: .combine)`.",
            accessibilityHint: "Good Example `Label` combined with `Text`"
        )
        contentStackView.addArrangedSubview(goodLabelTextDetails)
        
        // Bad Examples Header
        let badExamplesHeader = createHeaderLabel(text: "Bad Examples", isGood: false)
        contentStackView.addArrangedSubview(badExamplesHeader)
        
        let badDivider = createDivider(isGood: false)
        contentStackView.addArrangedSubview(badDivider)
        
        // Bad Example Image no .accessibilityLabel
        let badImageHeader = createHeaderLabel(text: "Bad Example `Image` no `.accessibilityLabel`", isSubheader: true)
        contentStackView.addArrangedSubview(badImageHeader)
        
        // Bad image without accessibility label
        let badImage = UIImageView(image: UIImage(named: "get10off"))
        badImage.contentMode = .scaleAspectFit
        badImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        badImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        badImage.isAccessibilityElement = true
        // No accessibility label is set, so VoiceOver will read the image filename
        badImage.accessibilityIdentifier = "badImage"
        
        // Center the image
        let badImageContainer = UIView()
        badImageContainer.addSubview(badImage)
        badImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            badImage.centerXAnchor.constraint(equalTo: badImageContainer.centerXAnchor),
            badImage.topAnchor.constraint(equalTo: badImageContainer.topAnchor),
            badImage.bottomAnchor.constraint(equalTo: badImageContainer.bottomAnchor)
        ])
        contentStackView.addArrangedSubview(badImageContainer)
        
        // Newsletter text repeated
        let newsletterTextRepeated = createLabel(text: "Sign up for our newsletter.")
        contentStackView.addArrangedSubview(newsletterTextRepeated)
        
        // Details disclosure for bad image
        let badImageDetails = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The bad informative image example uses no `.accessibilityLabel` for the image causing VoiceOver to read the image filename* which is not meaningful. *Disable VoiceOver Text Recognition",
            accessibilityHint: "Bad Example `Image` no `.accessibilityLabel`"
        )
        contentStackView.addArrangedSubview(badImageDetails)
        
        // Bad Example systemImage: no Label text HStack not combined
        let badSystemImageHeader = createHeaderLabel(text: "Bad Example `systemImage:` no `Label` text `HStack` not combined", isSubheader: true)
        contentStackView.addArrangedSubview(badSystemImageHeader)
        
        // Bad Hello World with globe
        let badHelloWorldContainer = UIView()
        let badHelloLabel = createLabel(text: "Hello,")
        let badGlobeImageView = UIImageView(image: UIImage(systemName: "globe"))
        badGlobeImageView.tintColor = .label
        badGlobeImageView.contentMode = .scaleAspectFit
        badGlobeImageView.isAccessibilityElement = true
        badGlobeImageView.accessibilityLabel = "globe"
        let badExclamationLabel = createLabel(text: "!")
        
        badHelloWorldContainer.addSubview(badHelloLabel)
        badHelloWorldContainer.addSubview(badGlobeImageView)
        badHelloWorldContainer.addSubview(badExclamationLabel)
        
        badHelloLabel.translatesAutoresizingMaskIntoConstraints = false
        badGlobeImageView.translatesAutoresizingMaskIntoConstraints = false
        badExclamationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            badHelloLabel.leadingAnchor.constraint(equalTo: badHelloWorldContainer.leadingAnchor),
            badHelloLabel.centerYAnchor.constraint(equalTo: badHelloWorldContainer.centerYAnchor),
            
            badGlobeImageView.leadingAnchor.constraint(equalTo: badHelloLabel.trailingAnchor, constant: 4),
            badGlobeImageView.centerYAnchor.constraint(equalTo: badHelloWorldContainer.centerYAnchor),
            badGlobeImageView.heightAnchor.constraint(equalToConstant: 24),
            badGlobeImageView.widthAnchor.constraint(equalToConstant: 24),
            
            badExclamationLabel.leadingAnchor.constraint(equalTo: badGlobeImageView.trailingAnchor, constant: 4),
            badExclamationLabel.centerYAnchor.constraint(equalTo: badHelloWorldContainer.centerYAnchor),
            
            badHelloWorldContainer.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        // Each element is individually focusable with VoiceOver - that's the bad practice
        contentStackView.addArrangedSubview(badHelloWorldContainer)
        
        // Details disclosure for bad system image
        let badSystemImageDetails = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The bad informative icon image example uses no `Label` text to give the informative icon an accessibility label causing VoiceOver to read the image as \"Globe, Image\". VoiceOver focuses on each individual part of the line of text because the `HStack` is not combined into one focusable element.",
            accessibilityHint: "Bad Example `systemImage:` no `Label` text `HStack` not combined"
        )
        contentStackView.addArrangedSubview(badSystemImageDetails)
        
        // Bad Example Image combined with Text
        let badImageTextHeader = createHeaderLabel(text: "Bad Example `Image` combined with `Text`", isSubheader: true)
        contentStackView.addArrangedSubview(badImageTextHeader)
        
        // Bad error message with exclamation circle
        let badErrorContainer = UIView()
        let badExclamationImageView = UIImageView(image: UIImage(systemName: "exclamationmark.circle"))
        badExclamationImageView.tintColor = darkRed
        badExclamationImageView.contentMode = .scaleAspectFit
        badExclamationImageView.isAccessibilityElement = true
        // No accessibility label
        
        let badErrorLabel = createLabel(text: "We're sorry. We can't show the offer details right now.")
        errorLabel.font = UIFont.boldSystemFont(ofSize: 16) // 16 is typically close to callout size
        badErrorLabel.textColor = darkRed
        
        badErrorContainer.addSubview(badExclamationImageView)
        badErrorContainer.addSubview(badErrorLabel)
        
        badExclamationImageView.translatesAutoresizingMaskIntoConstraints = false
        badErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            badExclamationImageView.leadingAnchor.constraint(equalTo: badErrorContainer.leadingAnchor),
            badExclamationImageView.centerYAnchor.constraint(equalTo: badErrorContainer.centerYAnchor),
            badExclamationImageView.heightAnchor.constraint(equalToConstant: 24),
            badExclamationImageView.widthAnchor.constraint(equalToConstant: 24),
            
            badErrorLabel.leadingAnchor.constraint(equalTo: badExclamationImageView.trailingAnchor, constant: 8),
            badErrorLabel.trailingAnchor.constraint(equalTo: badErrorContainer.trailingAnchor),
            badErrorLabel.centerYAnchor.constraint(equalTo: badErrorContainer.centerYAnchor),
            
            badErrorContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 30)
        ])
        
        // Elements are individually focusable - that's the bad practice
        contentStackView.addArrangedSubview(badErrorContainer)
        
        // Details disclosure for bad image with text
        let badImageTextDetails = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The bad `Image` combined with `Text` example uses `Image(systemName: \"exclamationmark.circle\")` with no accessibility label to give the error icon alt text. `.accessibilityElement(children: .combine)` is not used on the `HStack` to combine the image and text into a single focusable element with VoiceOver.",
            accessibilityHint: "Bad Example `Image` combined with `Text`"
        )
        contentStackView.addArrangedSubview(badImageTextDetails)
        
        // Bad Example Label combined with Text
        let badLabelTextHeader = createHeaderLabel(text: "Bad Example `Label` combined with `Text`", isSubheader: true)
        contentStackView.addArrangedSubview(badLabelTextHeader)
        
        // Bad Label with Text
        let badLabelContainer = UIView()
        let badLabelImageView = UIImageView(image: UIImage(systemName: "exclamationmark.circle"))
        badLabelImageView.tintColor = darkRed
        badLabelImageView.contentMode = .scaleAspectFit
        badLabelImageView.isAccessibilityElement = true
        // No accessibility label
        
        let badLabelText = createLabel(text: "We're sorry. We can't show the offer details right now.")
        errorLabel.font = UIFont.boldSystemFont(ofSize: 16) // 16 is typically close to callout size
        badLabelText.textColor = darkRed
        
        badLabelContainer.addSubview(badLabelImageView)
        badLabelContainer.addSubview(badLabelText)
        
        badLabelImageView.translatesAutoresizingMaskIntoConstraints = false
        badLabelText.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            badLabelImageView.leadingAnchor.constraint(equalTo: badLabelContainer.leadingAnchor),
            badLabelImageView.centerYAnchor.constraint(equalTo: badLabelContainer.centerYAnchor),
            badLabelImageView.heightAnchor.constraint(equalToConstant: 24),
            badLabelImageView.widthAnchor.constraint(equalToConstant: 24),
            
            badLabelText.leadingAnchor.constraint(equalTo: badLabelImageView.trailingAnchor, constant: 8),
            badLabelText.trailingAnchor.constraint(equalTo: badLabelContainer.trailingAnchor),
            badLabelText.centerYAnchor.constraint(equalTo: badLabelContainer.centerYAnchor),
            
            badLabelContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 30)
        ])
        
        // Elements are individually focusable - that's the bad practice
        contentStackView.addArrangedSubview(badLabelContainer)
        
        // Details disclosure for bad label with text
        let badLabelTextDetails = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The bad `Label` combined with `Text` example uses `Label(\"\", systemImage: \"exclamationmark.circle\").labelStyle(IconOnlyLabelStyle())` which does not give the icon an accessibility `Label` that is not displayed visually. The `HStack` is not combined into a single focusable element using `.accessibilityElement(children: .combine)` and `.accessibilityRemoveTraits(.isImage)` is not used on the `Label` icon image so that the accessibility label is spoken to VoiceOver when combined with the text.",
            accessibilityHint: "Bad Example `Label` combined with `Text`"
        )
        contentStackView.addArrangedSubview(badLabelTextDetails)
    }
    
    // MARK: - Helper Methods
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        return label
    }
    
    private func createTextViewWithSelectableText(text: String) -> UITextView {
        let textView = UITextView()
        textView.text = text
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        textView.backgroundColor = .clear
        
        // Calculate height based on content
        let fixedWidth = contentStackView.frame.width
        let size = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        
        return textView
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
        
        let detailsTextView = UITextView()
        detailsTextView.text = detailsText
        detailsTextView.isEditable = false
        detailsTextView.isScrollEnabled = false
        detailsTextView.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        detailsTextView.textContainer.lineFragmentPadding = 0
        detailsTextView.textContainerInset = .zero
        detailsTextView.backgroundColor = .clear
        detailsTextView.isHidden = true
        detailsTextView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(disclosureButton)
        containerView.addSubview(detailsTextView)
        
        NSLayoutConstraint.activate([
            disclosureButton.topAnchor.constraint(equalTo: containerView.topAnchor),
            disclosureButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            disclosureButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            detailsTextView.topAnchor.constraint(equalTo: disclosureButton.bottomAnchor, constant: 8),
            detailsTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            detailsTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            detailsTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        disclosureButton.addTarget(self, action: #selector(toggleDisclosure(_:)), for: .touchUpInside)
        
        return containerView
    }
    
    // MARK: - Actions
    
    @objc private func openDocumentation() {
        let url = URL(string: "https://github.com/cvs-health/ios-swiftui-accessibility-techniques/blob/main/iOSswiftUIa11yTechniques/Documentation/InformativeImages.md#informative-images")!
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true) {
            // Set focus back to the button when Safari is dismissed
            UIAccessibility.post(notification: .screenChanged, argument: self.documentationButton)
        }
    }
    
    @objc private func toggleDisclosure(_ sender: UIButton) {
        if let containerView = sender.superview,
           let detailsTextView = containerView.subviews.compactMap({ $0 as? UITextView }).first {
            
            detailsTextView.isHidden.toggle()
            
            if detailsTextView.isHidden {
                sender.setImage(UIImage(systemName: "chevron.right"), for: .normal)
                sender.tag = 0
            } else {
                sender.setImage(UIImage(systemName: "chevron.down"), for: .normal)
                sender.tag = 1
            }
        }
    }
    
    // MARK: - Theme Handling
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            updateColorScheme()
        }
    }
    
    private func updateColorScheme() {
        // Update colors based on current interface style if needed
    }
}

// MARK: - WebView for Documentation
class WebViewRepresentableUIViewController: UIViewController {
    private let webView = WKWebView()
    private let url: URL
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        webView.load(URLRequest(url: url))
    }
}

// MARK: - SwiftUI Wrapper
struct InformativeView: View {
    var body: some View {
        InformativeViewControllerRepresentable()
            .navigationTitle("Informative Images")
    }
}

// MARK: - SwiftUI Wrapper for WebView
struct InformativeViewRepresentable: UIViewControllerRepresentable {
    let url: String
    
    func makeUIViewController(context: Context) -> WebViewRepresentableUIViewController {
        return WebViewRepresentableUIViewController(url: URL(string: url)!)
    }
    
    func updateUIViewController(_ uiViewController: WebViewRepresentableUIViewController, context: Context) {
        // Update the view controller if needed
    }
}

struct InformativeViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> InformativeViewController {
        return InformativeViewController()
    }
    
    func updateUIViewController(_ uiViewController: InformativeViewController, context: Context) {
        // Update the view controller if needed
    }
}

struct InformativeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InformativeView()
        }
    }
}
