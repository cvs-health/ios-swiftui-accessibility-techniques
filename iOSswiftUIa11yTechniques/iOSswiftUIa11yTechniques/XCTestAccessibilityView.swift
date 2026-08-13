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
                Text("Good Example Image Button with `.accessibilityLabel`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button(action: {}) {
                    Image("barcode.viewfinder")
                }
                .accessibilityLabel("Scan barcode")
                .accessibilityIdentifier("goodButtonLabel")
                DisclosureGroup("Details") {
                    Text("The good Button uses Image(\"barcode.viewfinder\") with .accessibilityLabel(\"Scan barcode\") to give VoiceOver a human-readable label instead of the filename. performAccessibilityAudit() passes this example.")
                }.padding(.bottom).accessibilityHint("Good Example Image Button with `.accessibilityLabel`")
                Text("Good Example Link with sufficient contrast")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Link("View accessibility details", destination: URL(string: "https://www.w3.org/WAI/")!)
                    .accessibilityIdentifier("goodContrastLink")
                DisclosureGroup("Details") {
                    Text("The good Link uses the app's AccentColor which has sufficient contrast for light and dark mode. performAccessibilityAudit() passes this example.")
                }.padding(.bottom).accessibilityHint("Good Example Link with sufficient contrast")
                Text("Good Example Icon Button with adequate hit area")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button(action: {}) {
                    Image(systemName: "xmark")
                        .frame(minWidth: 44, minHeight: 44)
                }
                .accessibilityLabel("Dismiss")
                .accessibilityIdentifier("goodHitArea")
                DisclosureGroup("Details") {
                    Text("The good icon Button uses .frame(minWidth: 44, minHeight: 44) on the Image to meet Apple's recommended 44×44 point minimum touch target. performAccessibilityAudit() passes this example.")
                }.padding(.bottom).accessibilityHint("Good Example Icon Button with adequate hit area")
                Text("Good Example Text that wraps without clipping")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("This text wraps across multiple lines so all content remains visible and readable by every user.")
                    .accessibilityIdentifier("goodTextWrapped")
                DisclosureGroup("Details") {
                    Text("The good Text has no lineLimit so it wraps and all content is visible. performAccessibilityAudit() passes this example.")
                }.padding(.bottom).accessibilityHint("Good Example Text that wraps without clipping")
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
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.blue)
                        .frame(width: 44, height: 44)
                }
                .accessibilityIdentifier("badButtonNoLabel")
                // Button wrapping a Shape has no derived accessibility label — audit reports "Element has no description"
                DisclosureGroup("Details") {
                    Text("The bad Button wraps a RoundedRectangle shape with no .accessibilityLabel. A Shape has no inherent accessibility label so VoiceOver has nothing to speak. performAccessibilityAudit() reports an 'Element has no description' failure.")
                }.padding(.bottom).accessibilityHint("Bad Example Button with no accessibility label")
                Text("Bad Example Text with insufficient contrast")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Insufficient contrast text")
                    .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75))
                    .background(Color.white)
                    // ~1.8:1 contrast ratio — fails WCAG AA; explicit white background so audit detects the color pair
                    .padding(8)
                    .accessibilityIdentifier("badContrastText")
                DisclosureGroup("Details") {
                    Text("The bad Text uses light gray (~1.8:1 contrast ratio on white) which is well below the WCAG AA minimum of 4.5:1. The explicit .background(Color.white) lets performAccessibilityAudit() detect the color pair and report a contrast failure.")
                }.padding(.bottom).accessibilityHint("Bad Example Text with insufficient contrast")
                Text("Bad Example Icon Button with small hit area")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button(action: {}) {
                    Image(systemName: "xmark")
                }
                .frame(width: 20, height: 20)
                .buttonStyle(.plain)
                .accessibilityLabel("Dismiss")
                .accessibilityIdentifier("badSmallHitArea")
                DisclosureGroup("Details") {
                    Text("The bad icon Button uses .frame(width: 20, height: 20) directly on the Button (not the Image), constraining the accessibility element's frame to 20×20 points, well below Apple's recommended 44×44 minimum. performAccessibilityAudit() reports a hit region failure.")
                }.padding(.bottom).accessibilityHint("Bad Example Icon Button with small hit area")
                Text("Bad Example Text visually clipped by frame")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("This text is visually clipped by its container frame and cannot be fully read by any user because the height is fixed too small for the content.")
                    .frame(height: 20, alignment: .top)
                    .clipped()
                    .accessibilityIdentifier("badTextClipped")
                DisclosureGroup("Details") {
                    Text("The bad Text uses .frame(height: 20).clipped() which visually cuts off the content. Unlike lineLimit truncation, this clips pixels — the accessible text exists but is invisible. performAccessibilityAudit() reports a text clipped failure.")
                }.padding(.bottom).accessibilityHint("Bad Example Text visually clipped by frame")
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
