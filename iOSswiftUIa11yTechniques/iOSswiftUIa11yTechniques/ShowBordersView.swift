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

struct ShowBordersView: View {

    @Environment(\.accessibilityShowButtonShapes) private var showButtonShapes


    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    /// The bad example's hardcoded frame and the room it reserves for a border it
    /// never draws. Both scale with Dynamic Type, so the label keeps fitting at
    /// every text size while Show Borders is off and the reserved room always
    /// overflows it once the setting is on. That keeps this example's only failure
    /// the Show Borders one, rather than a plain Dynamic Type bug at large sizes.
    @ScaledMetric private var badButtonWidth: CGFloat = 130
    @ScaledMetric private var badButtonHeight: CGFloat = 44
    @ScaledMetric private var reservedBorderRoom: CGFloat = 30

    var body: some View {
        ScrollView {
            VStack {
                Text("Use `@Environment(\\.accessibilityShowButtonShapes)` to draw your own border on a custom button when the user enables Show Borders. Avoid fixed width button containers so the text does not truncate when Show Borders is enabled.")
                    .padding(.bottom)
                Text("Show Borders is currently **\(showButtonShapes ? "On" : "Off")**. Both buttons are identical until you turn it on.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom)
                Text("Good Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                Button(action: {
                }) {
                    Text("Add to Cart")
                        .padding(.horizontal, showButtonShapes ? 14 : 0)
                        .padding(.vertical, showButtonShapes ? 8 : 0)
                        .frame(minHeight: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(showButtonShapes ? Color.accentColor : Color.clear, lineWidth: 1)
                        )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
                DisclosureGroup("Details") {
                    Text("The good example uses `.frame(minHeight: 44)` with no fixed width, so it strokes a border and grows to fit when Show Borders is on.")
                }.padding(.bottom).accessibilityHint("Good Example")
                Text("Bad Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                Button(action: {
                }) {
                    Text("Add to Cart")
                        .lineLimit(1)
                        .padding(.horizontal, showButtonShapes ? reservedBorderRoom : 0)
                        .frame(width: badButtonWidth, height: badButtonHeight, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
                DisclosureGroup("Details") {
                    Text("The bad example uses a hardcoded `.frame(width:height:)` with `.lineLimit(1)`. The width is fixed, so \"Add to Cart\" truncates to \"Add to...\". The frame is `@ScaledMetric`, so this fails on Show Borders alone, not Dynamic Type.")
                }.padding(.bottom).accessibilityHint("Bad Example")
                VStack(alignment: .leading) {
                    Text("Enabling Show Borders").font(.subheadline).accessibilityAddTraits(.isHeader).bold()
                    Text("1. Open iOS Settings")
                    Button(action: { self.openSettings() }) {
                       Text("Open Settings")
                    }.padding(.leading)
                    Text("2. Go to **Accessibility > Display & Text Size** from the Settings home page.")
                    Text("3. Enable **Show Borders**, labelled **Button Shapes** in iOS 26.0 and earlier.")
                }
            }
            .navigationTitle("Show Borders")
            .padding()
        }

    }

    private func openSettings() {
          if let url = URL(string: UIApplication.openSettingsURLString) {
              if UIApplication.shared.canOpenURL(url) {
                  UIApplication.shared.open(url, options: [:], completionHandler: nil)
              }
          }
      }
}

// `accessibilityShowButtonShapes` is a read-only environment key, so the enabled
// state cannot be pinned in a Preview. Toggle Show Borders in Settings to see it.
#Preview {
    NavigationStack {
        ShowBordersView()
    }
}
