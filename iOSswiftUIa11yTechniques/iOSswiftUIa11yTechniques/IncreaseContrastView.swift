/*
   Copyright 2024 CVS Health and/or one of its affiliates

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
 
struct IncreaseContrastView: View {

    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Make sure that text and non-text content has sufficient contrast in the default presentation of your app. You can also enhance the contrast of the UI if the user enables Increase Contrast in their Accessibility Settings. Use `@Environment(\\.colorSchemeContrast)` to check if the user has enabled Increase Contrast and then increase the contrast of your UI.")
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
                VStack(alignment: .leading) {
                    Button(action: {
                    }) {
                        Text(colorSchemeContrast == .standard ? "Standard Contrast" : "Increased Contrast")
                            .padding()
                            .background(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1))
                            .foregroundColor(getForegroundColor())
                            .border(colorSchemeContrast == .increased ? Color.gray : Color.clear, width: 2)
                    }
                }
                 .padding()
                VStack(alignment: .leading) {
                    Text("Enabling Increase Contrast").font(.subheadline).accessibilityAddTraits(.isHeader).bold()
                    Text("1. Open iOS Settings")
                    Button(action: { self.openSettings() }) {
                       Text("Open Settings")
                    }.padding(.leading)
                    Text("2. Go to **Accessibility > Display & Text Size** from the Settings home page.")
                    Text("3. Enable **Increase Contrast**.")
                }
                DisclosureGroup("Details") {
                    Text("The good increase contrast example uses button text with light color contrast and no border in the default presentation and then when increase contrast is enabled the button uses a dark text color with a visible border.")
                }.padding(.bottom).accessibilityHint("Good Example")
            }
            .navigationTitle("Increase Contrast")
            .padding()
        }
 
    }
    
    func getForegroundColor() -> Color {
        if colorSchemeContrast == .increased {
            if colorScheme == .dark {
                // Dark mode with increased contrast
                return Color.white
            } else if colorScheme == .light {
                // Light mode with increased contrast
                return Color.black
            }
        } else {
            if colorScheme == .dark {
                // Dark mode with standard contrast
                return Color.gray
            } else if colorScheme == .light {
                // Light mode with standard contrast
                return Color(red: 108 / 255, green: 108 / 255, blue: 108 / 255)
            }
        }
        // Default color if none of the conditions are met
        return Color.black
    }

    
    private func openSettings() {
          if let url = URL(string: UIApplication.openSettingsURLString) {
              if UIApplication.shared.canOpenURL(url) {
                  UIApplication.shared.open(url, options: [:], completionHandler: nil)
              }
          }
      }
}
 
struct IncreaseContrastView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            IncreaseContrastView()
        }
    }
}
