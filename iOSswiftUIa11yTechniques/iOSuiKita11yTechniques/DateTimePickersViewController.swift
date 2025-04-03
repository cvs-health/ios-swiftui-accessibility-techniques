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
class DateTimePickersViewController: UIViewController {
    
    // MARK: - Properties
    private var date = Date()
    private var dateStart = Date()
    private var dateEnd = Date()
    private var time = Date()
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    private let darkGreen = UIColor(red: 0/255, green: 102/255, blue: 0/255, alpha: 1.0)
    private let darkRed = UIColor(red: 220/255, green: 20/255, blue: 60/255, alpha: 1.0)
    
    private lazy var dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: 2021, month: 1, day: 1)
        let endComponents = DateComponents(year: 2021, month: 12, day: 31, hour: 23, minute: 59, second: 59)
        return calendar.date(from:startComponents)!
            ...
            calendar.date(from:endComponents)!
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Date & Time Pickers"
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
        let introLabel = createLabel(
            text: "Date Pickers are used to select dates and times. Date Pickers without the `.graphical` or `.wheel` style need an `.accessibilityLabel` set to match their visible label text. Date Pickers with the `.graphical` or `.wheel` style need visible `DatePicker(\"Label\")` text for each picker so it is spoken to VoiceOver as the accessibility label. `AccessibilityFocusState` does not work with `DatePicker` to return focus.",
            multiLine: true)
        contentStackView.addArrangedSubview(introLabel)
        
        // Good Examples Header
        let goodHeaderLabel = createHeaderLabel(text: "Good Examples", isGood: true)
        contentStackView.addArrangedSubview(goodHeaderLabel)
        
        let goodDivider = createDivider(isGood: true)
        contentStackView.addArrangedSubview(goodDivider)
        
        // First Date Picker Example
        let basicDatePicker = createDatePicker(
            mode: .date,
            date: date,
            maximumDate: Date.now)
        basicDatePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        let basicDatePickerWithLabel = createLabeledDatePicker(label: "Pick a Date", datePicker: basicDatePicker)
        contentStackView.addArrangedSubview(basicDatePickerWithLabel)
        
        // Good Example Using .accessibilityLabel
        let accessibilityHeaderLabel = createHeaderLabel(text: "Good Example Using `.accessibilityLabel`", isSubheader: true)
        contentStackView.addArrangedSubview(accessibilityHeaderLabel)
        
        // Start Date
        let startDatePicker = createDatePicker(mode: .date, date: dateStart)
        startDatePicker.addTarget(self, action: #selector(startDateChanged(_:)), for: .valueChanged)
        startDatePicker.accessibilityLabel = "Start Date"
        startDatePicker.accessibilityIdentifier = "startDateGood"
        
        let startDatePickerWithLabel = createLabeledDatePicker(label: "Start Date", datePicker: startDatePicker)
        contentStackView.addArrangedSubview(startDatePickerWithLabel)
        
        // End Date
        let endDatePicker = createDatePicker(mode: .date, date: dateEnd)
        endDatePicker.addTarget(self, action: #selector(endDateChanged(_:)), for: .valueChanged)
        endDatePicker.accessibilityLabel = "End Date"
        endDatePicker.accessibilityIdentifier = "endDateGood"
        
        let endDatePickerWithLabel = createLabeledDatePicker(label: "End Date", datePicker: endDatePicker)
        contentStackView.addArrangedSubview(endDatePickerWithLabel)
        
        // Time
        let timePicker = createDatePicker(mode: .time, date: time)
        timePicker.addTarget(self, action: #selector(timeChanged(_:)), for: .valueChanged)
        timePicker.accessibilityLabel = "Scheduled Time"
        timePicker.accessibilityIdentifier = "timeGood"
        
        let timePickerWithLabel = createLabeledDatePicker(label: "Scheduled Time", datePicker: timePicker)
        contentStackView.addArrangedSubview(timePickerWithLabel)
        
        // Reservation
        let reservationPicker = createDatePicker(mode: .dateAndTime, date: date)
        reservationPicker.minimumDate = dateRange.lowerBound
        reservationPicker.maximumDate = dateRange.upperBound
        reservationPicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        reservationPicker.accessibilityLabel = "Reservation"
        reservationPicker.accessibilityIdentifier = "dateTimeGood"
        
        let reservationPickerWithLabel = createLabeledDatePicker(label: "Reservation", datePicker: reservationPicker)
        contentStackView.addArrangedSubview(reservationPickerWithLabel)
        
        // Details disclosure group
        let accessibilityDetailsDisclosure = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The first good Date Pickers example uses `.accessibilityLabel` on each `DatePicker` that matches the visible label text.",
            accessibilityHint: "Good Example Using `.accessibilityLabel"
        )
        contentStackView.addArrangedSubview(accessibilityDetailsDisclosure)
        
        // Good Example Using DatePicker("Label")
        let datePickerLabelHeader = createHeaderLabel(text: "Good Example Using `DatePicker(\"Label\")`", isSubheader: true)
        contentStackView.addArrangedSubview(datePickerLabelHeader)
        
        // Check In Label
        let checkInLabel = createLabel(text: "Check In", multiLine: false)
        checkInLabel.textAlignment = .left
        contentStackView.addArrangedSubview(checkInLabel)
        
        // Graphical Date Picker
        let graphicalDatePicker = UIDatePicker()
        graphicalDatePicker.datePickerMode = .date
        graphicalDatePicker.preferredDatePickerStyle = .inline
        graphicalDatePicker.date = date
        graphicalDatePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        graphicalDatePicker.accessibilityLabel = "Check In"
        graphicalDatePicker.accessibilityIdentifier = "graphicalGood"
        contentStackView.addArrangedSubview(graphicalDatePicker)
        
        // Check Out Label
        let checkOutLabel = createLabel(text: "Check Out", multiLine: false)
        checkOutLabel.textAlignment = .left
        contentStackView.addArrangedSubview(checkOutLabel)
        
        // Wheel Date Picker
        let wheelDatePicker = UIDatePicker()
        wheelDatePicker.datePickerMode = .time
        wheelDatePicker.preferredDatePickerStyle = .wheels
        wheelDatePicker.date = time
        wheelDatePicker.addTarget(self, action: #selector(timeChanged(_:)), for: .valueChanged)
        wheelDatePicker.accessibilityLabel = "Check Out"
        wheelDatePicker.accessibilityIdentifier = "wheelGood"
        contentStackView.addArrangedSubview(wheelDatePicker)
        
        // Details disclosure group for second good example
        let datePickerLabelDetailsDisclosure = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The second good Date Pickers example uses visible `DatePicker(\"Label\")` text for each date picker that is spoken to VoiceOver as the accessibility label.",
            accessibilityHint: "Good Example Using DatePicker(\"Label\")"
        )
        contentStackView.addArrangedSubview(datePickerLabelDetailsDisclosure)
        
        // Bad Examples Header
        let badHeaderLabel = createHeaderLabel(text: "Bad Examples", isGood: false)
        contentStackView.addArrangedSubview(badHeaderLabel)
        
        let badDivider = createDivider(isGood: false)
        contentStackView.addArrangedSubview(badDivider)
        
        // Bad Example No .accessibilityLabel
        let badAccessibilityHeaderLabel = createHeaderLabel(text: "Bad Example No `.accessibilityLabel`", isSubheader: true)
        contentStackView.addArrangedSubview(badAccessibilityHeaderLabel)
        
        // Start Date Bad
        let startDatePickerBad = createDatePicker(mode: .date, date: dateStart)
        startDatePickerBad.addTarget(self, action: #selector(startDateChanged(_:)), for: .valueChanged)
        startDatePickerBad.accessibilityIdentifier = "startDateBad"
        
        let startDatePickerBadWithLabel = createLabeledDatePicker(label: "Start Date", datePicker: startDatePickerBad)
        contentStackView.addArrangedSubview(startDatePickerBadWithLabel)
        
        // End Date Bad
        let endDatePickerBad = createDatePicker(mode: .date, date: dateEnd)
        endDatePickerBad.addTarget(self, action: #selector(endDateChanged(_:)), for: .valueChanged)
        endDatePickerBad.accessibilityIdentifier = "endDateBad"
        
        let endDatePickerBadWithLabel = createLabeledDatePicker(label: "End Date", datePicker: endDatePickerBad)
        contentStackView.addArrangedSubview(endDatePickerBadWithLabel)
        
        // Time Bad
        let timePickerBad = createDatePicker(mode: .time, date: time)
        timePickerBad.addTarget(self, action: #selector(timeChanged(_:)), for: .valueChanged)
        timePickerBad.accessibilityIdentifier = "timeBad"
        
        let timePickerBadWithLabel = createLabeledDatePicker(label: "Scheduled Time", datePicker: timePickerBad)
        contentStackView.addArrangedSubview(timePickerBadWithLabel)
        
        // Reservation Bad
        let reservationPickerBad = createDatePicker(mode: .dateAndTime, date: date)
        reservationPickerBad.minimumDate = dateRange.lowerBound
        reservationPickerBad.maximumDate = dateRange.upperBound
        reservationPickerBad.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        reservationPickerBad.accessibilityIdentifier = "dateTimeBad"
        
        let reservationPickerBadWithLabel = createLabeledDatePicker(label: "Reservation", datePicker: reservationPickerBad)
        contentStackView.addArrangedSubview(reservationPickerBadWithLabel)
        
        // Details disclosure group for first bad example
        let badAccessibilityDetailsDisclosure = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The first bad Date Pickers example has no `.accessibilityLabel` for each `DatePicker` that matches the visible label text.",
            accessibilityHint: "Bad Example No `.accessibilityLabel`"
        )
        contentStackView.addArrangedSubview(badAccessibilityDetailsDisclosure)
        
        // Bad Example No DatePicker("Label")
        let badLabelHeaderLabel = createHeaderLabel(text: "Bad Example No `DatePicker(\"Label\")`", isSubheader: true)
        contentStackView.addArrangedSubview(badLabelHeaderLabel)
        
        // Check In Label Bad
        let checkInLabelBad = createLabel(text: "Check In", multiLine: false)
        checkInLabelBad.textAlignment = .left
        contentStackView.addArrangedSubview(checkInLabelBad)
        
        // Graphical Date Picker Bad
        let graphicalDatePickerBad = UIDatePicker()
        graphicalDatePickerBad.datePickerMode = .date
        graphicalDatePickerBad.preferredDatePickerStyle = .inline
        graphicalDatePickerBad.date = date
        graphicalDatePickerBad.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        graphicalDatePickerBad.accessibilityIdentifier = "graphicalBad"
        contentStackView.addArrangedSubview(graphicalDatePickerBad)
        
        // Check Out Label Bad
        let checkOutLabelBad = createLabel(text: "Check Out", multiLine: false)
        checkOutLabelBad.textAlignment = .left
        contentStackView.addArrangedSubview(checkOutLabelBad)
        
        // Wheel Date Picker Bad
        let wheelDatePickerBad = UIDatePicker()
        wheelDatePickerBad.datePickerMode = .time
        wheelDatePickerBad.preferredDatePickerStyle = .wheels
        wheelDatePickerBad.date = time
        wheelDatePickerBad.addTarget(self, action: #selector(timeChanged(_:)), for: .valueChanged)
        wheelDatePickerBad.accessibilityIdentifier = "wheelBad"
        contentStackView.addArrangedSubview(wheelDatePickerBad)
        
        // Details disclosure group for second bad example
        let badLabelDetailsDisclosure = createDisclosureGroup(
            headerText: "Details",
            detailsText: "The second bad Date Pickers example uses no visible `DatePicker(\"\")` text for each date picker so nothing is spoken to VoiceOver as the accessibility label.",
            accessibilityHint: "`Bad Example No DatePicker(\"Label\")`"
        )
        contentStackView.addArrangedSubview(badLabelDetailsDisclosure)
    }
    
    // MARK: - Helper Methods
    
    private func createLabel(text: String, multiLine: Bool) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = multiLine ? 0 : 1
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
    
    private func createDatePicker(mode: UIDatePicker.Mode, date: Date, maximumDate: Date? = nil) -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = mode
        datePicker.date = date
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .compact
        }
        
        if let maxDate = maximumDate {
            datePicker.maximumDate = maxDate
        }
        
        return datePicker
    }
    
    private func createLabeledDatePicker(label: String, datePicker: UIDatePicker) -> UIView {
        let containerView = UIView()
        
        let labelView = UILabel()
        labelView.text = label
        labelView.translatesAutoresizingMaskIntoConstraints = false
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(labelView)
        containerView.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            labelView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            labelView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            datePicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            datePicker.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
        
        return containerView
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
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        date = sender.date
    }
    
    @objc private func startDateChanged(_ sender: UIDatePicker) {
        dateStart = sender.date
    }
    
    @objc private func endDateChanged(_ sender: UIDatePicker) {
        dateEnd = sender.date
    }
    
    @objc private func timeChanged(_ sender: UIDatePicker) {
        time = sender.date
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
struct DateTimePickersView: View {
    var body: some View {
        DateTimePickersUIKitView()
            .navigationTitle("Date & Time Pickers")
    }
}

struct DateTimePickersUIKitView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> DateTimePickersViewController {
        return DateTimePickersViewController()
    }
    
    func updateUIViewController(_ uiViewController: DateTimePickersViewController, context: Context) {
        // Update the view controller if needed
    }
}

struct DateTimePickersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DateTimePickersView()
        }
    }
}
