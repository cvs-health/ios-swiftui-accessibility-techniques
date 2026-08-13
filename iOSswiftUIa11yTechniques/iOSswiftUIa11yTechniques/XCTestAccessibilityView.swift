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
                Text("Bad Example Image with no accessibility label")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Image(systemName: "exclamationmark.circle")
                        .accessibilityIdentifier("badImageLabel")
                    Text("Error loading content")
                }
                // Image inside HStack with Text gets an empty label from iOS accessibility combination
                DisclosureGroup("Details") {
                    Text("The bad Image is inside an HStack with a Text element. iOS accessibility combines them, leaving the Image with an empty accessibility label. performAccessibilityAudit() reports an 'Element has no description' failure.")
                }.padding(.bottom).accessibilityHint("Bad Example Image with no accessibility label")
                Text("Bad Example Text with insufficient contrast")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                ZStack {
                    Color(red: 0.15, green: 0.15, blue: 0.15)
                    Text("Insufficient contrast text")
                        .foregroundColor(Color(red: 0.28, green: 0.28, blue: 0.28))
                        // ~1.6:1 contrast ratio — fails WCAG AA in both light and dark mode
                        .padding()
                        .accessibilityIdentifier("badContrastText")
                }
                .frame(height: 60)
                DisclosureGroup("Details") {
                    Text("The bad Text uses near-identical shades of dark gray (~1.6:1 contrast ratio), well below the WCAG AA minimum of 4.5:1. Explicit colors are used so the failure occurs in both light and dark mode. performAccessibilityAudit() reports a contrast failure.")
                }.padding(.bottom).accessibilityHint("Bad Example Text with insufficient contrast")
                Text("Bad Example Icon Button with small hit area")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button(action: {}) {
                    Image(systemName: "xmark")
                        .frame(width: 14, height: 14)
                }
                .accessibilityLabel("Dismiss")
                .accessibilityIdentifier("badSmallHitArea")
                DisclosureGroup("Details") {
                    Text("The bad icon Button uses .frame(width: 14, height: 14) on the Image, well below Apple's recommended 44×44 point minimum. performAccessibilityAudit() reports a hit region failure.")
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
