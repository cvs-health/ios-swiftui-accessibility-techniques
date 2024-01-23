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
 
struct VoiceOverPronunciationView: View {
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("VoiceOver Pronunciation can be controlled by using `.speechAlwaysIncludesPunctuation()` or `.speechSpellsOutCharacters()`. Use `.speechAlwaysIncludesPunctuation()` to make VoiceOver speak all punctuation characters, e.g., for code snippets or grammar usage guidance. Use `.speechSpellsOutCharacters()` if VoiceOver incorrectly speaks text together as one word when it should speak the text letter by letter.")
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
                Text("Use this code to add alt text to an image in SwiftUI:")
                Text("`Image(\"get10off\").accessibilityLabel(\"Get 10% off\")`")
                     .speechAlwaysIncludesPunctuation()
                Text("Google stock symbol is:").padding(.top)
                Text("GOOG").speechSpellsOutCharacters()
                Text("Enter Code").padding(.top)
                Text("2525").speechSpellsOutCharacters()
                DisclosureGroup("Details") {
                    Text("The good VoiceOver Pronunciation example uses `.speechAlwaysIncludesPunctuation()` so that VoiceOver speaks all punctuation characters in the SwiftUI code snippet. `.speechSpellsOutCharacters()` is used so that the GOOG stock symbol is spoken as G-O-O-G to VoiceOver and 2525 spoken as “two-five-two-five” rather than “two-thousand-five-hundred-twenty-five”.")
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
                Text("Use this code to add alt text to an image in SwiftUI:")
                Text("`Image(\"get10off\").accessibilityLabel(\"Get 10% off\")`")
                Text("Google stock symbol is:").padding(.top)
                Text("GOOG")
                Text("Enter Code").padding(.top)
                Text("2525")
                DisclosureGroup("Details") {
                    Text("The bad VoiceOver Pronunciation example does not use `.speechAlwaysIncludesPunctuation()` which causes VoiceOver to ignore all punctuation characters in the SwiftUI code snippet. `.speechSpellsOutCharacters()` is not used causing VoiceOver to speak the GOOG stock symbol as “GOOG” rather than “G-O-O-G” and 2525 is spoken as “two-thousand-five-hundred-twenty-five” rather than “two-five-two-five”.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
            }
            .navigationTitle("VoiceOver Pronunciation")
            .padding()
        }
 
    }
}
 
struct VoiceOverPronunciationView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceOverPronunciationView()
    }
}
