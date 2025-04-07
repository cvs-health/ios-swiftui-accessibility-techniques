import SwiftUI
import UIKit

class PopoversViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    // MARK: - Properties
    private var isShowingPopover = false
    private var isShowingPopoverBad = false
    private var triggerButton: UIButton!
    
    private let darkGreen = UIColor(red: 0/255, green: 102/255, blue: 0/255, alpha: 1.0)
    private let darkRed = UIColor(red: 220/255, green: 20/255, blue: 60/255, alpha: 1.0)
    
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        title = "Popovers"
        view.backgroundColor = .systemBackground
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Setup ScrollView
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Setup Content View inside ScrollView
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Setup ScrollView Constraints
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
        
        // Add content
        setupContent()
    }
    
    private func setupContent() {
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
        
        // Description Text
        let descriptionLabel = createLabel(with: "VoiceOver focus must move to the popover when displayed and back to the trigger button when the popover is closed. Popover title text must be coded as a Heading for VoiceOver users. Use `.popover()` to code a native SwiftUI popover that receives VoiceOver focus when opened. Use `AccessibilityFocusState` to send focus back to the trigger button that opened the popover when the popover is closed.")
        stackView.addArrangedSubview(descriptionLabel)
        
        // Good Example Header
        let goodExampleLabel = createHeaderLabel(with: "Good Example", color: darkGreen)
        stackView.addArrangedSubview(goodExampleLabel)
        
        let goodDivider = createDivider(color: darkGreen)
        stackView.addArrangedSubview(goodDivider)
        
        // Good Example Button
        triggerButton = UIButton(type: .system)
        triggerButton.setTitle("Show License Agreement", for: .normal)
        triggerButton.contentHorizontalAlignment = .left
        triggerButton.addTarget(self, action: #selector(showGoodPopover), for: .touchUpInside)
        triggerButton.isAccessibilityElement = true
        triggerButton.accessibilityLabel = "Show License Agreement"
        stackView.addArrangedSubview(triggerButton)
        
        // Good Example Details
        let goodDisclosureView = createDisclosureGroup(title: "Details", content: "The good alert example uses `.popover()` to create a native SwiftUI popover that receives VoiceOver focus when displayed. Additionally, `AccessibilityFocusState` is used to send focus back to the trigger button that opened the popover when the popover is closed. The popover title is correctly coded as a heading.", hint: "Good Example")
        stackView.addArrangedSubview(goodDisclosureView)
        
        // Bad Example Header
        let badExampleLabel = createHeaderLabel(with: "Bad Example", color: darkRed)
        stackView.addArrangedSubview(badExampleLabel)
        
        let badDivider = createDivider(color: darkRed)
        stackView.addArrangedSubview(badDivider)
        
        // Bad Example Button
        let badButton = UIButton(type: .system)
        badButton.setTitle("Show License Agreement", for: .normal)
        badButton.contentHorizontalAlignment = .left
        badButton.addTarget(self, action: #selector(toggleBadPopover), for: .touchUpInside)
        stackView.addArrangedSubview(badButton)
        
        // Bad popover container view - initially hidden
        let badPopoverView = createBadPopoverView()
        badPopoverView.isHidden = true
        badPopoverView.tag = 100  // For identification
        stackView.addArrangedSubview(badPopoverView)
        
        // Bad Example Details
        let badDisclosureView = createDisclosureGroup(title: "Details", content: "The bad popover example uses a custom view which does not receive VoiceOver focus when displayed and does not return focus when closed. The popover title is not coded as a heading.", hint: "Bad Example")
        stackView.addArrangedSubview(badDisclosureView)
    }
    
    private func createLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        return label
    }
    
    private func createHeaderLabel(with text: String, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = color
        label.accessibilityTraits = .header
        return label
    }
    
    private func createDivider(color: UIColor) -> UIView {
        let divider = UIView()
        divider.backgroundColor = color
        divider.heightAnchor.constraint(equalToConstant: 2).isActive = true
        return divider
    }
    
    private func createDisclosureGroup(title: String, content: String, hint: String) -> UIView {
        let containerView = UIView()
        containerView.accessibilityHint = hint
        
        let button = UIButton(type: .system)
        button.setTitle("\(title) ▼", for: .normal)
        button.contentHorizontalAlignment = .left
        button.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(button)
        
        let contentLabel = UILabel()
        contentLabel.text = content
        contentLabel.numberOfLines = 0
        contentLabel.isHidden = true
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(contentLabel)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: containerView.topAnchor),
            button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            contentLabel.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            contentLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        button.addAction(UIAction { _ in
            contentLabel.isHidden.toggle()
            button.setTitle("\(title) \(contentLabel.isHidden ? "▼" : "▲")", for: .normal)
        }, for: .touchUpInside)
        
        return containerView
    }
    
    private func createBadPopoverView() -> UIView {
        let containerView = UIView()
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
        
        let titleLabel = UILabel()
        titleLabel.text = "License Agreement"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        
        let contentLabel = UILabel()
        contentLabel.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        contentLabel.numberOfLines = 0
        
        let dismissButton = UIButton(type: .system)
        dismissButton.setTitle("Dismiss", for: .normal)
        dismissButton.addTarget(self, action: #selector(toggleBadPopover), for: .touchUpInside)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(contentLabel)
        stackView.addArrangedSubview(dismissButton)
        
        return containerView
    }
    
    // MARK: - Actions
    @objc private func showGoodPopover() {
        // Create popover content
        let popoverVC = UIViewController()
        popoverVC.preferredContentSize = CGSize(width: 300, height: 400)
        popoverVC.view.backgroundColor = .systemBackground
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        popoverVC.view.addSubview(scrollView)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: popoverVC.view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: popoverVC.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: popoverVC.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: popoverVC.view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
        
        // Add popover content
        let titleLabel = UILabel()
        titleLabel.text = "License Agreement"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.accessibilityTraits = .header
        
        let contentLabel = UILabel()
        contentLabel.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        contentLabel.numberOfLines = 0
        
        let dismissButton = UIButton(type: .system)
        dismissButton.setTitle("Dismiss", for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissGoodPopover), for: .touchUpInside)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(contentLabel)
        stackView.addArrangedSubview(dismissButton)
        
        // Set up and present the popover
        popoverVC.modalPresentationStyle = .popover
        popoverVC.popoverPresentationController?.sourceView = triggerButton
        popoverVC.popoverPresentationController?.sourceRect = triggerButton.bounds
        popoverVC.popoverPresentationController?.permittedArrowDirections = .any
        popoverVC.popoverPresentationController?.delegate = self
        
        present(popoverVC, animated: true) {
            UIAccessibility.post(notification: .screenChanged, argument: titleLabel)
        }
        
        isShowingPopover = true
    }
    
    @objc private func dismissGoodPopover() {
        dismiss(animated: true) {
            self.isShowingPopover = false
            // Return accessibility focus to trigger button
            UIAccessibility.post(notification: .screenChanged, argument: self.triggerButton)
        }
    }
    
    @objc private func toggleBadPopover() {
        isShowingPopoverBad.toggle()
        
        if let badPopoverView = contentView.viewWithTag(100) {
            badPopoverView.isHidden = !isShowingPopoverBad
        }
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none // Forces popover to be displayed as a popover even on compact size classes
    }
}

struct UIKitPopoverWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> PopoversViewController {
        return PopoversViewController()
    }
    
    func updateUIViewController(_ uiViewController: PopoversViewController, context: Context) {
        // Updates from SwiftUI to UIKit (if needed)
    }
}

struct PopoversView: View {
    var body: some View {
        UIKitPopoverWrapper()
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct PopoversView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PopoversView()
        }
    }
}
