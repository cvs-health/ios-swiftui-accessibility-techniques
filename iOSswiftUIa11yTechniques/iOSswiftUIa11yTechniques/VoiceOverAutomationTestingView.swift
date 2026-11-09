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

struct VoiceOverAutomationTestingView: View {

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("`XCUIVoiceOverService` drives VoiceOver from a UI test and returns what it speaks as a `String`, so the announcement itself can be asserted in CI. Turn VoiceOver on and read the examples below to hear the difference between a trait that reaches VoiceOver and one that does not. Both examples contain `.accessibilityAddTraits(.isHeader)` in their source, so static analysis cannot tell them apart — only the spoken utterance can.")
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
                Text("Good Example Assertable Heading")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Store Hours")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h2)
                    .accessibilityIdentifier("assertableHeading")
                VStack(alignment: .leading) {
                    Text("Monday to Friday 8AM to 9PM")
                    Text("Saturday 9AM to 10PM")
                }.frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    VStack {
                        Text("This heading speaks as \"Store Hours Heading level 2\", so a UI test can assert the trait and the level. `try vo.moveForward().utterance` returns that string. The level is only spoken because `.accessibilityAddTraits(.isHeader)` is applied alongside `.accessibilityHeading(.h2)`.")
                    }
                }.padding(.bottom).accessibilityHint("Good Example Assertable Heading")
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
                Text("Bad Example Fake Heading That Passes a Text Assertion")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Store Hours")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityLabel("Store Hours, Heading")
                    .accessibilityIdentifier("fakeHeading")
                VStack(alignment: .leading) {
                    Text("Monday to Friday 8AM to 9PM")
                }.frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    VStack {
                        Text("This text fakes a heading by putting the word \"Heading\" in `.accessibilityLabel` instead of applying `.accessibilityAddTraits(.isHeader)`. It speaks as \"Store Hours, Heading\", so a UI test asserting `utterance.contains(\"Heading\")` passes — and it is still not a heading. VoiceOver users cannot reach it with the Rotor or `VO-Cmd-H`, because it has no header trait. This is why trait membership must be asserted with keyboard quick navigation rather than by matching text: a string assertion checks what was spoken, not what the element is.")
                    }
                }.padding(.bottom).accessibilityHint("Bad Example Fake Heading That Passes a Text Assertion")
            }
            .padding()
            .navigationTitle("VoiceOver Automation Testing")
        }
    }
}

#Preview {
    NavigationStack {
        VoiceOverAutomationTestingView()
    }
}
