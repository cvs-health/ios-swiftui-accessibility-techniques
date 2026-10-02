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

    /// A standard filled iOS button fill, darkened from the system blue so white
    /// label text clears the 4.5:1 minimum rather than sitting at 4.0:1.
    private let buttonBlue = Color(red: 0.0, green: 0.337, blue: 0.702)

    var body: some View {
        ScrollView {
            VStack {
                Text("Show Borders adds a system-drawn shape to controls iOS recognizes as buttons. A plain filled iOS button has no border of its own, so give it one yourself when the user turns the setting on, and leave the button room to grow when you do. Use `@Environment(\\.accessibilityShowButtonShapes)` to check if the user has enabled Show Borders and then draw your own border rather than suppressing the system shape, which some users rely on.")
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
                        .fontWeight(.semibold)
                        .padding(.horizontal, showButtonShapes ? 36 : 16)
                        .padding(.vertical, 12)
                        .frame(minWidth: 150, minHeight: 44)
                        .foregroundColor(Color.white)
                        .background(buttonBlue)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .inset(by: 4)
                                .stroke(showButtonShapes ? Color.white : Color.clear, lineWidth: 2)
                        )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
                DisclosureGroup("Details") {
                    Text("The good show borders example is a plain filled iOS button with no border of its own. The fill is the affordance, so the button is never identified by color alone and needs no underline. When Show Borders is enabled it draws its own inset border and widens its padding to make room for it. Because it is sized with `.frame(minWidth: 150, minHeight: 44)`, the button simply grows to fit, so the border appears without ever clipping the label.")
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
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .padding(.horizontal, showButtonShapes ? 36 : 16)
                        .padding(.vertical, 12)
                        .frame(width: 150, height: 44)
                        .foregroundColor(Color.white)
                        .background(buttonBlue)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .inset(by: 4)
                                .stroke(showButtonShapes ? Color.white : Color.clear, lineWidth: 2)
                        )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
                DisclosureGroup("Details") {
                    Text("The bad show borders example is styled identically to the good one and differs in two modifiers: it uses a hardcoded `.frame(width: 150, height: 44)` instead of `minWidth` and `minHeight`, and it adds `.lineLimit(1)`. The button therefore cannot grow, so the room its border needs is taken out of the label and \"Add to Cart\" truncates to \"Add to...\" the moment Show Borders is turned on. Turning on an accessibility setting should never cost the user the button's name.")
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
