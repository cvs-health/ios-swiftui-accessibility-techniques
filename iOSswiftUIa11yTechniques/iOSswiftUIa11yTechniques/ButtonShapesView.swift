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

struct ButtonShapesView: View {

    @Environment(\.accessibilityShowButtonShapes) private var showButtonShapes


    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Button Shapes adds a system-drawn shape to controls iOS recognizes as buttons. When a button has no visible affordance of its own, that injected shape is the only thing the user gets, and it often reads as an oversized low-contrast grey block that fights your design. Give every button its own visible shape with sufficient contrast so the system has nothing left to add. Use `@Environment(\\.accessibilityShowButtonShapes)` to check if the user has enabled Button Shapes and then strengthen your own affordance rather than suppressing the system shape, which some users rely on.")
                    .padding(.bottom)
                Text("Button Shapes is currently **\(showButtonShapes ? "On" : "Off")**.")
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(minHeight: 44)
                        .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                        .background(colorScheme == .dark ? Color.white : Color.black)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: showButtonShapes ? 3 : 1)
                        )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
                Button(action: {
                }) {
                    Text("View Details")
                        .underline()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(minHeight: 44)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .background(colorScheme == .dark ? Color.black : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(showButtonShapes ? (colorScheme == .dark ? Color.white : Color.black) : Color.clear, lineWidth: 2)
                        )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
                DisclosureGroup("Details") {
                    Text("The good button shapes example gives each button an affordance the app owns. \"Add to Cart\" always has a solid background and a border, and \"View Details\" always has an underline, so neither button is identified by color alone and iOS has no missing affordance to compensate for. Both read `@Environment(\\.accessibilityShowButtonShapes)` and thicken their own border when the setting is on, so the button grows by a hairline instead of gaining a grey block. Padding is fixed in both states, so enabling Button Shapes never changes the layout.")
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
                        .foregroundColor(Color(red: 0.0, green: 0.478, blue: 1.0))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
                Button(action: {
                }) {
                    Text("View Details")
                        .padding(.horizontal, 24)
                        .padding(.vertical, 18)
                        .foregroundColor(Color(red: 0.557, green: 0.557, blue: 0.576))
                        .background(Color(red: 0.898, green: 0.898, blue: 0.918))
                        .cornerRadius(10)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
                DisclosureGroup("Details") {
                    Text("The bad button shapes example owns no affordance. \"Add to Cart\" is plain text tinted blue, so it is identified by color alone and is indistinguishable from body text when Button Shapes is off. \"View Details\" hardcodes heavy padding with grey text on a pale grey fill, which is the oversized low-contrast grey block users complain about, and it collides with the shape iOS draws on top. Neither button checks `@Environment(\\.accessibilityShowButtonShapes)`, so both leave the affordance entirely up to the system.")
                }.padding(.bottom).accessibilityHint("Bad Example")
                VStack(alignment: .leading) {
                    Text("Enabling Button Shapes").font(.subheadline).accessibilityAddTraits(.isHeader).bold()
                    Text("1. Open iOS Settings")
                    Button(action: { self.openSettings() }) {
                       Text("Open Settings")
                    }.padding(.leading)
                    Text("2. Go to **Accessibility > Display & Text Size** from the Settings home page.")
                    Text("3. Enable **Button Shapes**.")
                }
            }
            .navigationTitle("Button Shapes")
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
// state cannot be pinned in a Preview. Toggle Button Shapes in Settings to see it.
#Preview {
    NavigationStack {
        ButtonShapesView()
    }
}
