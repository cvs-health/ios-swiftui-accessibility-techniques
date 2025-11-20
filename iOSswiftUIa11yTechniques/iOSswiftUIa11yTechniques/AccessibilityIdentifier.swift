/*
   Copyright 2025 CVS Health and/or one of its affiliates

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
 
struct AccessibilityIdentifier: View {
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Accessibility Identifiers are used for UI Testing to specify a string as the name of an element that can be selected in the UI Test. Accessibility Identifiers are not spoken to VoiceOver users and should not be used to label elements for accessibility users.")
                    .padding(.bottom)
                Text("Good Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                Button(action: {
                    
                }) {
                    Image(systemName: "tray.and.arrow.down")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 44, height: 44)
                        .accessibilityLabel("Download Files")
                }
                .accessibilityIdentifier("downloadFilesButton")
                DisclosureGroup("Details") {
                    Text("The good example uses `.accessibilityIdentifier(\"downloadFilesButton\")` to uniquely identify the button so that it can be selected in the UI Test. `.accessibilityLabel(\"Download Files\")` is used to provide a descriptive label to VoiceOver users.")
                }.padding(.bottom).accessibilityHint("Good Example")
                Text("Bad Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                Button(action: {
                    
                }) {
                    Image(systemName: "tray.and.arrow.down")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 44, height: 44)
                        .accessibilityIdentifier("Download Files") // 🚨incorrectly trying to use as a label☠️
                }
                DisclosureGroup("Details") {
                    Text("The bad example incorrectly uses `.accessibilityIdentifier(\"Download Files\")` to try and label the button for VoiceOver users but `.accessibilityLabel(\"Download Files\")` should have been used instead.")
                }.padding(.bottom).accessibilityHint("Bad Example")
            }
            .navigationTitle("Accessibility Identifier")
            .padding()
        }
 
    }
}
 
#Preview {
    NavigationStack {
        AccessibilityIdentifier()
    }
}
