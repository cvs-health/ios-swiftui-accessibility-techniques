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
 
struct AttributedStringsView: View {
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Attributed Strings can have different attributes and styles for different parts of text in the string. When using attributed strings to visually convey meaning to sighted users there must also be meaningful alt text in the `.accessibilityLabel` of the attributed string. `.accessibilitySpeechAdjustedPitch` can be used to speak attributed strings to VoiceOver in a higher or lower pitch.")
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
                Text("iOS Developer Membership Sale").font(.headline).accessibilityAddTraits(.isHeader)
                Text(getAttributedLabel())
                    .accessibilityLabel("Old Price: $99, New Price: $79")
                Text("High and Low Pitch Text").font(.headline).accessibilityAddTraits(.isHeader).padding(.top)
                Text("\"Squeak, Squeak\" said the mouse. \"Fee, Fie, Fo, Fum\" said the giant.")
                    .accessibility(label: Text(getAccessibilityAttributedLabel()))
                DisclosureGroup("Details") {
                    Text("The good attributed strings example uses `.accessibilityLabel(\"Old Price: $99, New Price: $79\")` to give the attributed string with a strike-through price a meaningful accesibility label that includes alt text for the old price. The high and low pitch attributed string uses `.accessibilitySpeechAdjustedPitch` to speak \"Squeak, Squeak\" in a high pitched voice and \"Fee, Fie, Fo, Fum\" in a low pitched voice.")
                }.padding(.bottom).accessibilityHint("Good Example")
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
                Text("iOS Developer Membership Sale").font(.headline).accessibilityAddTraits(.isHeader)
                Text(getAttributedLabel())
                Text("High and Low Pitch Text").font(.headline).accessibilityAddTraits(.isHeader).padding(.top)
                Text("\"Squeak, Squeak\" said the mouse. \"Fee, Fie, Fo, Fum\" said the giant.")
                DisclosureGroup("Details") {
                    Text("The bad attributed strings example does not use an `.accessibilityLabel` to give the attributed string with a strike-through price a meaningful accessibility label that includes alt text for the old price. VoiceOver users don't know which is the old price or the new price. The high and low pitch attributed string does not use `.accessibilitySpeechAdjustedPitch` to speak \"Squeak, Squeak\" in a high pitched voice and \"Fee, Fie, Fo, Fum\" in a low pitched voice.")
                }.padding(.bottom).accessibilityHint("Bad Example")
            }
            .navigationTitle("Attributed Strings")
            .padding()
        }
 
    }
    func getAccessibilityAttributedLabel() -> AttributedString {
        var squeekSqueak = AttributedString("\"Squeak, Squeak\"")
        squeekSqueak.accessibilitySpeechAdjustedPitch = 1.0
        var feeFiFoFum = AttributedString("\"Fee, Fie, Fo, Fum\"")
        feeFiFoFum.accessibilitySpeechAdjustedPitch = -1.0
        return squeekSqueak+" said the mouse, "+feeFiFoFum+"said the giant."
    }
    func getAttributedLabel() -> AttributedString {
        var text = AttributedString("$99")
        text.strikethroughStyle = .single
        var text2 = AttributedString("$79")
        return text+" "+text2
    }
}
 
struct AttributedStringsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AttributedStringsView()
        }
    }
}
