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

// MARK: - UIKit View Controller
class FunctionalViewController: UIViewController {
    
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    private let darkGreen = UIColor(red: 0/255, green: 102/255, blue: 0/255, alpha: 1.0)
    private let darkRed = UIColor(red: 220/255, green: 20/255, blue: 60/255, alpha: 1.0)
    
    private var isSuperFavorite = false
    private var goodImageButton: UIButton!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Functional Images"
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
        let introText = createLabel(text: "Functional images are actionable images used as buttons or links. Functional images need accessibility labels that describe their function rather than their appearance. Use an `.accessibilityLabel` if the functional image has no visible text.")
        contentStackView.addArrangedSubview(introText)
        
        // Good Example Header
        let goodHeaderLabel = createHeaderLabel(text: "Good Example", isGood: true)
        contentStackView.addArrangedSubview(goodHeaderLabel)
        
        let goodDivider = createDivider(isGood: true)
        contentStackView.addArrangedSubview(goodDivider)
        
        // Good Example `Image` `Button` `.accessibilityLabel`
        let goodExampleHeaderLabel = createHeaderLabel(text: "Good Example `Image` `Button` `.accessibilityLabel`", isSubheader: true)
        contentStackView.addArrangedSubview(goodExampleHeaderLabel)
        
        // Good image button with proper accessibility
        goodImageButton = UIButton(type: .system)
        goodImageButton.setImage(UIImage(systemName: "barcode.viewfinder")?.withRenderingMode(.alwaysOriginal), for: .normal)
        goodImageButton.contentHorizontalAlignment = .center
        goodImageButton.addTarget(self, action: #selector(goodImageButtonTapped), for: .touchUpInside)
        goodImageButton.accessibilityLabel = "Scan barcode"
        goodImageButton.accessibilityIdentifier = "goodImage"
        goodImageButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        goodImageButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
        // Center the button
        let goodButtonContainer = UIView()
        goodButtonContainer.addSubview(goodImageButton)
        goodImageButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            goodImageButton.centerXAnchor.constraint(equalTo: goodButtonContainer.centerXAnchor),
            goodImageButton.topAnchor.constraint(equalTo: goodButtonContainer.topAnchor),
            goodImageButton.bottomAnchor.constraint(equalTo: goodButtonContainer.bottomAnchor)
        ])
        
        contentStackView.addArrangedSubview(goodButtonContainer)
        
        // Details disclosure for good example
        let goodExampleDetails = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The good functional image example uses an image button with `.accessibilityLabel(\"Scan barcode\"))` to give the button a meaningful accessibility label that describes its purpose to VoiceOver users.",
            accessibilityHint: "Good Example `Image` `Button` `.accessibilityLabel`"
        )
        contentStackView.addArrangedSubview(goodExampleDetails)
        
        // iOS 18+ Good Example
        if #available(iOS 18.0, *) {
            let ios18HeaderLabel = createHeaderLabel(
                text: "iOS 18+ Good Example `Image` `Button` `accessibilityLabel(_:isEnabled:)`",
                isSubheader: true
            )
            contentStackView.addArrangedSubview(ios18HeaderLabel)
            
            // Super favorite button
            let superFavoriteButton = UIButton(type: .system)
            superFavoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            superFavoriteButton.addTarget(self, action: #selector(toggleSuperFavorite), for: .touchUpInside)
            superFavoriteButton.accessibilityLabel = "Super Favorite"
            
            // Center the button
            let superFavoriteContainer = UIView()
            superFavoriteContainer.addSubview(superFavoriteButton)
            superFavoriteButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                superFavoriteButton.centerXAnchor.constraint(equalTo: superFavoriteContainer.centerXAnchor),
                superFavoriteButton.topAnchor.constraint(equalTo: superFavoriteContainer.topAnchor),
                superFavoriteButton.bottomAnchor.constraint(equalTo: superFavoriteContainer.bottomAnchor),
                superFavoriteButton.heightAnchor.constraint(equalToConstant: 44),
                superFavoriteButton.widthAnchor.constraint(equalToConstant: 44)
            ])
            
            contentStackView.addArrangedSubview(superFavoriteContainer)
            
            // Details disclosure for iOS 18+ example
            let ios18Details = createDisclosureGroup(
                headerText: "Details",
                detailsText: "The iOS 18+ good example image button uses `accessibilityLabel(_:isEnabled:)` to change the accessibility label to be \"Super Favorite\" when toggled and use the default SF Symbols VoiceOver label of \"Favorite\" when not toggled.",
                accessibilityHint: "iOS 18+ Good Example `Image` `Button` `accessibilityLabel(_:isEnabled:)`"
            )
            contentStackView.addArrangedSubview(ios18Details)
        }
        
        // Bad Examples Header
        let badHeaderLabel = createHeaderLabel(text: "Bad Examples", isGood: false)
        contentStackView.addArrangedSubview(badHeaderLabel)
        
        let badDivider = createDivider(isGood: false)
        contentStackView.addArrangedSubview(badDivider)
        
        // Bad Example `Image` `Button` no `.accessibilityLabel`
        let badExample1HeaderLabel = createHeaderLabel(
            text: "Bad Example `Image` `Button` no `.accessibilityLabel`",
            isSubheader: true
        )
        contentStackView.addArrangedSubview(badExample1HeaderLabel)
        
        // Bad image button without proper accessibility
        let badImageButton1 = UIButton(type: .system)
        badImageButton1.setImage(UIImage(named: "barcode.viewfinder")?.withRenderingMode(.alwaysOriginal), for: .normal)
        badImageButton1.contentHorizontalAlignment = .center
        badImageButton1.addTarget(self, action: #selector(badImageButtonTapped), for: .touchUpInside)
        badImageButton1.accessibilityIdentifier = "badImage1"
        badImageButton1.heightAnchor.constraint(equalToConstant: 44).isActive = true
        badImageButton1.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
        // Center the button
        let badButton1Container = UIView()
        badButton1Container.addSubview(badImageButton1)
        badImageButton1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            badImageButton1.centerXAnchor.constraint(equalTo: badButton1Container.centerXAnchor),
            badImageButton1.topAnchor.constraint(equalTo: badButton1Container.topAnchor),
            badImageButton1.bottomAnchor.constraint(equalTo: badButton1Container.bottomAnchor)
        ])
        
        contentStackView.addArrangedSubview(badButton1Container)
        
        // Details disclosure for bad example 1
        let badExample1Details = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The bad functional image example uses no `.accessibilityLabel` to give the image button a meaningful accessibility label causing VoiceOver to read the image filename \"barcode.viewfinder\" as the name of the button.",
            accessibilityHint: "Bad Example `Image` `Button` no `.accessibilityLabel`"
        )
        contentStackView.addArrangedSubview(badExample1Details)
        
        // Bad Example `Image` `TapGesture()` no `.accessibilityLabel`
        let badExample2HeaderLabel = createHeaderLabel(
            text: "Bad Example `Image` `TapGesture()` no `.accessibilityLabel`",
            isSubheader: true
        )
        contentStackView.addArrangedSubview(badExample2HeaderLabel)
        
        // Bad image with tap gesture (not a proper button)
        let badImageView = UIImageView(image: UIImage(named: "barcode.viewfinder"))
        badImageView.contentMode = .scaleAspectFit
        badImageView.isUserInteractionEnabled = true
        badImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        badImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        badImageView.accessibilityIdentifier = "badImage2"
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(badImageTapped))
        badImageView.addGestureRecognizer(tapGesture)
        
        // Center the image
        let badImage2Container = UIView()
        badImage2Container.addSubview(badImageView)
        badImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            badImageView.centerXAnchor.constraint(equalTo: badImage2Container.centerXAnchor),
            badImageView.topAnchor.constraint(equalTo: badImage2Container.topAnchor),
            badImageView.bottomAnchor.constraint(equalTo: badImage2Container.bottomAnchor)
        ])
        
        contentStackView.addArrangedSubview(badImage2Container)
        
        // Details disclosure for bad example 2
        let badExample2Details = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The second bad functional image example is incorrectly coded as an `Image` element with a `TapGesture` rather than as a `Button` which prevents VoiceOver users from hearing the \"Button\" trait spoken and they won't know the image is an actionable control. There is also no `.accessibilityLabel`.",
            accessibilityHint: "Bad Example `Image` `TapGesture()` no `.accessibilityLabel`"
        )
        contentStackView.addArrangedSubview(badExample2Details)
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
    @objc private func goodImageButtonTapped() {
        showAlert(title: "Button Activated", message: "You activated the button!")
    }
    
    @objc private func badImageButtonTapped() {
        showAlert(title: "Button Activated", message: "You activated the button!")
    }
    
    @objc private func badImageTapped() {
        showAlert(title: "Image Tapped", message: "You tapped the image!")
    }
    
    @objc private func toggleSuperFavorite(_ sender: UIButton) {
        isSuperFavorite.toggle()
        
        if isSuperFavorite {
            sender.setImage(UIImage(systemName: "sparkles"), for: .normal)
        } else {
            sender.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }
        
        // In iOS 18+, we would use accessibilityLabel(_:isEnabled:), but since UIKit doesn't have
        // a direct equivalent, we'll mimic this by setting the appropriate accessibility label
        if isSuperFavorite {
            sender.accessibilityLabel = "Super Favorite"
        } else {
            sender.accessibilityLabel = "Favorite"
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
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // Set focus back to the good button (equivalent to AccessibilityFocusState)
            UIAccessibility.post(notification: .screenChanged, argument: self?.goodImageButton)
        })
        present(alert, animated: true)
    }
}

// MARK: - SwiftUI Wrapper
struct FunctionalView: View {
    var body: some View {
        FunctionalViewControllerRepresentable()
            .navigationTitle("Functional Images")
    }
}

struct FunctionalViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> FunctionalViewController {
        return FunctionalViewController()
    }
    
    func updateUIViewController(_ uiViewController: FunctionalViewController, context: Context) {
        // Update the view controller if needed
    }
}

struct FunctionalView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FunctionalView()
        }
    }
}
