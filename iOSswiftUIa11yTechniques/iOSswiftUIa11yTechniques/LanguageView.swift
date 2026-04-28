/*
   Copyright 2023-2026 CVS Health and/or one of its affiliates

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
                Text("Parts of the app or page that are in a different language than the main language must be spoken to VoiceOver users in the correct speech synthesizer, i.e., Spanish text must be spoken in a Spanish synthesizer with the correct accent and pronunciations. Use `.environment(\\.locale, Locale(identifier: \"es\"))` on a container to set the language for an entire page or section. Use an `AttributedString` with `attributes: AttributeContainer().languageIdentifier()` on individual text elements in a different language so VoiceOver speaks them correctly.")
                    .padding(.bottom)
                Text("Good Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                Text("Good Example Language of Page")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                NavigationLink("Good Language of Page Example") {
                    LanguageOfPageGoodView()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The good Language of Page example opens a full page of Spanish content with `.environment(\\.locale, Locale(identifier: \"es\"))` applied to the entire page so VoiceOver speaks all of the Spanish text with a Spanish speech synthesizer.")
                }.padding(.bottom).accessibilityHint("Good Example Language of Page")
                Text("Good Example Language of Parts")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Welcome to our home page.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(
                    AttributedString(
                        "Bienvenido a nuestra página de inicio.",
                        attributes: AttributeContainer().languageIdentifier("es")
                    )
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The good Language of Parts example uses an `AttributedString` with `attributes: AttributeContainer().languageIdentifier(\"es\")` on the Spanish text so VoiceOver speaks it correctly with a Spanish accent while the surrounding English text is spoken with the default English accent.")
                }.padding(.bottom).accessibilityHint("Good Example Language of Parts")
                Text("Bad Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                Text("Bad Example Language of Page")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                NavigationLink("Bad Language of Page Example") {
                    LanguageOfPageBadView()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The bad Language of Page example opens a full page of Spanish content with no `.environment(\\.locale, Locale(identifier: \"es\"))` so VoiceOver speaks the Spanish text incorrectly without a Spanish accent, using the default English speech synthesizer.")
                }.padding(.bottom).accessibilityHint("Bad Example Language of Page")
                Text("Bad Example Language of Parts")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Welcome to our home page.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Bienvenido a nuestra página de inicio.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The bad Language of Parts example uses Spanish text with no `.languageIdentifier` `AttributedString` `attributes:` so VoiceOver speaks it incorrectly without a Spanish accent.")
                }.padding(.bottom).accessibilityHint("Bad Example Language of Parts")
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
