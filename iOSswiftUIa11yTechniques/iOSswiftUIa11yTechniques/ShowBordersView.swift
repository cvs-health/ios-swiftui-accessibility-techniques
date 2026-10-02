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

/// A custom button style with no border by default. The fill is the affordance,
/// so the button is never identified by color alone. When the user turns on Show
/// Borders, the style draws its own border instead of leaving iOS to inject one.
///
/// The environment is read inside a nested `View` rather than on the style itself,
/// because a `ButtonStyle` is not a `View` and does not reliably receive
/// environment updates.
struct ShowBordersButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        StyleBody(configuration: configuration)
    }

    private struct StyleBody: View {
        let configuration: ButtonStyleConfiguration

        @Environment(\.accessibilityShowButtonShapes) private var showButtonShapes
        @Environment(\.colorScheme) private var colorScheme

        var body: some View {
            configuration.label
                .fontWeight(.semibold)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(minHeight: 44)
                .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                .background(colorScheme == .dark ? Color.white : Color.black)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .inset(by: 4)
                        .stroke(
                            showButtonShapes ? (colorScheme == .dark ? Color.black : Color.white) : Color.clear,
                            lineWidth: 2
                        )
                )
                .opacity(configuration.isPressed ? 0.7 : 1.0)
        }
    }
}

struct ShowBordersView: View {

    @Environment(\.accessibilityShowButtonShapes) private var showButtonShapes


    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Show Borders adds a system-drawn shape to controls iOS recognizes as buttons. When a button has no visible affordance of its own, that injected shape is the only thing the user gets, and it often reads as an oversized low-contrast grey block that fights your design. Give every button its own visible shape with sufficient contrast so the system has nothing left to add. Use `@Environment(\\.accessibilityShowButtonShapes)` to check if the user has enabled Show Borders and then strengthen your own affordance rather than suppressing the system shape, which some users rely on.")
                    .padding(.bottom)
                Text("This setting was labelled **Button Shapes** in iOS 26.0 and earlier and was renamed to **Show Borders** by iOS 26.3. The underlying preference and the SwiftUI and UIKit APIs still use the original button shapes naming.")
                    .padding(.bottom)
                Text("Show Borders is currently **\(showButtonShapes ? "On" : "Off")**.")
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
                }
                .buttonStyle(ShowBordersButtonStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
                Button(action: {
                }) {
                    Text("View Details")
                }
                .buttonStyle(ShowBordersButtonStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
                DisclosureGroup("Details") {
                    Text("The good show borders example uses a custom `ButtonStyle` with no border at all by default. The solid fill is the affordance, so the button is never identified by color alone and iOS has no missing affordance to compensate for. When Show Borders is enabled the style draws its own inset border, which is why no underline is needed. Because the button sizes itself from its label and uses `minHeight` rather than a fixed frame, the border has room to appear without changing the button's footprint or clipping the label.")
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
                        .padding(.horizontal, showButtonShapes ? 20 : 0)
                        .frame(width: 120, height: 36)
                        .foregroundColor(Color.white)
                        .background(Color(red: 0.0, green: 0.2, blue: 0.6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(showButtonShapes ? Color.white : Color.clear, lineWidth: 2)
                        )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
                Button(action: {
                }) {
                    Text("View Details")
                        .lineLimit(1)
                        .padding(.horizontal, showButtonShapes ? 20 : 0)
                        .frame(width: 120, height: 36)
                        .foregroundColor(Color(red: 0.557, green: 0.557, blue: 0.576))
                        .background(Color(red: 0.898, green: 0.898, blue: 0.918))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(showButtonShapes ? Color(red: 0.557, green: 0.557, blue: 0.576) : Color.clear, lineWidth: 2)
                        )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
                DisclosureGroup("Details") {
                    Text("The bad show borders example hardcodes `.frame(width: 120, height: 36)` with `.lineLimit(1)`, so the button cannot grow. It reserves horizontal room for its border only once Show Borders is enabled, and because the width is fixed that room has to come out of the label: \"Add to Cart\" and \"View Details\" both truncate to an ellipsis the moment the setting is turned on. Turning on an accessibility setting should never cost the user the button's name. \"View Details\" also uses grey text on a pale grey fill, which fails contrast and gives the fill too little contrast against the page to work as an affordance on its own.")
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
