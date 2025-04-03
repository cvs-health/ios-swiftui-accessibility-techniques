import UIKit

class ButtonsViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    private var username: String = "jdoe24"
    private var email: String = "jdoe24@gmail.com"
    private var username2: String = ""
    private var password2: String = ""
    private let darkGreen = UIColor(red: 0/255, green: 102/255, blue: 0/255, alpha: 1)
    private let darkRed = UIColor(red: 220/255, green: 20/255, blue: 60/255, alpha: 1)
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Buttons"
        
        // Setup scroll view
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        // Introduction text
        let introLabel = createLabel(withText: "Buttons must have meaningful label text or `.accessibilityLabel`. Button states must be conveyed to VoiceOver users. Use a unique and specific `.accessibilityLabel` if the visible button label text does not describe its specific function. Use `.disabled(true)` to set the disabled state of a button.")
        introLabel.numberOfLines = 0
        stackView.addArrangedSubview(introLabel)
        
        // Good Examples Header
        let goodExamplesHeader = createHeader(withText: "Good Examples", color: isDarkMode() ? .systemGreen : darkGreen)
        stackView.addArrangedSubview(goodExamplesHeader)
        
        // Green divider
        let greenDivider = createDivider(color: isDarkMode() ? .systemGreen : darkGreen)
        stackView.addArrangedSubview(greenDivider)
        
        // Good Example Unique Accessibility Label
        let uniqueAccessibilityLabelHeader = createHeader(withText: "Good Example Unique `.accessibilityLabel`", color: .label)
        stackView.addArrangedSubview(uniqueAccessibilityLabelHeader)
        
        // Username row
        let usernameRow = createInputRow(labelText: "Username", textValue: username, buttonText: "Edit", buttonAccessibilityLabel: "Edit Username", identifier: "edit1good")
        stackView.addArrangedSubview(usernameRow)
        
        // Email row
        let emailRow = createInputRow(labelText: "Email", textValue: email, buttonText: "Edit", buttonAccessibilityLabel: "Edit Email", identifier: "edit2good")
        stackView.addArrangedSubview(emailRow)
        
        // Details disclosure for good example
        let goodDetailsButton = createDisclosureButton(withTitle: "Details", detailsText: "The good button example with unique `.accessibilityLabel` uses `.accessibilityLabel(\"Edit Username\")` and `.accessibilityLabel(\"Edit Email\")` to give each Edit button a unique and specific accessibility label for VoiceOver users.", hint: "Good Example Unique .accessibilityLabel")
        stackView.addArrangedSubview(goodDetailsButton)
        
        // Good Example Disabled Button
        let disabledButtonHeader = createHeader(withText: "Good Example Disabled Button", color: .label)
        stackView.addArrangedSubview(disabledButtonHeader)
        
        // Username label and field
        let usernameLabel = createLabel(withText: "Username")
        stackView.addArrangedSubview(usernameLabel)
        
        let usernameField = createTextField(placeholder: "", text: username2)
        usernameField.accessibilityLabel = "Username"
        usernameField.textContentType = .username
        usernameField.autocorrectionType = .no
        usernameField.keyboardType = .asciiCapable
        stackView.addArrangedSubview(usernameField)
        
        // Password label and field
        let passwordLabel = createLabel(withText: "Password")
        stackView.addArrangedSubview(passwordLabel)
        
        let passwordField = createTextField(placeholder: "", text: password2)
        passwordField.accessibilityLabel = "Password"
        passwordField.textContentType = .password
        passwordField.isSecureTextEntry = true
        stackView.addArrangedSubview(passwordField)
        
        // Login button (disabled)
        let loginButton = UIButton(type: .system)
        loginButton.setTitle("Log In", for: .normal)
        loginButton.contentHorizontalAlignment = .left
        loginButton.isEnabled = false
        loginButton.accessibilityIdentifier = "loginGood"
        loginButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        stackView.addArrangedSubview(loginButton)
        
        // Details disclosure for disabled button
        let disabledDetailsButton = createDisclosureButton(withTitle: "Details", detailsText: "The good disabled button example uses `.disabled(true)` to set the disabled state of the Log In button. VoiceOver users will hear the disabled (dimmed) state. Full Keyboard Access users will not be able to move focus to the good disabled button example which is the expected behavior for disabled buttons.", hint: "Good Example Disabled Button")
        stackView.addArrangedSubview(disabledDetailsButton)
        
        // Bad Examples Header
        let badExamplesHeader = createHeader(withText: "Bad Examples", color: isDarkMode() ? .systemRed : darkRed)
        stackView.addArrangedSubview(badExamplesHeader)
        
        // Red divider
        let redDivider = createDivider(color: isDarkMode() ? .systemRed : darkRed)
        stackView.addArrangedSubview(redDivider)
        
        // Bad Example Generic Labels
        let genericLabelsHeader = createHeader(withText: "Bad Example Generic Labels", color: .label)
        stackView.addArrangedSubview(genericLabelsHeader)
        
        // Username row with generic label
        let badUsernameRow = createInputRow(labelText: "Username", textValue: username, buttonText: "Edit", buttonAccessibilityLabel: nil, identifier: "edit1bad")
        stackView.addArrangedSubview(badUsernameRow)
        
        // Email row with generic label
        let badEmailRow = createInputRow(labelText: "Email", textValue: email, buttonText: "Edit", buttonAccessibilityLabel: "Edit Button", identifier: "edit2bad")
        stackView.addArrangedSubview(badEmailRow)
        
        // Details disclosure for bad example
        let badDetailsButton = createDisclosureButton(withTitle: "Details", detailsText: "The bad generic button labels example uses the same label text \"Edit\" for both buttons without providing a unique and specific `.accessibilityLabel` for VoiceOver users. The second bad Edit button incorrectly includes the role \"Button\" inside the `.accessibilityLabel`.", hint: "Bad Example Generic Labels")
        stackView.addArrangedSubview(badDetailsButton)
        
        // Bad Example Disabled Button
        let badDisabledHeader = createHeader(withText: "Bad Example Disabled Button", color: .label)
        stackView.addArrangedSubview(badDisabledHeader)
        
        // Username label and field for bad example
        let badUsernameLabel = createLabel(withText: "Username")
        stackView.addArrangedSubview(badUsernameLabel)
        
        let badUsernameField = createTextField(placeholder: "", text: username2)
        badUsernameField.accessibilityLabel = "Username"
        stackView.addArrangedSubview(badUsernameField)
        
        // Password label and field for bad example
        let badPasswordLabel = createLabel(withText: "Password")
        stackView.addArrangedSubview(badPasswordLabel)
        
        let badPasswordField = createTextField(placeholder: "", text: username2)
        badPasswordField.accessibilityLabel = "Password"
        stackView.addArrangedSubview(badPasswordField)
        
        // Bad Login button (visually disabled but actually enabled)
        let badLoginButton = UIButton(type: .system)
        badLoginButton.setTitle("Log In", for: .normal)
        badLoginButton.contentHorizontalAlignment = .left
        badLoginButton.tintColor = .gray
        badLoginButton.accessibilityIdentifier = "loginBad"
        badLoginButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        stackView.addArrangedSubview(badLoginButton)
        
        // Details disclosure for bad disabled button
        let badDisabledDetailsButton = createDisclosureButton(withTitle: "Details", detailsText: "The bad disabled button example uses `.tint(.gray)` to visually convey that the Log In button is disabled but VoiceOver will not speak a disabled state. Full Keyboard Access users will be able to move focus to the bad disabled button example which is not the expected behavior for disabled buttons.", hint: "Bad Example Disabled Button")
        stackView.addArrangedSubview(badDisabledDetailsButton)
    }
    
    // MARK: - UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Helper Methods
    private func isDarkMode() -> Bool {
        return traitCollection.userInterfaceStyle == .dark
    }
    
    private func createLabel(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createHeader(withText text: String, color: UIColor) -> UILabel {
        let header = UILabel()
        header.text = text
        header.font = UIFont.preferredFont(forTextStyle: .subheadline).bold()
        header.numberOfLines = 0
        header.textColor = color
        header.accessibilityTraits = .header
        header.translatesAutoresizingMaskIntoConstraints = false
        return header
    }
    
    private func createDivider(color: UIColor) -> UIView {
        let divider = UIView()
        divider.backgroundColor = color
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 2).isActive = true
        return divider
    }
    
    private func createTextField(placeholder: String, text: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.text = text
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
    
    private func createInputRow(labelText: String, textValue: String, buttonText: String, buttonAccessibilityLabel: String?, identifier: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = labelText
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let textField = UITextField()
        textField.text = textValue
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.accessibilityLabel = labelText
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let button = UIButton(type: .system)
        button.setTitle(buttonText, for: .normal)
        if let accessibilityLabel = buttonAccessibilityLabel {
            button.accessibilityLabel = accessibilityLabel
        }
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
            textField.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -8),
            
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            button.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            container.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return container
    }
    
    private func createDisclosureButton(withTitle title: String, detailsText: String, hint: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.contentHorizontalAlignment = .left
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.accessibilityHint = hint
        button.tag = container.hash
        button.addTarget(self, action: #selector(toggleDisclosure(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let detailsLabel = UILabel()
        detailsLabel.text = detailsText
        detailsLabel.numberOfLines = 0
        detailsLabel.isHidden = true
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(button)
        container.addSubview(detailsLabel)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: container.topAnchor),
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            detailsLabel.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 8),
            detailsLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            detailsLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            detailsLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        // Store details label in associated object for later access
        objc_setAssociatedObject(button, UnsafeRawPointer(bitPattern: container.hash)!, detailsLabel, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        return container
    }
    
    @objc private func toggleDisclosure(_ sender: UIButton) {
        if let detailsLabel = objc_getAssociatedObject(sender, UnsafeRawPointer(bitPattern: sender.tag)!) as? UILabel {
            let isHidden = detailsLabel.isHidden
            detailsLabel.isHidden = !isHidden
            
            // Update the chevron image
            let imageName = isHidden ? "chevron.down" : "chevron.right"
            sender.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }
}

// MARK: - Helper Extensions
extension UIFont {
    func bold() -> UIFont {
        return UIFont(descriptor: fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
    }
}

// MARK: - UIHostingController for SwiftUI integration
import SwiftUI

// Use this to embed the ButtonsViewController in SwiftUI if needed
struct ButtonsUIKitView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ButtonsViewController {
        return ButtonsViewController()
    }
    
    func updateUIViewController(_ uiViewController: ButtonsViewController, context: Context) {
        // Update the view controller if needed
    }
}
