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

struct XCTestAccessibilityView: View {
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("performAccessibilityAudit() checks for contrast, hit area size, text clipping, and missing accessibility labels. The bad examples below intentionally trigger these audit failures so that a UI test using the issueHandler pattern can collect and report all of them at once.")
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
                Text("Good Example Button with descriptive label")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button(action: {}) {
                    Image(systemName: "envelope.fill")
                }
                .accessibilityLabel("Compose email")
                .accessibilityIdentifier("goodButtonLabel")
                DisclosureGroup("Details") {
                    Text("The good Button wraps an icon image and uses .accessibilityLabel(\"Compose email\") to give VoiceOver users a clear, human-readable description. performAccessibilityAudit() passes this example.")
                }.padding(.bottom).accessibilityHint("Good Example Button with descriptive label")
                Text("Good Example Image with accessibility label")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Image(systemName: "heart.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
                    .accessibilityLabel("Favorite")
                    .accessibilityIdentifier("goodImageLabel")
                DisclosureGroup("Details") {
                    Text("The good Image uses .accessibilityLabel(\"Favorite\") to provide a human-readable description instead of relying on the system image name. performAccessibilityAudit() passes this example.")
                }.padding(.bottom).accessibilityHint("Good Example Image with accessibility label")
                Text("Good Example Text with sufficient contrast")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                ZStack {
                    Color.white
                    Text("Sufficient contrast text")
                        .foregroundColor(.black)
                        .padding()
                        .accessibilityIdentifier("goodContrastText")
                }
                .frame(height: 60)
                DisclosureGroup("Details") {
                    Text("The good Text uses black on white which provides a 21:1 contrast ratio, well above the WCAG AA minimum of 4.5:1. performAccessibilityAudit() passes this example.")
                }.padding(.bottom).accessibilityHint("Good Example Text with sufficient contrast")
                Text("Good Example Button with adequate hit area")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button("Submit") {}
                    .frame(minWidth: 44, minHeight: 44)
                    .accessibilityIdentifier("goodHitArea")
                DisclosureGroup("Details") {
                    Text("The good Button uses .frame(minWidth: 44, minHeight: 44) to meet Apple's recommended 44×44 point minimum touch target size. performAccessibilityAudit() passes this example.")
                }.padding(.bottom).accessibilityHint("Good Example Button with adequate hit area")
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
                Text("Bad Example Button with no accessibility label")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button(action: {}) {
                    Image(systemName: "envelope.fill")
                }
                .accessibilityLabel("") // empty label — audit reports "Element has no description"
                .accessibilityIdentifier("badButtonNoLabel")
                DisclosureGroup("Details") {
                    Text("The bad Button uses .accessibilityLabel(\"\") which results in an empty accessibility label. VoiceOver users receive no description. performAccessibilityAudit() reports an 'Element has no description' failure.")
                }.padding(.bottom).accessibilityHint("Bad Example Button with no accessibility label")
                Text("Bad Example Image with no accessibility label")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Image(systemName: "star.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.yellow)
                    .accessibilityLabel("") // empty label — audit reports "Element has no description"
                    .accessibilityIdentifier("badImageNoLabel")
                DisclosureGroup("Details") {
                    Text("The bad Image uses .accessibilityLabel(\"\") which results in an empty label. VoiceOver users receive no description. performAccessibilityAudit() reports an 'Element has no description' failure.")
                }.padding(.bottom).accessibilityHint("Bad Example Image with no accessibility label")
                Text("Bad Example Button with small hit area")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button("Tap") {}
                    .frame(width: 20, height: 20)
                    .contentShape(Rectangle())
                    .accessibilityIdentifier("badSmallHitArea")
                DisclosureGroup("Details") {
                    Text("The bad Button is constrained to 20×20 points, well below Apple's recommended 44×44 point minimum touch target. performAccessibilityAudit() reports an 'Element hit region is too small' failure.")
                }.padding(.bottom).accessibilityHint("Bad Example Button with small hit area")
                Text("Bad Example Text with insufficient contrast")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                ZStack {
                    Color.white
                    Text("Insufficient contrast text")
                        .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
                        .padding()
                        .accessibilityIdentifier("badContrastText")
                }
                .frame(height: 60)
                DisclosureGroup("Details") {
                    Text("The bad Text uses light gray (75% brightness) on a white background, giving a contrast ratio of approximately 2.3:1 — below the WCAG AA minimum of 4.5:1. performAccessibilityAudit() reports a contrast failure.")
                }.padding(.bottom).accessibilityHint("Bad Example Text with insufficient contrast")
            }
            .padding()
            .navigationTitle("XCTest Accessibility")
        }
    }
}

#Preview {
    NavigationStack {
        XCTestAccessibilityView()
    }
}
