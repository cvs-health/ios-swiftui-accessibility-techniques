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
import UIKit

// UIViewRepresentable wrapper that creates a tappable UIView with no accessibility label at the UIKit layer.
// Unlike SwiftUI's empty-string label, a nil UIKit accessibilityLabel reliably triggers
// performAccessibilityAudit()'s "Element has no description" check.
private struct NoLabelButton: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isAccessibilityElement = true
        view.accessibilityTraits = .button
        view.accessibilityLabel = nil
        view.accessibilityIdentifier = "badButtonNoLabel"
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 4
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

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
                NoLabelButton()
                    .frame(width: 44, height: 44)
                // UIView with accessibilityLabel = nil at the UIKit layer — audit reports "Element has no description"
                DisclosureGroup("Details") {
                    Text("The bad Button is a UIViewRepresentable wrapping a UIView with accessibilityLabel = nil at the UIKit layer. Unlike SwiftUI's empty-string label, a nil UIKit label is unambiguously missing. performAccessibilityAudit() reports an 'Element has no description' failure.")
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
                Text("Bad Example Text truncated by lineLimit and narrow frame")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("This text is intentionally truncated: the full content is not visible to any user.")
                    .lineLimit(1)
                    .frame(maxWidth: 160)
                    .accessibilityIdentifier("badTextClipped")
                DisclosureGroup("Details") {
                    Text("The bad Text uses .lineLimit(1) combined with .frame(maxWidth: 160) to force visual truncation. The full text exists in the accessibility label but is visually cut off, creating a parity failure. performAccessibilityAudit() reports a text clipped failure.")
                }.padding(.bottom).accessibilityHint("Bad Example Text truncated by lineLimit and narrow frame")
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
