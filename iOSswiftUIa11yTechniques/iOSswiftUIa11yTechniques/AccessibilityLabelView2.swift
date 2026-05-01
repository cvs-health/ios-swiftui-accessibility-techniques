/*
   Copyright 2026 CVS Health and/or one of its affiliates

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

struct AccessibilityLabelView2: View {
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Use `.accessibilityLabel` to provide a concise, meaningful name for UI elements that VoiceOver speaks to users. The label should describe what the element is, not what it does or its type. Labels should not include the control type (e.g., \"button\") because VoiceOver already announces the trait.")
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
                Text("Good Example Icon Button with Label")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button(action: {}) {
                    Image(systemName: "trash")
                        .font(.title2)
                }
                .accessibilityLabel("Delete")
                .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The good icon button example uses `.accessibilityLabel(\"Delete\")` to give the icon-only button a meaningful name. VoiceOver reads \"Delete, button\" instead of the SF Symbol name. The label is a single word that describes what the element is.")
                }.padding(.bottom).accessibilityHint("Good Example Icon Button with Label")
                Text("Good Example Image with Label")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Image(systemName: "dog.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.brown)
                    .accessibilityLabel("Golden retriever playing in a park")
                    .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The good image example uses `.accessibilityLabel(\"Golden retriever playing in a park\")` to describe what the image shows. VoiceOver reads the description so users understand the image content. Labels for images should describe what the image conveys, not the file name or technical details.")
                }.padding(.bottom).accessibilityHint("Good Example Image with Label")
                Text("Good Example Specific Label for Generic Button")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack(alignment: .leading) {
                    Text("Wireless Headphones")
                        .font(.headline)
                    Text("$79.99")
                        .foregroundColor(.secondary)
                    Button(action: {}) {
                        Text("Add to cart")
                    }
                    .accessibilityLabel("Add to cart, Wireless Headphones")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The good specific label example uses `.accessibilityLabel(\"Add to cart, Wireless Headphones\")` to make a generic \"Add to cart\" button specific to its context. The visible label text is included at the beginning of the `.accessibilityLabel` so Voice Control users can still activate it by saying the visible text.")
                }.padding(.bottom).accessibilityHint("Good Example Specific Label for Generic Button")
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
                Text("Bad Example Icon Button without Label")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button(action: {}) {
                    Image(systemName: "trash")
                        .font(.title2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The bad icon button example has no `.accessibilityLabel`. VoiceOver reads the SF Symbol name \"trash\" instead of a meaningful label like \"Delete\". SF Symbol names are not always clear or meaningful to users.")
                }.padding(.bottom).accessibilityHint("Bad Example Icon Button without Label")
                Text("Bad Example Image without Label")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Image(systemName: "dog.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.brown)
                    .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The bad image example has no `.accessibilityLabel`. VoiceOver reads the SF Symbol name or nothing at all. Users cannot understand what the image represents without a descriptive label.")
                }.padding(.bottom).accessibilityHint("Bad Example Image without Label")
                Text("Bad Example Label Includes Control Type")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button(action: {}) {
                    Image(systemName: "trash")
                        .font(.title2)
                }
                .accessibilityLabel("Delete button")
                .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The bad label example uses `.accessibilityLabel(\"Delete button\")` which includes the control type. VoiceOver already announces the button trait, so users hear \"Delete button, button\" which is redundant. Labels should never include the control type such as \"button\", \"image\", \"link\", or \"tab\".")
                }.padding(.bottom).accessibilityHint("Bad Example Label Includes Control Type")
            }
            .padding()
            .navigationTitle("Accessibility Label")
        }
    }
}

#Preview {
    NavigationStack {
        AccessibilityLabelView2()
    }
}
