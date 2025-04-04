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
class DecorativeViewController: UIViewController {
    
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
        title = "Decorative Images"
        view.backgroundColor = .systemBackground
        
        setupScrollView()
        setupContentStackView()
        addContentToStackView()
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
    
    private func addContentToStackView() {
        // Introduction Text
        let introText = createLabel(text: "Decorative images are used purely for decoration and convey no meaning to sighted users. Decorative images must be hidden from VoiceOver users. Use `Image(decorative:)` or `.accessibilityHidden(true)` to hide decorative images from VoiceOver.")
        introText.numberOfLines = 0
        contentStackView.addArrangedSubview(introText)
        
        // Good Examples Header
        let goodExamplesHeader = createHeaderLabel(text: "Good Examples", isGood: true)
        contentStackView.addArrangedSubview(goodExamplesHeader)
        
        let goodDivider = createDivider(isGood: true)
        contentStackView.addArrangedSubview(goodDivider)
        
        // Good Example Image(decorative:) header
        let goodImageHeader = createHeaderLabel(text: "Good Example `Image(decorative:)`", isSubheader: true)
        contentStackView.addArrangedSubview(goodImageHeader)
        
        // Good decorative image
        let goodImage = UIImageView(image: UIImage(named: "newspaper"))
        goodImage.contentMode = .scaleAspectFit
        goodImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        goodImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        goodImage.isAccessibilityElement = false // Equivalent to Image(decorative:)
        goodImage.accessibilityIdentifier = "goodImage"
        contentStackView.addArrangedSubview(goodImage)
        
        // Offer text
        let offerText = createLabel(text: "Discover new offers every week and earn extra savings.")
        contentStackView.addArrangedSubview(offerText)
        
        // Shop weekly ad link
        let shopWeeklyAdButton = UIButton(type: .system)
        shopWeeklyAdButton.setTitle("Shop weekly ad", for: .normal)
        let attributedString = NSAttributedString(
            string: "Shop weekly ad",
            attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue]
        )
        shopWeeklyAdButton.setAttributedTitle(attributedString, for: .normal)
        shopWeeklyAdButton.addTarget(self, action: #selector(openWeeklyAd), for: .touchUpInside)
        contentStackView.addArrangedSubview(shopWeeklyAdButton)
        
        // Details disclosure for good image
        let goodImageDetails = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The good decorative image example uses `Image(decorative: \"newspaper\")` which prevents VoiceOver from focusing on the image.",
            accessibilityHint: "Good Example Image(decorative:)"
        )
        contentStackView.addArrangedSubview(goodImageDetails)
        
        // Good Example .accessibilityHidden(true) header
        let goodIconHeader = createHeaderLabel(text: "Good Example `.accessibilityHidden(true)`", isSubheader: true)
        contentStackView.addArrangedSubview(goodIconHeader)
        
        // Good icon image
        let goodIconConfig = UIImage.SymbolConfiguration(scale: .large)
        let goodIcon = UIImageView(image: UIImage(systemName: "globe", withConfiguration: goodIconConfig))
        goodIcon.tintColor = .systemBlue
        goodIcon.contentMode = .scaleAspectFit
        goodIcon.heightAnchor.constraint(equalToConstant: 32).isActive = true
        goodIcon.widthAnchor.constraint(equalToConstant: 32).isActive = true
        goodIcon.isAccessibilityElement = false // Equivalent to .accessibilityHidden(true)
        goodIcon.accessibilityIdentifier = "goodIcon"
        contentStackView.addArrangedSubview(goodIcon)
        
        // Hello world text
        let helloText = createLabel(text: "Hello, world!")
        contentStackView.addArrangedSubview(helloText)
        
        // Details disclosure for good icon
        let goodIconDetails = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The good decorative icon image example uses `.accessibilityHidden(true)` which prevents VoiceOver from focusing on the icon.",
            accessibilityHint: "Good Example `.accessibilityHidden(true)`"
        )
        contentStackView.addArrangedSubview(goodIconDetails)
        
        // Bad Examples Header
        let badExamplesHeader = createHeaderLabel(text: "Bad Examples", isGood: false)
        contentStackView.addArrangedSubview(badExamplesHeader)
        
        let badDivider = createDivider(isGood: false)
        contentStackView.addArrangedSubview(badDivider)
        
        // Bad Example Missing Image(decorative:) header
        let badImageHeader = createHeaderLabel(text: "Bad Example Missing `Image(decorative:)`", isSubheader: true)
        contentStackView.addArrangedSubview(badImageHeader)
        
        // Bad decorative image
        let badImage = UIImageView(image: UIImage(named: "newspaper"))
        badImage.contentMode = .scaleAspectFit
        badImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        badImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        badImage.isAccessibilityElement = true // Bad practice for decorative images
        badImage.accessibilityLabel = "newspaper"
        badImage.accessibilityIdentifier = "badImage"
        contentStackView.addArrangedSubview(badImage)
        
        // Offer text repeated
        let offerTextRepeated = createLabel(text: "Discover new offers every week and earn extra savings.")
        contentStackView.addArrangedSubview(offerTextRepeated)
        
        // Shop weekly ad link repeated
        let shopWeeklyAdButtonRepeated = UIButton(type: .system)
        shopWeeklyAdButtonRepeated.setTitle("Shop weekly ad", for: .normal)
        shopWeeklyAdButtonRepeated.setAttributedTitle(attributedString, for: .normal)
        shopWeeklyAdButtonRepeated.addTarget(self, action: #selector(openWeeklyAd), for: .touchUpInside)
        contentStackView.addArrangedSubview(shopWeeklyAdButtonRepeated)
        
        // Details disclosure for bad image
        let badImageDetails = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The bad decorative image example does not use the `decorative:` parameter which allows VoiceOver to focus on the image and read \"newspaper\" as its accessibility label.",
            accessibilityHint: "Bad Example Missing `Image(decorative:)`"
        )
        contentStackView.addArrangedSubview(badImageDetails)
        
        // Bad Example Missing .accessibilityHidden(true) header
        let badIconHeader = createHeaderLabel(text: "Bad Example Missing `.accessibilityHidden(true)`", isSubheader: true)
        contentStackView.addArrangedSubview(badIconHeader)
        
        // Bad icon image
        let badIconConfig = UIImage.SymbolConfiguration(scale: .large)
        let badIcon = UIImageView(image: UIImage(systemName: "globe", withConfiguration: badIconConfig))
        badIcon.tintColor = .systemBlue
        badIcon.contentMode = .scaleAspectFit
        badIcon.heightAnchor.constraint(equalToConstant: 32).isActive = true
        badIcon.widthAnchor.constraint(equalToConstant: 32).isActive = true
        badIcon.isAccessibilityElement = true // Bad practice for decorative images
        badIcon.accessibilityLabel = "globe"
        badIcon.accessibilityIdentifier = "badIcon"
        contentStackView.addArrangedSubview(badIcon)
        
        // Hello world text repeated
        let helloTextRepeated = createLabel(text: "Hello, world!")
        contentStackView.addArrangedSubview(helloTextRepeated)
        
        // Details disclosure for bad icon
        let badIconDetails = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The bad decorative icon image example does not use `.accessibilityHidden(true)` which allows VoiceOver to focus on the image and read \"globe\" as its accessibility label.",
            accessibilityHint: "Bad Example Missing `.accessibilityHidden(true)`"
        )
        contentStackView.addArrangedSubview(badIconDetails)
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
    
    @objc private func openWeeklyAd() {
        guard let url = URL(string: "https://www.example.com/weeklyad") else { return }
        UIApplication.shared.open(url)
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

// MARK: - SwiftUI Wrapper
struct DecorativeView: View {
    var body: some View {
        DecorativeViewControllerRepresentable()
            .navigationTitle("Decorative Images")
    }
}

struct DecorativeViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> DecorativeViewController {
        return DecorativeViewController()
    }
    
    func updateUIViewController(_ uiViewController: DecorativeViewController, context: Context) {
        // Update the view controller if needed
    }
}

struct DecorativeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DecorativeView()
        }
    }
}
