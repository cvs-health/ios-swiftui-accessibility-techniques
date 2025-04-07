import UIKit
import SwiftUI

class ProgressIndicatorsViewController: UIViewController {
    
    // Properties
    private var progressIndicatorBadVisible = false
    private var progressIndicatorGoodVisible = false
    private var progress: Float = 0.8
    
    private let darkGreen = UIColor(red: 0/255, green: 102/255, blue: 0/255, alpha: 1.0)
    private let darkRed = UIColor(red: 220/255, green: 20/255, blue: 60/255, alpha: 1.0)
    
    private var scrollView: UIScrollView!
    private var contentStackView: UIStackView!
    private var goodProgressView: UIProgressView?
    private var badProgressView: UIProgressView?
    private var activityIndicatorGood: UIActivityIndicatorView?
    private var activityIndicatorBad: UIActivityIndicatorView?
    private var goodProgressLabel: UILabel?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Progress Indicators"
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Setup ScrollView
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Setup StackView for content
        contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)
        
        // Set constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
        
        // Add content
        setupContentViews()
    }
    
    private func setupContentViews() {
        // Introduction text
        let introLabel = UILabel()
        introLabel.text = "Progress indicators are used to show page loading status or the progress of a task. Create progress indicators with visible `ProgressView(\"Label\")` label text. Post an `AccessibilityNotification.Announcement` speaking the loading indicator text to VoiceOver when displaying page loading indicators."
        introLabel.numberOfLines = 0
        contentStackView.addArrangedSubview(introLabel)
        
        // Good Examples Header
        let goodExamplesHeader = createHeaderLabel(text: "Good Examples", color: darkGreen)
        contentStackView.addArrangedSubview(goodExamplesHeader)
        
        let goodDivider = createDivider(color: darkGreen)
        contentStackView.addArrangedSubview(goodDivider)
        
        // Good Example 1 Header
        let goodExample1Header = createHeaderLabel(text: "Good Example `ProgressView(\"Label\")`, `AccessibilityNotification.Announcement`, and `.foregroundColor` with sufficient contrast", color: .label)
        contentStackView.addArrangedSubview(goodExample1Header)
        
        // Good Example 1 Content
        let goodExample1Container = UIView()
        contentStackView.addArrangedSubview(goodExample1Container)
        
        let goodProgressContainer = UIView()
        goodProgressContainer.translatesAutoresizingMaskIntoConstraints = false
        goodExample1Container.addSubview(goodProgressContainer)
        
        goodProgressLabel = UILabel()
        goodProgressLabel?.text = "Updating your information"
        goodProgressLabel?.translatesAutoresizingMaskIntoConstraints = false
        goodProgressLabel?.isHidden = true
        goodProgressContainer.addSubview(goodProgressLabel!)
        
        activityIndicatorGood = UIActivityIndicatorView(style: .medium)
        activityIndicatorGood?.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorGood?.hidesWhenStopped = true
        goodProgressContainer.addSubview(activityIndicatorGood!)
        
        let saveGoodButton = UIButton(type: .system)
        saveGoodButton.setTitle("Save", for: .normal)
        saveGoodButton.contentHorizontalAlignment = .left
        saveGoodButton.translatesAutoresizingMaskIntoConstraints = false
        saveGoodButton.accessibilityIdentifier = "saveGood"
        saveGoodButton.addTarget(self, action: #selector(showGoodProgressIndicator), for: .touchUpInside)
        goodExample1Container.addSubview(saveGoodButton)
        
        NSLayoutConstraint.activate([
            goodProgressContainer.topAnchor.constraint(equalTo: goodExample1Container.topAnchor),
            goodProgressContainer.leadingAnchor.constraint(equalTo: goodExample1Container.leadingAnchor),
            goodProgressContainer.trailingAnchor.constraint(equalTo: goodExample1Container.trailingAnchor),
            
            activityIndicatorGood!.centerYAnchor.constraint(equalTo: goodProgressContainer.centerYAnchor),
            activityIndicatorGood!.leadingAnchor.constraint(equalTo: goodProgressContainer.leadingAnchor),
            
            goodProgressLabel!.centerYAnchor.constraint(equalTo: goodProgressContainer.centerYAnchor),
            goodProgressLabel!.leadingAnchor.constraint(equalTo: activityIndicatorGood!.trailingAnchor, constant: 8),
            goodProgressLabel!.trailingAnchor.constraint(lessThanOrEqualTo: goodProgressContainer.trailingAnchor),
            
            saveGoodButton.topAnchor.constraint(equalTo: goodProgressContainer.bottomAnchor, constant: 16),
            saveGoodButton.leadingAnchor.constraint(equalTo: goodExample1Container.leadingAnchor),
            saveGoodButton.trailingAnchor.constraint(equalTo: goodExample1Container.trailingAnchor),
            saveGoodButton.bottomAnchor.constraint(equalTo: goodExample1Container.bottomAnchor)
        ])
        
        // Good Example 1 Disclosure Group
        let goodDisclosure1 = createDisclosureGroup(
            title: "Details",
            content: "The first good progress indicator example posts an `AccessibilityNotification.Announcement` that speaks the indicator text \"Updating your information\" to VoiceOver when the progress view displays. The announcement is posted with a 0.1 second delay to make it speak correctly to VoiceOver. The `ProgressView` uses `.foregroundColor(.primary)` to give the spinner label text sufficient contrast.",
            hint: "Good Example `ProgressView(\"Label\")`, `AccessibilityNotification.Announcement`, and `.foregroundColor` with sufficient contrast"
        )
        contentStackView.addArrangedSubview(goodDisclosure1)
        
        // Good Example 2 Header
        let goodExample2Header = createHeaderLabel(text: "Good Example `ProgressView(\"Label\")`", color: .label)
        contentStackView.addArrangedSubview(goodExample2Header)
        
        // Good Example 2 Content
        let goodProgressView2Container = UIView()
        contentStackView.addArrangedSubview(goodProgressView2Container)
        
        let goodProgressLabel2 = UILabel()
        goodProgressLabel2.text = "Downloading Purchase Receipt"
        goodProgressLabel2.translatesAutoresizingMaskIntoConstraints = false
        goodProgressView2Container.addSubview(goodProgressLabel2)
        
        goodProgressView = UIProgressView(progressViewStyle: .default)
        goodProgressView?.progress = 0.2
        goodProgressView?.translatesAutoresizingMaskIntoConstraints = false
        goodProgressView?.accessibilityIdentifier = "progressView2good"
        goodProgressView?.accessibilityLabel = "Downloading Purchase Receipt, 20 percent complete"
        goodProgressView2Container.addSubview(goodProgressView!)
        
        NSLayoutConstraint.activate([
            goodProgressLabel2.topAnchor.constraint(equalTo: goodProgressView2Container.topAnchor, constant: 8),
            goodProgressLabel2.leadingAnchor.constraint(equalTo: goodProgressView2Container.leadingAnchor),
            goodProgressLabel2.trailingAnchor.constraint(equalTo: goodProgressView2Container.trailingAnchor),
            
            goodProgressView!.topAnchor.constraint(equalTo: goodProgressLabel2.bottomAnchor, constant: 8),
            goodProgressView!.leadingAnchor.constraint(equalTo: goodProgressView2Container.leadingAnchor),
            goodProgressView!.trailingAnchor.constraint(equalTo: goodProgressView2Container.trailingAnchor),
            goodProgressView!.bottomAnchor.constraint(equalTo: goodProgressView2Container.bottomAnchor, constant: -8)
        ])
        
        // Good Example 2 Disclosure Group
        let goodDisclosure2 = createDisclosureGroup(
            title: "Details",
            content: "The second good progress indicator example uses visible label text `ProgressView(\"Downloading Purchase Receipt\")`.",
            hint: "Good Example `ProgressView(\"Label\")`"
        )
        contentStackView.addArrangedSubview(goodDisclosure2)
        
        // Bad Examples Header
        let badExamplesHeader = createHeaderLabel(text: "Bad Examples", color: darkRed)
        contentStackView.addArrangedSubview(badExamplesHeader)
        
        let badDivider = createDivider(color: darkRed)
        contentStackView.addArrangedSubview(badDivider)
        
        // Bad Example 1 Header
        let badExample1Header = createHeaderLabel(text: "Bad Example `ProgressView()` no label, no accessibility announcement", color: .label)
        contentStackView.addArrangedSubview(badExample1Header)
        
        // Bad Example 1 Content
        let badExample1Container = UIView()
        contentStackView.addArrangedSubview(badExample1Container)
        
        let badProgressContainer = UIView()
        badProgressContainer.translatesAutoresizingMaskIntoConstraints = false
        badExample1Container.addSubview(badProgressContainer)
        
        activityIndicatorBad = UIActivityIndicatorView(style: .medium)
        activityIndicatorBad?.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorBad?.hidesWhenStopped = true
        badProgressContainer.addSubview(activityIndicatorBad!)
        
        let saveBadButton = UIButton(type: .system)
        saveBadButton.setTitle("Save", for: .normal)
        saveBadButton.contentHorizontalAlignment = .left
        saveBadButton.translatesAutoresizingMaskIntoConstraints = false
        saveBadButton.accessibilityIdentifier = "saveBad"
        saveBadButton.addTarget(self, action: #selector(showBadProgressIndicator), for: .touchUpInside)
        badExample1Container.addSubview(saveBadButton)
        
        NSLayoutConstraint.activate([
            badProgressContainer.topAnchor.constraint(equalTo: badExample1Container.topAnchor),
            badProgressContainer.leadingAnchor.constraint(equalTo: badExample1Container.leadingAnchor),
            badProgressContainer.trailingAnchor.constraint(equalTo: badExample1Container.trailingAnchor),
            
            activityIndicatorBad!.centerYAnchor.constraint(equalTo: badProgressContainer.centerYAnchor),
            activityIndicatorBad!.leadingAnchor.constraint(equalTo: badProgressContainer.leadingAnchor),
            
            saveBadButton.topAnchor.constraint(equalTo: badProgressContainer.bottomAnchor, constant: 16),
            saveBadButton.leadingAnchor.constraint(equalTo: badExample1Container.leadingAnchor),
            saveBadButton.trailingAnchor.constraint(equalTo: badExample1Container.trailingAnchor),
            saveBadButton.bottomAnchor.constraint(equalTo: badExample1Container.bottomAnchor)
        ])
        
        // Bad Example 1 Disclosure Group
        let badDisclosure1 = createDisclosureGroup(
            title: "Details",
            content: "The first bad progress indicator example does not speak an accessibility announcement notification to VoiceOver when the progress view displays. There is no label text for the progress view and no accessibility label for VoiceOver.",
            hint: "Bad Example `ProgressView()` no label, no accessibility announcement"
        )
        contentStackView.addArrangedSubview(badDisclosure1)
        
        // Bad Example 2 Header
        let badExample2Header = createHeaderLabel(text: "Bad Example `ProgressView()` no label text or accessibility label", color: .label)
        contentStackView.addArrangedSubview(badExample2Header)
        
        // Bad Example 2 Content
        let badProgressView2Container = UIView()
        contentStackView.addArrangedSubview(badProgressView2Container)
        
        badProgressView = UIProgressView(progressViewStyle: .default)
        badProgressView?.progress = 0.2
        badProgressView?.translatesAutoresizingMaskIntoConstraints = false
        badProgressView?.accessibilityIdentifier = "progressView2bad"
        badProgressView2Container.addSubview(badProgressView!)
        
        NSLayoutConstraint.activate([
            badProgressView!.topAnchor.constraint(equalTo: badProgressView2Container.topAnchor, constant: 8),
            badProgressView!.leadingAnchor.constraint(equalTo: badProgressView2Container.leadingAnchor),
            badProgressView!.trailingAnchor.constraint(equalTo: badProgressView2Container.trailingAnchor),
            badProgressView!.bottomAnchor.constraint(equalTo: badProgressView2Container.bottomAnchor, constant: -8)
        ])
        
        // Bad Example 2 Disclosure Group
        let badDisclosure2 = createDisclosureGroup(
            title: "Details",
            content: "The second bad progress indicator example has no visible label text and no accessibility label for VoiceOver.",
            hint: "Bad Example `ProgressView()` no label text or accessibility label"
        )
        contentStackView.addArrangedSubview(badDisclosure2)
    }
    
    // MARK: - Helper Methods
    private func createHeaderLabel(text: String, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = color
        label.numberOfLines = 0
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
    
    // MARK: - Actions
    @objc private func showGoodProgressIndicator() {
        progressIndicatorGoodVisible = true
        goodProgressLabel?.isHidden = false
        activityIndicatorGood?.startAnimating()
        
        // Post accessibility announcement with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(notification: .announcement, argument: "Updating your information")
        }
        
        // Hide indicator after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.progressIndicatorGoodVisible = false
            self.goodProgressLabel?.isHidden = true
            self.activityIndicatorGood?.stopAnimating()
        }
    }
    
    @objc private func showBadProgressIndicator() {
        progressIndicatorBadVisible = true
        activityIndicatorBad?.startAnimating()
        
        // Hide indicator after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.progressIndicatorBadVisible = false
            self.activityIndicatorBad?.stopAnimating()
        }
    }
}



// This is the UIViewControllerRepresentable wrapper that bridges UIKit and SwiftUI
struct ProgressIndicatorsUIKitWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ProgressIndicatorsViewController {
        return ProgressIndicatorsViewController()
    }
    
    func updateUIViewController(_ uiViewController: ProgressIndicatorsViewController, context: Context) {
        // Updates from SwiftUI to UIKit (if needed)
    }
}

// This is the SwiftUI view that will be used within your app
struct ProgressIndicatorsView: View {
    var body: some View {
        ProgressIndicatorsUIKitWrapper()
            .navigationBarTitleDisplayMode(.inline)
    }
}

// Preview provider for SwiftUI canvas
struct ProgressIndicatorsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProgressIndicatorsView()
        }
    }
}
