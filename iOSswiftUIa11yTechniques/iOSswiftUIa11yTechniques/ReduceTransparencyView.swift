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
 
struct ReduceTransparencyView: View {

    @Environment(\.accessibilityReduceTransparency) var reduceTransparency

    
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Make sure that text and non-text content has sufficient contrast in the default presentation of your app. You can also enhance the contrast of the UI if the user enables Reduce Transparency in their Accessibility Settings. Use `@Environment(\\.accessibilityReduceTransparency)` to check if the user has enabled Reduce Transparency and then reduce the transparency of design elements with low opacity to enhance contrast of the UI.")
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
                        Text(reduceTransparency == true ? "Reduced Transparency" : "Standard Transparency")
                            .padding()
                            .background(reduceTransparency == true ? Color(red: 146 / 255, green: 146 / 255, blue: 146 / 255) : Color.black.opacity(0.05))
                            .foregroundColor(reduceTransparency == true ? Color.black : Color(red: 108 / 255, green: 108 / 255, blue: 108 / 255))
                            .cornerRadius(10)
                    }
                }
                 .padding()
                VStack(alignment: .leading) {
                    Text("Enabling Reduce Transparency").font(.subheadline).accessibilityAddTraits(/*@START_MENU_TOKEN@*/.isHeader/*@END_MENU_TOKEN@*/).bold()
                    Text("1. Open iOS Settings")
                    Button(action: { self.openSettings() }) {
                       Text("Open Settings")
                    }.padding(.leading)
                    Text("2. Go to **Accessibility > Display & Text Size** from the Settings home page.")
                    Text("3. Enable **Reduce Transparency**.")
                }
                DisclosureGroup("Details") {
                    Text("The good reduce transparency example uses a light, transparent background color on the button in the default presentation and then when reduce transparency is enabled the button uses a dark background color with the transparency reduced.")
                }.padding(.bottom).accessibilityHint("Good Example")
            }
            .navigationTitle("Reduce Transparency")
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
 
struct ReduceTransparencyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ReduceTransparencyView()
        }
    }
}
