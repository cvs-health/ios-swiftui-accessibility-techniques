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
    @State private var selectedFruitDefault: Fruit = .banana
    @State private var selectedFruitWheel: Fruit = .cherry
    @State private var selectedFruitSegmented: Fruit = .grape
    @State private var selectedFruitBad: Fruit = .apple
    @State private var selectedFruitDefaultBad: Fruit = .banana
    @State private var selectedFruitWheelBad: Fruit = .cherry
    @State private var selectedFruitSegmentedBad: Fruit = .grape
    @AccessibilityFocusState private var isTriggerFocused: Bool
    @AccessibilityFocusState private var isFruitFocused: Bool

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Pickers need visible label text and an accessibility label. Pickers with the default or `MenuPickerStyle` need `Picker(\"Label\")` text which is spoken to VoiceOver as the accessibility label. Pickers with the `WheelPickerStyle` or `SegmentedPickerStyle` need an `.accessibilityLabel` set to match their visible label text and need `.accessibilityElement(children: .contain)` or else the accessibility label will not be spoken to VoiceOver. Don't use `.accessibilityLabel` on `Picker` with the default or `MenuPickerStyle` or else VoiceOver will not speak the visible picker value text when the picker is closed. Use `AccessibilityFocusState` to send VoiceOver focus back to the picker when the value has been changed.")
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
                Text("Fruit: \(selectedFruitDefault.rawValue)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Picker("Fruit", selection: $selectedFruitDefault) {
                    ForEach(Fruit.allCases) { fruit in
                        Text(fruit.rawValue).tag(fruit)
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .onChange(of: selectedFruitDefault) {
                        isTriggerFocused = true
                    }
                    .accessibilityFocused($isTriggerFocused)
                DisclosureGroup("Details") {
                    Text("The default style good example uses `Picker(\"Fruit\")` label text which is spoken as the accessibility label to VoiceOver. `AccessibilityFocusState` is used to send VoiceOver focus back to the picker when the value has been changed.")
                }.padding(.bottom).accessibilityHint("Good Example Default Style")
                Text("Good Example Wheel Style")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Fruit: \(selectedFruitWheel.rawValue)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Picker("Fruit", selection: $selectedFruitWheel) { //a11yLabel and Picker label don't speak to VoiceOver for WheelPickerStyle
                    ForEach(Fruit.allCases) { fruit in
                        Text(fruit.rawValue).tag(fruit)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .accessibilityElement(children: .contain) // only if children .contain applied then a11yLabel will speak
                .accessibilityLabel("Fruit")
                DisclosureGroup("Details") {
                    Text("The wheel style good example uses `.accessibilityLabel(\"Fruit\")` which matches the visible label text and `.accessibilityElement(children: .contain)` to make sure the accessibility label is spoken to VoiceOver.")
                }.padding(.bottom).accessibilityHint("Good Example Wheel Style")
                Text("Good Example Segmented Style")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Fruit: \(selectedFruitSegmented.rawValue)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Picker("Fruit", selection: $selectedFruitSegmented) { //a11yLabel and Picker label don't speak to VoiceOver for SegmentedPickerStyle
                    ForEach(Fruit.allCases) { fruit in
                        Text(fruit.rawValue).tag(fruit)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .accessibilityElement(children: .contain) // only if children .contain applied then a11yLabel will speak
                .accessibilityLabel("Fruit")
                DisclosureGroup("Details") {
                    Text("The segmented style good example uses `.accessibilityLabel(\"Fruit\")` which matches the visible label text and `.accessibilityElement(children: .contain)` to make sure the accessibility label is spoken to VoiceOver.")
                }.padding()
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
                .onChange(of: selectedFruit) {
                    isFruitFocused = true
                }
                .accessibilityFocused($isFruitFocused)
                DisclosureGroup("Details") {
                    Text("The menu style good example uses `Picker(\"Fruit\")` label text which is spoken as the accessibility label to VoiceOver.")
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
                Text("Bad Example Default Style")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Picker("", selection: $selectedFruitDefaultBad) {
                    ForEach(Fruit.allCases) { fruit in
                        Text(fruit.rawValue).tag(fruit)
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityLabel("Fruit")
                DisclosureGroup("Details") {
                    Text("The default style bad example uses `.accessibilityLabel(\"Fruit\")` which incorrectly overrides the visible picker label text and VoiceOver will not speak the visible selected picker value when the picker is closed. `AccessibilityFocusState` is not used to send VoiceOver focus back to the picker when the value has been changed.")
                }.padding()
                Text("Bad Example Wheel Style")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Picker("", selection: $selectedFruitWheelBad) {
                    ForEach(Fruit.allCases) { fruit in
                        Text(fruit.rawValue).tag(fruit)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                DisclosureGroup("Details") {
                    Text("The wheel style bad example does not use an `.accessibilityLabel` or visible label text and does not use `.accessibilityElement(children: .contain)` to make sure the accessibility label is spoken to VoiceOver.")
                }.padding()
                Text("Bad Example Segmented Style")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Picker("", selection: $selectedFruitSegmentedBad) {
                    ForEach(Fruit.allCases) { fruit in
                        Text(fruit.rawValue).tag(fruit)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                DisclosureGroup("Details") {
                    Text("The segmented style bad example does not use an `.accessibilityLabel` or visible label text and does not use `.accessibilityElement(children: .contain)` to make sure the accessibility label is spoken to VoiceOver.")
                }.padding()
                Text("Bad Example Menu Style")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Picker("", selection: $selectedFruitBad) {
                    ForEach(Fruit.allCases) { fruit in
                        Text(fruit.rawValue).tag(fruit)
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
                .pickerStyle(MenuPickerStyle())
                DisclosureGroup("Details") {
                    Text("The menu style bad example uses empty `Picker(\"\")` label text so there is no accessibility label spoken to VoiceOver.")
                }.padding()
            }
            .navigationTitle("Pickers")
            .padding()
        }
 
    }
}
 
struct PickersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PickersView()
        }
    }
}
