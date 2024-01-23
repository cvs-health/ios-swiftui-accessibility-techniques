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
 
struct SlidersView: View {
    
    @State private var speedGood = 50.0
    @State private var speedBad = 50.0
    @State private var brightnessGood = 100.0
    @State private var brightnessBad = 100.0
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    @FocusState var isInputActive: Bool

    var body: some View {
        ScrollView {
            VStack {
                Text("Sliders are used to adjust a value by sliding the thumb between the minimum and maximum. Use `Slider` to create a native slider control that is adjustable with VoiceOver. Give each `Slider` a unique and meaningful accessibility label and visible label text. Include a `TextField` and `Stepper` to allow users fine control when adjusting the slider value.")
                    .padding([.bottom])
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
                Text("Good Example 1")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Brightness").frame(maxWidth: .infinity, alignment: .leading)
                Slider(value: $brightnessGood, in: 0...100, step: 1)
                    .accessibilityLabel("Brightness")
                    .accessibilityIdentifier("sliderGood1")
                DisclosureGroup("Details") {
                    Text("The first good slider example uses `Text(\"Brightness\")` as the visible label text and `.accessibilityLabel(\"Brightness\")` as the VoiceOver accessibility label.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                Text("Good Example 2")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Text("Speed")
                    TextField("", value: $speedGood, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(alignment: .leading)
                        .accessibilityLabel("Speed")
                        .keyboardType(.numberPad)
                        .focused($isInputActive)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    isInputActive = false
                                }
                            }
                        }
                    Stepper("", value: $speedGood).accessibilityLabel("Speed")
                }
                Slider(value: $speedGood, in: 0...100, step: 1) {
                        Text("Speed")
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("100")
                    }
                DisclosureGroup("Details") {
                    Text("The second good slider example uses visible label text as well as minimum and maximum value labels. A `TextField` and `Stepper` are included to allow users to see the exact value and have fine control when adjusting the value. The `Slider` uses internal `Text(\"Speed\")` as the invisible accessibility label. The `TextField` and `Stepper` use `.accessibilityLabel(\"Speed\")` as their VoiceOver labels.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
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
                Slider(value: $brightnessBad, in: 0...100, step: 1)
                    .accessibilityIdentifier("sliderBad1")
                DisclosureGroup("Details") {
                    Text("The first bad slider example uses no visible label text and no VoiceOver accessibility label.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                Text("Bad Example 2")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("\(Int(round(speedBad)))")
                Slider(value: $speedBad, in: 0...100, step: 1) {
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("100")
                    }
                    .accessibilityIdentifier("sliderBad2")
                DisclosureGroup("Details") {
                    Text("The second bad slider example uses no label text and no accessibility label for VoiceOver. Users can see the slider value but their is no `TextField` or `Stepper` included to allow fine control.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
            }
            .padding()
            .navigationTitle("Sliders")

        }
 
    }
}
 
struct SlidersView_Previews: PreviewProvider {
    static var previews: some View {
        SlidersView()
    }
}
