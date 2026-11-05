/*
   Copyright 2024-2026 CVS Health and/or one of its affiliates

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
                Text("Scroll views are not scrollable with Full Keyboard Access unless there is a focusable control like a `Button` or `DisclosureGroup` inside or after the scroll view. The `ScrollView` can also be made `.focusable()` or a focusable element can be placed inside the scroll view to allow Full Keyboard Access. WARNING: if you make the `ScrollView` `.focusable()` then DON'T put another focusable element like a `Button` inside the focusable `ScrollView` because nothing inside the scroll view will be focusable at that point.")
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
                    Text("The good scroll view example uses a `Button` at the top of the `ScrollView` which allows Full Keyboard Access to scroll the view using the up and down arrow keys The bad scroll view examples below do not have a `Button` or a `DisclosureGroup` in the scroll view or after the scroll view which prevents Full Keyboard Access from scrolling the view using the up or down arrow keys.")
                }.padding(.bottom)
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
                Text("Bad Example No Focusable Control")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(0..<100) {
                                Text("Row \($0)")
                            }
                        }
                }
                DisclosureGroup("Details") {
                    Text("The first bad scroll view example does not have a `Button` or a `DisclosureGroup` in the scroll view or after the scroll view and is not `.focusable()`, which prevents Full Keyboard Access from scrolling the view using the up or down arrow keys.")
                }.padding(.bottom).accessibilityHint("Bad Example No Focusable Control")
                Text("Bad Example Button Inside Focusable Scroll View")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(0..<100) {
                                Text("Row \($0)")
                            }
                            Button("Button 101", action: {})
                        }
                }.focusable()
                DisclosureGroup("Details") {
                    Text("The second bad scroll view example uses `.focusable()` on the `ScrollView` and also places a `Button` at the bottom of the scroll view content. Making the `ScrollView` itself focusable means Full Keyboard Access focus stops on the scroll view as a single element, so \"Button 101\" inside it can never be focused or activated with a keyboard. Either make the `ScrollView` `.focusable()` with no focusable controls inside it, or leave the `ScrollView` not focusable and put a focusable control inside or after it, as shown in the good example above.")
                }.accessibilityHint("Bad Example Button Inside Focusable Scroll View")
            }
            .navigationTitle("Scroll Views")
            .padding()
        }
 
    }
}
 
#Preview {
    NavigationStack {
        ScrollViews()
    }
}
