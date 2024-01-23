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
 
struct SegmentedControlsView: View {
    @State private var favoriteColor = "Red"
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Segmented controls need `.accessibilityElement(children: .contain)` and `.accessibilityLabel(\"Group Label\")` applied to the `Picker{}` so that VoiceOver users hear the segmented control group label spoken when first moving focus to a segment in the group.")
                    .padding(.bottom)
                Text("Good Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                Text("What is your favorite color? \(favoriteColor)").frame(maxWidth: .infinity, alignment: .leading)
                Picker("What is your favorite color?", selection: $favoriteColor) {
                    Text("Red").tag("Red")
                    Text("Green").tag("Green")
                    Text("Blue").tag("Blue")
                }
                .pickerStyle(.segmented)
                //a11yLabel, Hint, and Value dont' work on Picker{} unless you add .accessibilityElement(children: .contain) then a11yLabel works as a Grouping Container (Idea taken from Apple SwiftUI Accessibility Examples app)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("What is your favorite color?")
                .accessibilityIdentifier("pickerGood")
                DisclosureGroup("Details") {
                    Text("The good Segmented controls example uses `.accessibilityElement(children: .contain)` and `.accessibilityLabel(\"What is your favorite color?\")` on the `Picker{}` so that VoiceOver users hear the group label spoken when first moving focus to a segment in the group.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                Text("Bad Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                Text("What is your favorite color? \(favoriteColor)").frame(maxWidth: .infinity, alignment: .leading)
                Picker("What is your favorite color?", selection: $favoriteColor) {
                    Text("Red").tag("Red")
                    Text("Green").tag("Green")
                    Text("Blue").tag("Blue")
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("pickerBad")
                DisclosureGroup("Details") {
                    Text("The bad Segmented controls example does not use `.accessibilityLabel` for each `tag()` segment button causing VoiceOver users to only hear the segment label and not the group label spoken together.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
            }
            .navigationTitle("Segmented Controls")
            .padding()
        }
 
    }
}
 
struct SegmentedControlsView_Previews: PreviewProvider {
    static var previews: some View {
        SegmentedControlsView()
    }
}
