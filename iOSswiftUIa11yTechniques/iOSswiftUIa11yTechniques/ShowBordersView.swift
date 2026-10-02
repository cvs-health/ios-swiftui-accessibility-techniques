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

    var body: some View {
        ScrollView {
            VStack {
                Text("A basic SwiftUI `Button` with a text label renders as plain tinted text, with no border and no fill. Nothing but its color and position says it is tappable, which is exactly why iOS offers Show Borders. Honour the setting by drawing a real border when it is on, and leave the button room to grow so the border never comes at the expense of the label. Use `@Environment(\\.accessibilityShowButtonShapes)` to check whether the user has enabled it.")
                    .padding(.bottom)
                Text("This setting was labelled **Button Shapes** in iOS 26.0 and earlier and was renamed to **Show Borders** by iOS 26.3. The underlying preference and the SwiftUI and UIKit APIs still use the original button shapes naming.")
                    .padding(.bottom)
                Text("Show Borders is currently **\(showButtonShapes ? "On" : "Off")**. Both buttons below are identical while it is off. Turn it on and the good button gains a border, while the bad button truncates its label.")
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
                    Text("The good show borders example is a plain text button that sizes itself from its label, using `.frame(minHeight: 44)` for the touch target and no fixed width. When Show Borders is enabled it adds padding and strokes a border in the accent color, and because nothing pins its width the button simply grows to fit, so the full label survives. Note that a text-only button is distinguished by color and position alone while the setting is off, which is what WCAG 1.4.1 Use of Color cautions against. Honouring Show Borders is the minimum; a button carrying a critical action is better off with a permanent fill or border so it never depends on the user having found this setting.")
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
                        .padding(.horizontal, showButtonShapes ? 14 : 0)
                        .frame(width: 100, height: 44, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
                DisclosureGroup("Details") {
                    Text("The bad show borders example is the same plain text button pinned to a hardcoded `.frame(width: 100, height: 44)` with `.lineLimit(1)`. It reserves horizontal room once Show Borders is enabled but never actually draws a border, and because the width is fixed that room has to come out of the label, so \"Add to Cart\" truncates to \"Add to...\". The user loses the button's name and gains no affordance in exchange. Turning on an accessibility setting should never cost the user the button's name.")
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
