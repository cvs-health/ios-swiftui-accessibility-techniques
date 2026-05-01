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

struct ContrastView: View {
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Text must have a contrast ratio of at least 4.5:1 against its background (WCAG 1.4.3). Large text (18pt+ or 14pt+ bold) requires at least 3:1. Non-text UI components like borders, icons, and controls require at least 3:1 contrast against adjacent colors (WCAG 1.4.11). Use semantic SwiftUI colors like `.primary` and `.secondary` which automatically adapt to light and dark mode.")
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
                Text("Good Example Text Contrast")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("This text uses the default primary color.")
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Large Title Text")
                    .font(.title)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Secondary text for captions and hints.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The good text contrast examples use `.foregroundColor(.primary)` and `.foregroundColor(.secondary)` which provide sufficient contrast ratios in both light and dark mode. WCAG 1.4.3 requires 4.5:1 for normal text and 3:1 for large text (18pt+ or 14pt+ bold). The `.secondary` color meets the 3:1 minimum for large text and exceeds 4.5:1 for normal text in most configurations.")
                }.padding(.bottom).accessibilityHint("Good Example Text Contrast")
                Text("Good Example Non-Text Contrast")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button("Submit") {}
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("Email address", text: .constant(""))
                    .textFieldStyle(.roundedBorder)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                    )
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                    Text("Verified")
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
                DisclosureGroup("Details") {
                    Text("The good non-text contrast examples use `.buttonStyle(.borderedProminent)` which provides a filled button with sufficient contrast. The text field uses `.textFieldStyle(.roundedBorder)` with a visible border. The checkmark icon uses `.foregroundColor(.green)` which provides at least 3:1 contrast. WCAG 1.4.11 requires 3:1 contrast for UI components and graphical objects against adjacent colors.")
                }.padding(.bottom).accessibilityHint("Good Example Non-Text Contrast")
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
                Text("Bad Example Low Contrast Text")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("This light gray text is hard to read.")
                    .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Low contrast caption text.")
                    .font(.caption)
                    .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
                    .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The bad text contrast examples use hardcoded light gray colors like `Color(red: 0.7, green: 0.7, blue: 0.7)` which has approximately a 2.6:1 contrast ratio against a white background, failing the WCAG 1.4.3 minimum of 4.5:1. These colors also do not adapt to dark mode.")
                }.padding(.bottom).accessibilityHint("Bad Example Low Contrast Text")
                Text("Bad Example Low Contrast Non-Text")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button("Submit") {}
                    .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("Email address", text: .constant(""))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 1)
                    )
                    .padding(.vertical, 8)
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
                        .font(.title2)
                    Text("Verified")
                        .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
                DisclosureGroup("Details") {
                    Text("The bad non-text contrast examples use very light gray colors for the button text, text field border, and icon. The button text at `Color(red: 0.75, ...)` has approximately 2:1 contrast. The text field border at `Color(red: 0.85, ...)` has approximately 1.4:1 contrast. Both fail the WCAG 1.4.11 minimum of 3:1 for UI components. These hardcoded colors also do not adapt to dark mode.")
                }.padding(.bottom).accessibilityHint("Bad Example Low Contrast Non-Text")
                Text("Bad Example Hardcoded Colors")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("This text uses hardcoded black.")
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("This text uses hardcoded white on a dark rectangle.")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                    .cornerRadius(8)
                DisclosureGroup("Details") {
                    Text("The bad hardcoded color examples use `Color.black` and `Color.white` which do not adapt to dark mode. In dark mode, black text on a dark background becomes invisible. In light mode, white text on a light background is unreadable. Use `.foregroundColor(.primary)` instead which automatically adjusts to the current color scheme.")
                }.padding(.bottom).accessibilityHint("Bad Example Hardcoded Colors")
            }
            .padding()
            .navigationTitle("Contrast")
        }
    }
}

#Preview {
    NavigationStack {
        ContrastView()
    }
}
