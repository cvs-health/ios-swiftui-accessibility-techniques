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

class ButtonsViewController: UIViewController {
    
    private var username: String = "jdoe24"
    private var email: String = "jdoe24@gmail.com"
    private var username2: String = ""
    private var password2: String = ""
    private let darkGreen = UIColor(red: 0/255, green: 102/255, blue: 0/255, alpha: 1.0)
    private let darkRed = UIColor(red: 220/255, green: 20/255, blue: 60/255, alpha: 1.0)
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        title = "Buttons"
        view.backgroundColor = .systemBackground
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
        
        setupContent()
    }
    
    private func setupContent() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        // Introduction text
        let introLabel = UILabel()
        introLabel.text = "Buttons must have meaningful label text or `.accessibilityLabel`. Button states must be conveyed to VoiceOver users. Use a unique and specific `.accessibilityLabel` if the visible button label text does not describe its specific function. Use `.disabled(true)` to set the disabled state of a button."
        introLabel.numberOfLines = 0
        stackView.addArrangedSubview(introLabel)
        
        // Good Examples Header
        let goodExamplesHeader = createHeaderLabel(text: "Good Examples", isGood: true)
        stackView.addArrangedSubview(goodExamplesHeader)
        
        // Good Examples Divider
        let goodDivider = createDivider(isGood: true)
        stackView.addArrangedSubview(goodDivider)
        
        // Good Example Unique `.accessibilityLabel` Header
        let goodUniqueHeader = createSubheaderLabel(text: "Good Example Unique `.accessibilityLabel`")
        stackView.addArrangedSubview(goodUniqueHeader)
        
        // Username row
        let usernameRow = createTextFieldButtonRow(labelText: "Username", textFieldValue: username, buttonText: "Edit", accessibilityLabel: "Edit Username", identifier: "edit1good")
        stackView.addArrangedSubview(usernameRow)
        
        // Email row
        let emailRow = createTextFieldButtonRow(labelText: "Email", textFieldValue: email, buttonText: "Edit", accessibilityLabel: "Edit Email", identifier: "edit2good")
        stackView.addArrangedSubview(emailRow)
        
        // Good Example Unique Disclosure Group
        let uniqueDisclosure = createDisclosureView(
            headerText: "Details",
            contentText: "The good button example with unique `.accessibilityLabel` uses `.accessibilityLabel(\"Edit Username\")` and `.accessibilityLabel(\"Edit Email\")` to give each Edit button a unique and specific accessibility label for VoiceOver users.",
            hint: "Good Example Unique .accessibilityLabel"
        )
        stackView.addArrangedSubview(uniqueDisclosure)
        
        // Good Example Disabled Button Header
        let goodDisabledHeader = createSubheaderLabel(text: "Good Example Disabled Button")
        stackView.addArrangedSubview(goodDisabledHeader)
        
        // Username field for disabled example
        let usernameLabel = UILabel()
        usernameLabel.text = "Username"
        stackView.addArrangedSubview(usernameLabel)
        
        let usernameField = UITextField()
        usernameField.borderStyle = .roundedRect
        usernameField.text = username2
        usernameField.accessibilityLabel = "Username"
        usernameField.textContentType = .username
        usernameField.autocorrectionType = .no
        usernameField.keyboardType = .asciiCapable
        stackView.addArrangedSubview(usernameField)
        
        // Password field for disabled example
        let passwordLabel = UILabel()
        passwordLabel.text = "Password"
        stackView.addArrangedSubview(passwordLabel)
        
        let passwordField = UITextField()
        passwordField.borderStyle = .roundedRect
        passwordField.text = password2
        passwordField.accessibilityLabel = "Password"
        passwordField.textContentType = .password
        stackView.addArrangedSubview(passwordField)
        
        // Disabled login button
        let loginButton = UIButton(type: .system)
        loginButton.setTitle("Log In", for: .normal)
        loginButton.contentHorizontalAlignment = .left
        loginButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        loginButton.isEnabled = false
        loginButton.accessibilityIdentifier = "loginGood"
        stackView.addArrangedSubview(loginButton)
        
        // Good Example Disabled Button Disclosure Group
        let disabledDisclosure = createDisclosureView(
            headerText: "Details",
            contentText: "The good disabled button example uses `.disabled(true)` to set the disabled state of the Log In button. VoiceOver users will hear the disabled (dimmed) state. Full Keyboard Access users will not be able to move focus to the good disabled button example which is the expected behavior for disabled buttons.",
            hint: "Good Example Disabled Button"
        )
        stackView.addArrangedSubview(disabledDisclosure)
        
        // Bad Examples Header
        let badExamplesHeader = createHeaderLabel(text: "Bad Examples", isGood: false)
        stackView.addArrangedSubview(badExamplesHeader)
        
        // Bad Examples Divider
        let badDivider = createDivider(isGood: false)
        stackView.addArrangedSubview(badDivider)
        
        // Bad Example Generic Labels Header
        let badGenericHeader = createSubheaderLabel(text: "Bad Example Generic Labels")
        stackView.addArrangedSubview(badGenericHeader)
        
        // Bad Username row
        let badUsernameRow = createTextFieldButtonRow(labelText: "Username", textFieldValue: username, buttonText: "Edit", accessibilityLabel: nil, identifier: "edit1bad")
        stackView.addArrangedSubview(badUsernameRow)
        
        // Bad Email row
        let badEmailRow = createTextFieldButtonRow(labelText: "Email", textFieldValue: email, buttonText: "Edit", accessibilityLabel: "Edit Button", identifier: "edit2bad")
        stackView.addArrangedSubview(badEmailRow)
        
        // Bad Example Generic Labels Disclosure Group
        let badGenericDisclosure = createDisclosureView(
            headerText: "Details",
            contentText: "The bad generic button labels example uses the same label text \"Edit\" for both buttons without providing a unique and specific `.accessibilityLabel` for VoiceOver users. The second bad Edit button incorrectly includes the role \"Button\" inside the `.accessibilityLabel`.",
            hint: "Bad Example Generic Labels"
        )
        stackView.addArrangedSubview(badGenericDisclosure)
        
        // Bad Example Disabled Button Header
        let badDisabledHeader = createSubheaderLabel(text: "Bad Example Disabled Button")
        stackView.addArrangedSubview(badDisabledHeader)
        
        // Username field for bad disabled example
        let badUsernameLabel = UILabel()
        badUsernameLabel.text = "Username"
        stackView.addArrangedSubview(badUsernameLabel)
        
        let badUsernameField = UITextField()
        badUsernameField.borderStyle = .roundedRect
        badUsernameField.text = username2
        badUsernameField.accessibilityLabel = "Username"
        stackView.addArrangedSubview(badUsernameField)
        
        // Password field for bad disabled example
        let badPasswordLabel = UILabel()
        badPasswordLabel.text = "Password"
        stackView.addArrangedSubview(badPasswordLabel)
        
        let badPasswordField = UITextField()
        badPasswordField.borderStyle = .roundedRect
        badPasswordField.text = username2
        badPasswordField.accessibilityLabel = "Password"
        stackView.addArrangedSubview(badPasswordField)
        
        // Bad login button
        let badLoginButton = UIButton(type: .system)
        badLoginButton.setTitle("Log In", for: .normal)
        badLoginButton.contentHorizontalAlignment = .left
        badLoginButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        badLoginButton.tintColor = .gray
        badLoginButton.accessibilityIdentifier = "loginBad"
        stackView.addArrangedSubview(badLoginButton)
        
        // Bad Example Disabled Button Disclosure Group
        let badDisabledDisclosure = createDisclosureView(
            headerText: "Details",
            contentText: "The bad disabled button example uses `.tint(.gray)` to visually convey that the Log In button is disabled but VoiceOver will not speak a disabled state. Full Keyboard Access users will be able to move focus to the bad disabled button example which is not the expected behavior for disabled buttons.",
            hint: "Bad Example Disabled Button"
        )
        stackView.addArrangedSubview(badDisabledDisclosure)
    }
    
    private func createHeaderLabel(text: String, isGood: Bool) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textAlignment = .left
        label.textColor = isGood ? (isDarkMode() ? .systemGreen : darkGreen) : (isDarkMode() ? .systemRed : darkRed)
        label.accessibilityTraits = .header
        return label
    }
    
    private func createSubheaderLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textAlignment = .left
        label.accessibilityTraits = .header
        return label
    }
    
    private func createDivider(isGood: Bool) -> UIView {
        let divider = UIView()
        divider.backgroundColor = isGood ? (isDarkMode() ? .systemGreen : darkGreen) : (isDarkMode() ? .systemRed : darkRed)
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 2).isActive = true
        return divider
    }
    
    private func createTextFieldButtonRow(labelText: String, textFieldValue: String, buttonText: String, accessibilityLabel: String?, identifier: String) -> UIView {
        let container = UIView()
        
        let label = UILabel()
        label.text = labelText
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.text = textFieldValue
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let button = UIButton(type: .system)
        button.setTitle(buttonText, for: .normal)
        button.accessibilityLabel = accessibilityLabel
        button.accessibilityIdentifier = identifier
        button.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(label)
        container.addSubview(textField)
        container.addSubview(button)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.widthAnchor.constraint(equalToConstant: 80),
            
            textField.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8),
            textField.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            textField.topAnchor.constraint(equalTo: container.topAnchor),
            textField.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            button.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 8),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            button.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    private func createDisclosureView(headerText: String, contentText: String, hint: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let button = UIButton(type: .system)
        button.setTitle("▶ \(headerText)", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.contentHorizontalAlignment = .left
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityHint = hint
        
        let contentLabel = UILabel()
        contentLabel.text = contentText
        contentLabel.numberOfLines = 0
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.isHidden = true
        
        container.addSubview(button)
        container.addSubview(contentLabel)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            contentLabel.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            contentLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
        ])
        
        button.addTarget(self, action: #selector(toggleDisclosure(_:)), for: .touchUpInside)
        button.tag = container.hashValue
        
        return container
    }
    
    @objc private func toggleDisclosure(_ sender: UIButton) {
        if let container = sender.superview {
            for subview in container.subviews {
                if let label = subview as? UILabel {
                    label.isHidden = !label.isHidden
                    sender.setTitle(label.isHidden ? "▶ Details" : "▼ Details", for: .normal)
                }
            }
        }
    }
    
    private func isDarkMode() -> Bool {
        return self.traitCollection.userInterfaceStyle == .dark
    }
}
