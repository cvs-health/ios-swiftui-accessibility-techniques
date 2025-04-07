import UIKit
import SwiftUI

class SlidersViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    private var speedGood: Double = 50.0
    private var speedBad: Double = 50.0
    private var brightnessGood: Double = 100.0
    private var brightnessBad: Double = 100.0
    
    private let darkGreen = UIColor(red: 0/255, green: 102/255, blue: 0/255, alpha: 1.0)
    private let darkRed = UIColor(red: 220/255, green: 20/255, blue: 60/255, alpha: 1.0)
    
    // UI Components
    private var scrollView: UIScrollView!
    private var contentStackView: UIStackView!
    private var speedGoodTextField: UITextField!
    private var speedGoodSlider: UISlider!
    private var brightnessBadSlider: UISlider!
    private var speedBadSlider: UISlider!
    private var speedBadValueLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sliders"
        view.backgroundColor = .systemBackground
        setupUI()
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Setup ScrollView
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Setup ContentStackView
        contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)
        
        // Setup constraints
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
        
        addContentViews()
    }
    
    private func addContentViews() {
        // Introduction Text
        let introLabel = UILabel()
        introLabel.text = "Sliders are used to adjust a value by sliding the thumb between the minimum and maximum. Use `Slider` to create a native slider control that is adjustable with VoiceOver. Give each `Slider` a unique and meaningful accessibility label and visible label text. Include a `TextField` and `Stepper` to allow users fine control when adjusting the slider value. Provide buttons as single tap alternatives to adjusting the slider with gestures."
        introLabel.numberOfLines = 0
        contentStackView.addArrangedSubview(introLabel)
        
        // Good Examples Header
        let goodExamplesHeader = createHeaderLabel(text: "Good Examples", color: darkGreen)
        contentStackView.addArrangedSubview(goodExamplesHeader)
        
        let goodDivider = createDivider(color: darkGreen)
        contentStackView.addArrangedSubview(goodDivider)
        
        // Good Example 1 Header
        let goodExample1Header = createHeaderLabel(
            text: "Good Example with label text, `.accessibilityLabel`, and single tap gesture alternatives",
            color: .label
        )
        contentStackView.addArrangedSubview(goodExample1Header)
        
        // Brightness Label
        let brightnessLabel = UILabel()
        brightnessLabel.text = "Brightness"
        brightnessLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        contentStackView.addArrangedSubview(brightnessLabel)
        
        // Brightness Slider with Buttons
        let brightnessContainer = UIView()
        contentStackView.addArrangedSubview(brightnessContainer)
        
        let decreaseBrightnessButton = UIButton(type: .system)
        decreaseBrightnessButton.setImage(UIImage(systemName: "sun.min"), for: .normal)
        decreaseBrightnessButton.accessibilityLabel = "Decrease Brightness"
        decreaseBrightnessButton.addTarget(self, action: #selector(decreaseBrightness), for: .touchUpInside)
        decreaseBrightnessButton.translatesAutoresizingMaskIntoConstraints = false
        brightnessContainer.addSubview(decreaseBrightnessButton)
        
        let brightnessGoodSlider = UISlider()
        brightnessGoodSlider.minimumValue = 0
        brightnessGoodSlider.maximumValue = 100
        brightnessGoodSlider.value = Float(brightnessGood)
        brightnessGoodSlider.addTarget(self, action: #selector(brightnessGoodSliderChanged), for: .valueChanged)
        brightnessGoodSlider.accessibilityLabel = "Brightness"
        brightnessGoodSlider.accessibilityIdentifier = "sliderGood1"
        brightnessGoodSlider.translatesAutoresizingMaskIntoConstraints = false
        brightnessContainer.addSubview(brightnessGoodSlider)
        
        let increaseBrightnessButton = UIButton(type: .system)
        increaseBrightnessButton.setImage(UIImage(systemName: "sun.max.fill"), for: .normal)
        increaseBrightnessButton.accessibilityLabel = "Increase Brightness"
        increaseBrightnessButton.addTarget(self, action: #selector(increaseBrightness), for: .touchUpInside)
        increaseBrightnessButton.translatesAutoresizingMaskIntoConstraints = false
        brightnessContainer.addSubview(increaseBrightnessButton)
        
        NSLayoutConstraint.activate([
            decreaseBrightnessButton.leadingAnchor.constraint(equalTo: brightnessContainer.leadingAnchor),
            decreaseBrightnessButton.centerYAnchor.constraint(equalTo: brightnessContainer.centerYAnchor),
            
            brightnessGoodSlider.leadingAnchor.constraint(equalTo: decreaseBrightnessButton.trailingAnchor, constant: 8),
            brightnessGoodSlider.trailingAnchor.constraint(equalTo: increaseBrightnessButton.leadingAnchor, constant: -8),
            brightnessGoodSlider.centerYAnchor.constraint(equalTo: brightnessContainer.centerYAnchor),
            brightnessGoodSlider.topAnchor.constraint(equalTo: brightnessContainer.topAnchor),
            brightnessGoodSlider.bottomAnchor.constraint(equalTo: brightnessContainer.bottomAnchor),
            
            increaseBrightnessButton.trailingAnchor.constraint(equalTo: brightnessContainer.trailingAnchor),
            increaseBrightnessButton.centerYAnchor.constraint(equalTo: brightnessContainer.centerYAnchor)
        ])
        
        // Good Example 1 Details
        let goodDetails1 = createDisclosureGroup(
            title: "Details",
            content: "The first good slider example uses `Text(\"Brightness\")` as the visible label text and `.accessibilityLabel(\"Brightness\")` as the VoiceOver accessibility label. Buttons are used as single tap alternatives to the adjusting the slider with a gesture.",
            hint: "Good Example with label text, `.accessibilityLabel`, and single tap gesture alternatives"
        )
        contentStackView.addArrangedSubview(goodDetails1)
        
        // Good Example 2 Header
        let goodExample2Header = createHeaderLabel(
            text: "Good Example `Slider` internal label text with `Stepper` and `TextField`",
            color: .label
        )
        contentStackView.addArrangedSubview(goodExample2Header)
        
        // Speed Controls Container
        let speedControlsContainer = UIView()
        contentStackView.addArrangedSubview(speedControlsContainer)
        
        // Speed Label
        let speedLabel = UILabel()
        speedLabel.text = "Speed"
        speedLabel.translatesAutoresizingMaskIntoConstraints = false
        speedControlsContainer.addSubview(speedLabel)
        
        // Speed TextField
        speedGoodTextField = UITextField()
        speedGoodTextField.borderStyle = .roundedRect
        speedGoodTextField.text = "\(Int(speedGood))"
        speedGoodTextField.keyboardType = .numberPad
        speedGoodTextField.accessibilityLabel = "Speed"
        speedGoodTextField.delegate = self
        speedGoodTextField.translatesAutoresizingMaskIntoConstraints = false
        speedControlsContainer.addSubview(speedGoodTextField)
        
        // Add Toolbar with Done button to TextField
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [flexSpace, doneButton]
        speedGoodTextField.inputAccessoryView = toolbar
        
        // Stepper
        let stepper = UIStepper()
        stepper.minimumValue = 0
        stepper.maximumValue = 100
        stepper.value = speedGood
        stepper.addTarget(self, action: #selector(speedStepperChanged), for: .valueChanged)
        stepper.accessibilityLabel = "Speed"
        stepper.translatesAutoresizingMaskIntoConstraints = false
        speedControlsContainer.addSubview(stepper)
        
        NSLayoutConstraint.activate([
            speedLabel.leadingAnchor.constraint(equalTo: speedControlsContainer.leadingAnchor),
            speedLabel.centerYAnchor.constraint(equalTo: speedControlsContainer.centerYAnchor),
            
            speedGoodTextField.leadingAnchor.constraint(equalTo: speedLabel.trailingAnchor, constant: 8),
            speedGoodTextField.centerYAnchor.constraint(equalTo: speedControlsContainer.centerYAnchor),
            speedGoodTextField.widthAnchor.constraint(equalToConstant: 60),
            
            stepper.leadingAnchor.constraint(equalTo: speedGoodTextField.trailingAnchor, constant: 8),
            stepper.centerYAnchor.constraint(equalTo: speedControlsContainer.centerYAnchor),
            stepper.trailingAnchor.constraint(lessThanOrEqualTo: speedControlsContainer.trailingAnchor),
            
            speedControlsContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
        
        // Speed Slider
        let sliderContainer = UIView()
        contentStackView.addArrangedSubview(sliderContainer)
        
        let minValueLabel = UILabel()
        minValueLabel.text = "0"
        minValueLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        minValueLabel.translatesAutoresizingMaskIntoConstraints = false
        sliderContainer.addSubview(minValueLabel)
        
        speedGoodSlider = UISlider()
        speedGoodSlider.minimumValue = 0
        speedGoodSlider.maximumValue = 100
        speedGoodSlider.value = Float(speedGood)
        speedGoodSlider.addTarget(self, action: #selector(speedGoodSliderChanged), for: .valueChanged)
        speedGoodSlider.accessibilityLabel = "Speed"
        speedGoodSlider.translatesAutoresizingMaskIntoConstraints = false
        sliderContainer.addSubview(speedGoodSlider)
        
        let maxValueLabel = UILabel()
        maxValueLabel.text = "100"
        maxValueLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        maxValueLabel.translatesAutoresizingMaskIntoConstraints = false
        sliderContainer.addSubview(maxValueLabel)
        
        NSLayoutConstraint.activate([
            minValueLabel.leadingAnchor.constraint(equalTo: sliderContainer.leadingAnchor),
            minValueLabel.centerYAnchor.constraint(equalTo: sliderContainer.centerYAnchor),
            
            speedGoodSlider.leadingAnchor.constraint(equalTo: minValueLabel.trailingAnchor, constant: 8),
            speedGoodSlider.trailingAnchor.constraint(equalTo: maxValueLabel.leadingAnchor, constant: -8),
            speedGoodSlider.centerYAnchor.constraint(equalTo: sliderContainer.centerYAnchor),
            speedGoodSlider.topAnchor.constraint(equalTo: sliderContainer.topAnchor),
            speedGoodSlider.bottomAnchor.constraint(equalTo: sliderContainer.bottomAnchor),
            
            maxValueLabel.trailingAnchor.constraint(equalTo: sliderContainer.trailingAnchor),
            maxValueLabel.centerYAnchor.constraint(equalTo: sliderContainer.centerYAnchor)
        ])
        
        // Good Example 2 Details
        let goodDetails2 = createDisclosureGroup(
            title: "Details",
            content: "The second good slider example uses visible label text as well as minimum and maximum value labels. A `TextField` and `Stepper` are included to allow users to see the exact value and have fine control when adjusting the value. The `Slider` uses internal `Text(\"Speed\")` as the invisible accessibility label. The `TextField` and `Stepper` use `.accessibilityLabel(\"Speed\")` as their VoiceOver labels.",
            hint: "Good Example `Slider` internal label text with `Stepper` and `TextField`"
        )
        contentStackView.addArrangedSubview(goodDetails2)
        
        // Bad Examples Header
        let badExamplesHeader = createHeaderLabel(text: "Bad Examples", color: darkRed)
        contentStackView.addArrangedSubview(badExamplesHeader)
        
        let badDivider = createDivider(color: darkRed)
        contentStackView.addArrangedSubview(badDivider)
        
        // Bad Example 1 Header
        let badExample1Header = createHeaderLabel(
            text: "Bad Example no label text or `.accessibilityLabel` and no single tap gesture alternatives",
            color: .label
        )
        contentStackView.addArrangedSubview(badExample1Header)
        
        // Bad Brightness Slider
        brightnessBadSlider = UISlider()
        brightnessBadSlider.minimumValue = 0
        brightnessBadSlider.maximumValue = 100
        brightnessBadSlider.value = Float(brightnessBad)
        brightnessBadSlider.accessibilityIdentifier = "sliderBad1"
        contentStackView.addArrangedSubview(brightnessBadSlider)
        
        // Bad Example 1 Details
        let badDetails1 = createDisclosureGroup(
            title: "Details",
            content: "The first bad slider example uses no visible label text and no VoiceOver accessibility label. There are no single tap alternatives to adjusting the slider with a gesture.",
            hint: "Bad Example no label text or `.accessibilityLabel` and no single tap gesture alternatives"
        )
        contentStackView.addArrangedSubview(badDetails1)
        
        // Bad Example 2 Header
        let badExample2Header = createHeaderLabel(
            text: "Bad Example no label, no `.accessibilityLabel`, no `TextField`, no `Stepper`",
            color: .label
        )
        contentStackView.addArrangedSubview(badExample2Header)
        
        // Bad Speed Value Label
        speedBadValueLabel = UILabel()
        speedBadValueLabel.text = "\(Int(round(speedBad)))"
        contentStackView.addArrangedSubview(speedBadValueLabel)
        
        // Bad Speed Slider
        let badSliderContainer = UIView()
        contentStackView.addArrangedSubview(badSliderContainer)
        
        let badMinValueLabel = UILabel()
        badMinValueLabel.text = "0"
        badMinValueLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        badMinValueLabel.translatesAutoresizingMaskIntoConstraints = false
        badSliderContainer.addSubview(badMinValueLabel)
        
        speedBadSlider = UISlider()
        speedBadSlider.minimumValue = 0
        speedBadSlider.maximumValue = 100
        speedBadSlider.value = Float(speedBad)
        speedBadSlider.addTarget(self, action: #selector(speedBadSliderChanged), for: .valueChanged)
        speedBadSlider.accessibilityIdentifier = "sliderBad2"
        speedBadSlider.translatesAutoresizingMaskIntoConstraints = false
        badSliderContainer.addSubview(speedBadSlider)
        
        let badMaxValueLabel = UILabel()
        badMaxValueLabel.text = "100"
        badMaxValueLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        badMaxValueLabel.translatesAutoresizingMaskIntoConstraints = false
        badSliderContainer.addSubview(badMaxValueLabel)
        
        NSLayoutConstraint.activate([
            badMinValueLabel.leadingAnchor.constraint(equalTo: badSliderContainer.leadingAnchor),
            badMinValueLabel.centerYAnchor.constraint(equalTo: badSliderContainer.centerYAnchor),
            
            speedBadSlider.leadingAnchor.constraint(equalTo: badMinValueLabel.trailingAnchor, constant: 8),
            speedBadSlider.trailingAnchor.constraint(equalTo: badMaxValueLabel.leadingAnchor, constant: -8),
            speedBadSlider.centerYAnchor.constraint(equalTo: badSliderContainer.centerYAnchor),
            speedBadSlider.topAnchor.constraint(equalTo: badSliderContainer.topAnchor),
            speedBadSlider.bottomAnchor.constraint(equalTo: badSliderContainer.bottomAnchor),
            
            badMaxValueLabel.trailingAnchor.constraint(equalTo: badSliderContainer.trailingAnchor),
            badMaxValueLabel.centerYAnchor.constraint(equalTo: badSliderContainer.centerYAnchor)
        ])
        
        // Bad Example 2 Details
        let badDetails2 = createDisclosureGroup(
            title: "Details",
            content: "The second bad slider example uses no label text and no accessibility label for VoiceOver. Users can see the slider value but their is no `TextField` or `Stepper` included to allow fine control.",
            hint: "Bad Example no label, no `.accessibilityLabel`, no `TextField`, no `Stepper`"
        )
        contentStackView.addArrangedSubview(badDetails2)
    }
    
    // MARK: - Helper UI Functions
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
    
    // MARK: - Actions and Event Handlers
    @objc private func brightnessGoodSliderChanged(_ sender: UISlider) {
        brightnessGood = Double(sender.value)
    }
    
    @objc private func decreaseBrightness() {
        if brightnessGood > 0 {
            brightnessGood -= 10
            updateBrightnessGoodUI()
        }
    }
    
    @objc private func increaseBrightness() {
        if brightnessGood < 100 {
            brightnessGood += 10
            updateBrightnessGoodUI()
        }
    }
    
    private func updateBrightnessGoodUI() {
        for subview in contentStackView.arrangedSubviews {
            if let container = subview as? UIView {
                for view in container.subviews {
                    if let slider = view as? UISlider, slider.accessibilityIdentifier == "sliderGood1" {
                        slider.value = Float(brightnessGood)
                    }
                }
            }
        }
    }
    
    @objc private func speedGoodSliderChanged(_ sender: UISlider) {
        speedGood = Double(sender.value)
        speedGoodTextField.text = "\(Int(round(speedGood)))"
    }
    
    @objc private func speedStepperChanged(_ sender: UIStepper) {
        speedGood = sender.value
        speedGoodSlider.value = Float(speedGood)
        speedGoodTextField.text = "\(Int(round(speedGood)))"
    }
    
    @objc private func speedBadSliderChanged(_ sender: UISlider) {
        speedBad = Double(sender.value)
        speedBadValueLabel.text = "\(Int(round(speedBad)))"
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
        
        // Update values from text field if needed
        if let text = speedGoodTextField.text, let value = Double(text) {
            if value >= 0 && value <= 100 {
                speedGood = value
                speedGoodSlider.value = Float(value)
            } else {
                // Reset to previous value if out of range
                speedGoodTextField.text = "\(Int(round(speedGood)))"
            }
        } else {
            // Reset to previous value if invalid
            speedGoodTextField.text = "\(Int(round(speedGood)))"
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == speedGoodTextField, let text = textField.text, let value = Double(text) {
            if value >= 0 && value <= 100 {
                speedGood = value
                speedGoodSlider.value = Float(value)
            } else {
                // Reset to previous value if out of range
                textField.text = "\(Int(round(speedGood)))"
            }
        }
    }
}

// MARK: - UIViewRepresentable Wrapper
struct UISliderView: UIViewRepresentable {
    // The UIKit view we're wrapping
    typealias UIViewType = UIView
    
    // Properties from SwiftUI to pass to UIKit
    var configuration: ((UIView) -> Void)?
    
    func makeUIView(context: Context) -> UIView {
        // Create a container view to hold our UIKit components
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
        // Apply any configuration needed
        configuration?(containerView)
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Apply any updates when SwiftUI state changes
        configuration?(uiView)
    }
}

// MARK: - View Controller Representable Wrapper
struct SlidersUIKitWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> SlidersViewController {
        return SlidersViewController()
    }
    
    func updateUIViewController(_ uiViewController: SlidersViewController, context: Context) {
        // Updates from SwiftUI to UIKit (if needed)
    }
}

// MARK: - SwiftUI View
struct SlidersView: View {
    var body: some View {
        SlidersUIKitWrapper()
            .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview Provider
struct SlidersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SlidersView()
        }
    }
}
