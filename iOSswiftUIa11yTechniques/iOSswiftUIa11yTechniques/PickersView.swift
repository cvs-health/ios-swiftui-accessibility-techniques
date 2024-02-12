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

import SwiftUI

enum Fruit: String, CaseIterable, Identifiable {
    case apple = "Apple"
    case banana = "Banana"
    case cherry = "Cherry"
    case grape = "Grape"

    var id: Self { self }
}

 
struct PickersView: View {
    @State private var selectedFruit: Fruit = .apple
    
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
                Text("Good Example Default Style")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Fruit: \(selectedFruit.rawValue)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Picker("Fruit", selection: $selectedFruit) {
                    ForEach(Fruit.allCases) { fruit in
                        Text(fruit.rawValue).tag(fruit)
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
                Text("Good Example Wheel Style")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Fruit: \(selectedFruit.rawValue)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Picker("Fruit", selection: $selectedFruit) {
                    ForEach(Fruit.allCases) { fruit in
                        Text(fruit.rawValue).tag(fruit)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                Text("Good Example Segmented Style")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Fruit: \(selectedFruit.rawValue)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Picker("Fruit", selection: $selectedFruit) {
                    ForEach(Fruit.allCases) { fruit in
                        Text(fruit.rawValue).tag(fruit)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                Text("Good Example Menu Style")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Fruit: \(selectedFruit.rawValue)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Picker("Fruit", selection: $selectedFruit) {
                    ForEach(Fruit.allCases) { fruit in
                        Text(fruit.rawValue).tag(fruit)
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
                .pickerStyle(MenuPickerStyle())
                DisclosureGroup("Details") {
                    Text("The first good Pickers example uses `.accessibilityLabel` on each `DatePicker` that matches the visible label text.")
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
