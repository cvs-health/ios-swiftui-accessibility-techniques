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

import SwiftUI
 
struct PickersView: View {
    @State private var selectedCategory = "Mexican"

    
    
    @State private var date = Date()
    @State private var dateStart = Date()
    @State private var dateEnd = Date()
    @State private var time = Date()
    let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: 2021, month: 1, day: 1)
        let endComponents = DateComponents(year: 2021, month: 12, day: 31, hour: 23, minute: 59, second: 59)
        return calendar.date(from:startComponents)!
            ...
            calendar.date(from:endComponents)!
    }()
    
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Pickers are used to select dates and times. Pickers without the `.graphical` or `.wheel` style need an `.accessibilityLabel` set to match their visible label text. Pickers with the `.graphical` or `.wheel` style need visible `DatePicker(\"Label\")` text for each picker so it is spoken to VoiceOver as the accessibility label.")
                    .padding(.bottom)
                Text("Good Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                VStack {
                    Text("Food Category: \(selectedCategory)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Picker("Food Category",
                         selection: $selectedCategory) {
                        Text("Italian")
                            .tag("Italian")
                        Text("Chinese")
                            .tag("Chinese")
                        Text("Indian")
                            .tag("Indian")
                        Text("Mexican")
                            .tag("Mexican")
                        Text("American")
                            .tag("American")
                    }
                         .frame(maxWidth: .infinity, alignment: .leading)
                }
                Text("Good Example 1")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                DatePicker(
                        "Start Date",
                        selection: $dateStart,
                        displayedComponents: [.date]
                    )
                .accessibilityLabel("Start Date")
                .accessibilityIdentifier("startDateGood")
                DatePicker(
                        "End Date",
                        selection: $dateEnd,
                        displayedComponents: [.date]
                    )
                .accessibilityLabel("End Date")
                .accessibilityIdentifier("endDateGood")
                DatePicker("Scheduled Time", selection: $time, displayedComponents: .hourAndMinute)
                    .accessibilityLabel("Scheduled Time")
                    .accessibilityIdentifier("timeGood")
                DatePicker(
                        "Reservation",
                         selection: $date,
                         in: dateRange,
                         displayedComponents: [.date, .hourAndMinute]
                    )
                .accessibilityLabel("Reservation")
                .accessibilityIdentifier("dateTimeGood")
                DisclosureGroup("Details") {
                    Text("The first good Pickers example uses `.accessibilityLabel` on each `DatePicker` that matches the visible label text.")
                }.padding()
                Text("Good Example 2")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Check In").frame(maxWidth: .infinity, alignment: .leading)
                DatePicker(
                        "Check In",
                        selection: $date,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .accessibilityIdentifier("graphicalGood")
                Text("Check Out").frame(maxWidth: .infinity, alignment: .leading)
                DatePicker("Check Out", selection: $time, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .accessibilityIdentifier("wheelGood")
                DisclosureGroup("Details") {
                    Text("The second good Pickers example uses visible `DatePicker(\"Label\")` text for each picker that is spoken to VoiceOver as the accessibility label.")
                }.padding()
                Text("Bad Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                Text("Bad Example 1")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                DatePicker(
                        "Start Date",
                        selection: $dateStart,
                        displayedComponents: [.date]
                    )
                .accessibilityIdentifier("startDateBad")
                DatePicker(
                        "End Date",
                        selection: $dateEnd,
                        displayedComponents: [.date]
                    )
                .accessibilityIdentifier("endDateBad")
                DatePicker("Scheduled Time", selection: $time, displayedComponents: .hourAndMinute)
                    .accessibilityIdentifier("timeBad")
                DatePicker(
                        "Reservation",
                         selection: $date,
                         in: dateRange,
                         displayedComponents: [.date, .hourAndMinute]
                    )
                .accessibilityIdentifier("dateTimeBad")
                DisclosureGroup("Details") {
                    Text("The first bad Pickers example has no `.accessibilityLabel` for each `DatePicker` that matches the visible label text.")
                }.padding()
                Text("Bad Example 2")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Check In").frame(maxWidth: .infinity, alignment: .leading)
                DatePicker(
                        "",
                        selection: $date,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .accessibilityIdentifier("graphicalBad")
                Text("Check Out").frame(maxWidth: .infinity, alignment: .leading)
                DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .accessibilityIdentifier("wheelBad")
                DisclosureGroup("Details") {
                    Text("The second bad Pickers example uses no visible `DatePicker(\"\")` text for each picker so nothing is spoken to VoiceOver as the accessibility label.")
                }.padding()
            }
            .navigationTitle("Pickers")
            .padding()
        }
 
    }
}
 
struct PickersView_Previews: PreviewProvider {
    static var previews: some View {
        PickersView()
    }
}
