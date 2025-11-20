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
 
struct ScrollViews: View {

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Scroll views are not scrollable with Full Keyboard Access unless there is a focusable control like a `Button` or `DisclosureGroup` inside or after the scroll view.")
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
                ScrollView {
                        VStack(alignment: .leading) {
                            Button("Button 0", action: {})
                            ForEach(0..<100) {
                                Text("Row \($0)")
                            }
                        }
                    }
                DisclosureGroup("Details") {
                    Text("The good scroll view example uses a `Button` at the top of the `ScrollView` which allows Full Keyboard Access to scroll the view using the up and down arrow keys The bad scroll view example below does not have a `Button` or a `DisclosureGroup` in the scroll view or after the scroll view which prevents Full Keyboard Access from scrolling the view using the up or down arrow keys.")
                }.padding(.bottom)
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
                ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(0..<100) {
                                Text("Row \($0)")
                            }
                        }
                }
            }
            .navigationTitle("Scroll Views")
            .padding()
        }
 
    }
}
 
struct ScrollViews_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ScrollViews()
        }
    }
}
