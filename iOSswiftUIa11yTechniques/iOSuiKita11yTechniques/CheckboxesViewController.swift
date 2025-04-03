/*
   Copyright 2024 CVS Health and/or one of its affiliates

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

class CheckboxesViewController: UIViewController {
    
    // MARK: - Properties
    private var isChecked = false
    private var isEmailChecked = false
    private var isPhoneChecked = false
    private var isTextChecked = false
    private var isCheckedBad = false
    private var isEmailCheckedBad = false
    private var isPhoneCheckedBad = false
    private var isTextCheckedBad = false
    
    private let darkGreen = UIColor(red: 0/255, green: 102/255, blue: 0/255, alpha: 1.0)
    private let darkRed = UIColor(red: 220/255, green: 20/255, blue: 60/255, alpha: 1.0)
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateColors()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Checkboxes"
        
        setupScrollView()
        setupContentElements()
        updateColors()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
    
    private func setupContentElements() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        // Introduction text
        let introText = createLabel(text: "SwiftUI has no native checkbox control or accessibility trait for VoiceOver. Code checkboxes as `Toggle` elements with a custom `.toggleStyle`. Use `Toggle(\"Label Text\")` to create label text. Use `.accessibilityValue(isChecked ? \"Checked\" : \"Unchecked\")` to create custom value text for VoiceOver. Checkbox groups need an accessibility label for the group which matches the visible group label text. Use `.accessibilityElement(children: .contain)` and `.accessibilityLabel(\"Group Label\")` on the checkbox group container so that VoiceOver users hear the group label spoken when first moving focus to a checkbox in the group.")
        stackView.addArrangedSubview(introText)
        
        // Good Examples Header
        let goodExamplesHeader = createHeaderLabel(text: "Good Examples", isGood: true)
        stackView.addArrangedSubview(goodExamplesHeader)
        
        let goodDivider = createDivider(isGood: true)
        stackView.addArrangedSubview(goodDivider)
        
        // Good Example Single Checkbox
        let goodSingleHeader = createHeaderLabel(text: "Good Example Single Checkbox", isSubheader: true)
        stackView.addArrangedSubview(goodSingleHeader)
        
        let goodCheckbox = createCheckbox(text: "Accept Terms", isChecked: isChecked)
        goodCheckbox.addTarget(self, action: #selector(goodCheckboxTapped), for: .touchUpInside)
        goodCheckbox.accessibilityIdentifier = "checkboxGood"
        stackView.addArrangedSubview(goodCheckbox)
        
        let goodSingleDetails = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The good single checkbox example uses a native `Toggle` with a custom `.toggleStyle` to look like a square checkbox control. Additionally `.accessibilityValue(isChecked ? \"Checked\" : \"Unchecked\")` is used to create custom value text for VoiceOver. VoiceOver reads the \"Switch button\" trait and \"Checked\" and \"Unchecked\" values.",
            accessibilityHint: "Good Example Single Checkbox"
        )
        stackView.addArrangedSubview(goodSingleDetails)
        
        // Good Example Checkbox Group
        let goodGroupHeader = createHeaderLabel(text: "Good Example Checkbox Group", isSubheader: true)
        stackView.addArrangedSubview(goodGroupHeader)
        
        let groupLabel = createLabel(text: "Preferred contact method(s):")
        stackView.addArrangedSubview(groupLabel)
        
        let checkboxGroupContainer = UIView()
        checkboxGroupContainer.isAccessibilityElement = false
        checkboxGroupContainer.accessibilityElements = []
        checkboxGroupContainer.accessibilityLabel = "Preferred contact method(s):"
        stackView.addArrangedSubview(checkboxGroupContainer)
        
        let groupStack = UIStackView()
        groupStack.axis = .vertical
        groupStack.spacing = 8
        groupStack.translatesAutoresizingMaskIntoConstraints = false
        checkboxGroupContainer.addSubview(groupStack)
        
        NSLayoutConstraint.activate([
            groupStack.topAnchor.constraint(equalTo: checkboxGroupContainer.topAnchor),
            groupStack.leadingAnchor.constraint(equalTo: checkboxGroupContainer.leadingAnchor),
            groupStack.trailingAnchor.constraint(equalTo: checkboxGroupContainer.trailingAnchor),
            groupStack.bottomAnchor.constraint(equalTo: checkboxGroupContainer.bottomAnchor)
        ])
        
        let emailCheckbox = createCheckbox(text: "Email", isChecked: isEmailChecked)
        emailCheckbox.addTarget(self, action: #selector(emailCheckboxTapped), for: .touchUpInside)
        groupStack.addArrangedSubview(emailCheckbox)
        
        let phoneCheckbox = createCheckbox(text: "Phone", isChecked: isPhoneChecked)
        phoneCheckbox.addTarget(self, action: #selector(phoneCheckboxTapped), for: .touchUpInside)
        groupStack.addArrangedSubview(phoneCheckbox)
        
        let textCheckbox = createCheckbox(text: "Text", isChecked: isTextChecked)
        textCheckbox.addTarget(self, action: #selector(textCheckboxTapped), for: .touchUpInside)
        groupStack.addArrangedSubview(textCheckbox)
        
        checkboxGroupContainer.accessibilityElements = [emailCheckbox, phoneCheckbox, textCheckbox]
        
        let goodGroupDetails = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The good checkbox group example uses `.accessibilityElement(children: .contain)` and `.accessibilityLabel(\"Group Label\")` on the checkbox group container so that VoiceOver users hear the group label spoken when first moving focus to a checkbox in the group.",
            accessibilityHint: "Good Example Checkbox Group"
        )
        stackView.addArrangedSubview(goodGroupDetails)
        
        // Bad Examples Header
        let badExamplesHeader = createHeaderLabel(text: "Bad Examples", isGood: false)
        stackView.addArrangedSubview(badExamplesHeader)
        
        let badDivider = createDivider(isGood: false)
        stackView.addArrangedSubview(badDivider)
        
        // Bad Example Single Checkbox
        let badSingleHeader = createHeaderLabel(text: "Bad Example Single Checkbox", isSubheader: true)
        stackView.addArrangedSubview(badSingleHeader)
        
        let badCheckbox = createBadCheckbox(text: "Accept Terms", isChecked: isCheckedBad)
        badCheckbox.accessibilityIdentifier = "checkboxBad"
        badCheckbox.addTarget(self, action: #selector(badCheckboxTapped), for: .touchUpInside)
        stackView.addArrangedSubview(badCheckbox)
        
        let badSingleDetails = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The bad single checkbox example uses a `Button` that changes an `Image` when tapped to look like a square checkbox control. VoiceOver reads a \"Button\" trait and does not read \"Checked\" or \"Unchecked\" values.",
            accessibilityHint: "Bad Example Single Checkbox"
        )
        stackView.addArrangedSubview(badSingleDetails)
        
        // Bad Example Checkbox Group
        let badGroupHeader = createHeaderLabel(text: "Bad Example Checkbox Group", isSubheader: true)
        stackView.addArrangedSubview(badGroupHeader)
        
        let badGroupLabel = createLabel(text: "Preferred contact method(s):")
        stackView.addArrangedSubview(badGroupLabel)
        
        let badGroupStack = UIStackView()
        badGroupStack.axis = .vertical
        badGroupStack.spacing = 8
        stackView.addArrangedSubview(badGroupStack)
        
        let emailBadCheckbox = createCheckbox(text: "Email", isChecked: isEmailCheckedBad)
        emailBadCheckbox.addTarget(self, action: #selector(emailBadCheckboxTapped), for: .touchUpInside)
        badGroupStack.addArrangedSubview(emailBadCheckbox)
        
        let phoneBadCheckbox = createCheckbox(text: "Phone", isChecked: isPhoneCheckedBad)
        phoneBadCheckbox.addTarget(self, action: #selector(phoneBadCheckboxTapped), for: .touchUpInside)
        badGroupStack.addArrangedSubview(phoneBadCheckbox)
        
        let textBadCheckbox = createCheckbox(text: "Text", isChecked: isTextCheckedBad)
        textBadCheckbox.addTarget(self, action: #selector(textBadCheckboxTapped), for: .touchUpInside)
        badGroupStack.addArrangedSubview(textBadCheckbox)
        
        NSLayoutConstraint.activate([
            badGroupStack.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -150)
        ])
        
        let badGroupDetails = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The bad checkbox group example has no group accessibility label on the checkbox group container so VoiceOver users don't hear the group label spoken when first moving focus to a checkbox in the group.",
            accessibilityHint: "Bad Example Checkbox Group"
        )
        stackView.addArrangedSubview(badGroupDetails)
    }
    
    // MARK: - Helper Functions
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.textAlignment = .natural
        return label
    }
    
    private func createHeaderLabel(text: String, isGood: Bool = true, isSubheader: Bool = false) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = isSubheader ? UIFont.systemFont(ofSize: 15, weight: .bold) : UIFont.systemFont(ofSize: 17, weight: .bold)
        
        if !isSubheader {
            label.textColor = isGood ? darkGreen : darkRed
            label.accessibilityTraits.insert(.header)
        } else {
            label.accessibilityTraits.insert(.header)
        }
        
        return label
    }
    
    private func createDivider(isGood: Bool) -> UIView {
        let divider = UIView()
        divider.backgroundColor = isGood ? darkGreen : darkRed
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 2).isActive = true
        return divider
    }
    
    private func createCheckbox(text: String, isChecked: Bool) -> UIButton {
        let button = UIButton(type: .system)
        configureCheckbox(button, withText: text, isChecked: isChecked)
        
        // Set accessibility properties
        button.accessibilityTraits = .button
        button.accessibilityValue = isChecked ? "Checked" : "Unchecked"
        button.accessibilityLabel = text
        
        return button
    }
    
    private func configureCheckbox(_ button: UIButton, withText text: String, isChecked: Bool) {
        let checkboxImage = isChecked ? UIImage(systemName: "checkmark.square") : UIImage(systemName: "square")
        button.setImage(checkboxImage, for: .normal)
        button.setTitle(text, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.contentHorizontalAlignment = .left
        
        // Configure the button's image and text placement
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        // Set a consistent height for the button
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
    }
    
    private func createBadCheckbox(text: String, isChecked: Bool) -> UIButton {
        let button = UIButton(type: .system)
        let checkboxImage = isChecked ? UIImage(systemName: "checkmark.square") : UIImage(systemName: "square")
        button.setImage(checkboxImage, for: .normal)
        button.setTitle(text, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.contentHorizontalAlignment = .left
        
        // Configure the button's image and text placement
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        // Set a consistent height for the button
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
        
        return button
    }
    
    private func createDisclosureGroup(headerText: String, detailsText: String, accessibilityHint: String) -> UIView {
        let containerView = UIView()
        
        let button = UIButton(type: .system)
        button.setTitle(headerText, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.contentHorizontalAlignment = .left
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.tag = 0  // 0 means closed, 1 means open
        button.accessibilityHint = accessibilityHint
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let detailsLabel = UILabel()
        detailsLabel.text = detailsText
        detailsLabel.numberOfLines = 0
        detailsLabel.isHidden = true
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(button)
        containerView.addSubview(detailsLabel)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: containerView.topAnchor),
            button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            detailsLabel.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 8),
            detailsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            detailsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            detailsLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        button.addTarget(self, action: #selector(toggleDisclosure(_:)), for: .touchUpInside)
        
        return containerView
    }
    
    private func updateColors() {
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        
        // Update any UI elements that need color adjustments based on mode
        // For example, you might want to adjust the darkGreen and darkRed colors
        // to be more visible in dark mode
    }
    
    // MARK: - Actions
    @objc private func goodCheckboxTapped(_ sender: UIButton) {
        isChecked.toggle()
        configureCheckbox(sender, withText: "Accept Terms", isChecked: isChecked)
        sender.accessibilityValue = isChecked ? "Checked" : "Unchecked"
    }
    
    @objc private func emailCheckboxTapped(_ sender: UIButton) {
        isEmailChecked.toggle()
        configureCheckbox(sender, withText: "Email", isChecked: isEmailChecked)
        sender.accessibilityValue = isEmailChecked ? "Checked" : "Unchecked"
    }
    
    @objc private func phoneCheckboxTapped(_ sender: UIButton) {
        isPhoneChecked.toggle()
        configureCheckbox(sender, withText: "Phone", isChecked: isPhoneChecked)
        sender.accessibilityValue = isPhoneChecked ? "Checked" : "Unchecked"
    }
    
    @objc private func textCheckboxTapped(_ sender: UIButton) {
        isTextChecked.toggle()
        configureCheckbox(sender, withText: "Text", isChecked: isTextChecked)
        sender.accessibilityValue = isTextChecked ? "Checked" : "Unchecked"
    }
    
    @objc private func badCheckboxTapped(_ sender: UIButton) {
        isCheckedBad.toggle()
        let checkboxImage = isCheckedBad ? UIImage(systemName: "checkmark.square") : UIImage(systemName: "square")
        sender.setImage(checkboxImage, for: .normal)
    }
    
    @objc private func emailBadCheckboxTapped(_ sender: UIButton) {
        isEmailCheckedBad.toggle()
        configureCheckbox(sender, withText: "Email", isChecked: isEmailCheckedBad)
        sender.accessibilityValue = isEmailCheckedBad ? "Checked" : "Unchecked"
    }
    
    @objc private func phoneBadCheckboxTapped(_ sender: UIButton) {
        isPhoneCheckedBad.toggle()
        configureCheckbox(sender, withText: "Phone", isChecked: isPhoneCheckedBad)
        sender.accessibilityValue = isPhoneCheckedBad ? "Checked" : "Unchecked"
    }
    
    @objc private func textBadCheckboxTapped(_ sender: UIButton) {
        isTextCheckedBad.toggle()
        configureCheckbox(sender, withText: "Text", isChecked: isTextCheckedBad)
        sender.accessibilityValue = isTextCheckedBad ? "Checked" : "Unchecked"
    }
    
    @objc private func toggleDisclosure(_ sender: UIButton) {
        // Find the details label in the same container
        if let containerView = sender.superview,
           let detailsLabel = containerView.subviews.first(where: { $0 is UILabel }) as? UILabel {
            
            // Toggle visibility
            detailsLabel.isHidden.toggle()
            
            // Update the button's image
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

// MARK: - UIHostingController for SwiftUI integration
import SwiftUI

// Use this to embed the ButtonsViewController in SwiftUI if needed
struct CheckboxesUIKitView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CheckboxesViewController {
        return CheckboxesViewController()
    }
    
    func updateUIViewController(_ uiViewController: CheckboxesViewController, context: Context) {
        // Update the view controller if needed
    }
}
