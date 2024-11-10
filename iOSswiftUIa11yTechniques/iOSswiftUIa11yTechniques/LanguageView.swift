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
 
struct LanguageView: View {
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Parts of the app or page that are in a different language than the main language must be spoken to VoiceOver users in the correct speech synthesizer, i.e., Spanish text must be spoken in a Spanish synthesizer with the correct accent and pronunciations. Use an `AttributedString` with `attributes: AttributeContainer().languageIdentifier()` on the different language text so VoiceOver speaks it correctly with a proper accent for that language.")
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
                Text("Welcome to our home page.")
                Text(
                    AttributedString(
                        "Bienvenido a nuestra página de inicio.",
                        attributes: AttributeContainer().languageIdentifier("es")
                    )
                )
                DisclosureGroup("Details") {
                    Text("The good language example uses an `AttributedString` with `attributes: AttributeContainer().languageIdentifier(\"es\")` on the Spanish text so VoiceOver speaks it correctly with a Spanish accent.")
                }.padding(.bottom)
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
                Text("Welcome to our home page.")
                Text("Bienvenido a nuestra página de inicio.")
                DisclosureGroup("Details") {
                    Text("The bad language example uses Spanish text with no `.languageIdentifier` `AttributedString` `attributes: so VoiceOver speaks it incorrectly without a Spanish accent.")
                }.padding(.bottom)
            }
            .navigationTitle("Language")
            .padding()
        }
 
    }
}
 
struct LanguageView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LanguageView()
        }
    }
}
