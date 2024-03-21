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
 
struct HidingFromAccessibility: View {
    @State private var searchText = ""

    
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Only purely decorative images or content like repetitive text should be hidden from accessibility. Don't hide informative or functional content from assistive technology users. Don't use `.accessibilityHidden(true)` on any informative content or UI controls. Don't use `.accessibilityHidden(true)` on any parent view containers that hold informative or functional content because all child elements will be hidden from accessibility users.")
                    .padding(.bottom)
                Text("Good Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                HeaderContainer(searchText: $searchText)
                DisclosureGroup("Details") {
                    Text("The good example uses a custom `HeaderContainer` view that holds a search input, notifications button, and shopping cart button. `.accessibilityHidden(true)` is used on the icon button's badge numbers to avoid VoiceOver speaking repetitive text.")
                }
                Text("Bad Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                HeaderContainer(searchText: $searchText)
                    .accessibilityHidden(true)
                DisclosureGroup("Details") {
                    Text("The bad example uses a custom `HeaderContainer` view that holds a search input, notifications button, and shopping cart button. `.accessibilityHidden(true)` is incorrectly used to hide the contents of the custom view from assistive technology users. VoiceOver, Voice Control, and Full Keyboard Access users cannot focus on or activate any of the controls inside the custom view with `.accessibilityHidden(true)` applied.")
                }
            }
            .navigationTitle("Hiding from Accessibility")
            .padding()
        }
 
    }
}
 
struct HidingFromAccessibility_Previews: PreviewProvider {
    static var previews: some View {
        HidingFromAccessibility()
    }
}


struct HeaderContainer: View {
    
    @Binding var searchText: String
    @Environment(\.colorScheme) var colorScheme
    var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)

    var body: some View {
        HStack {
            Text("Search")
            TextField("", text: $searchText)
                .padding(7)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .accessibilityLabel("Search")
            Spacer()
            Button(action: {
            }) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 24))
            }
            .accessibilityLabel("3 Notifications")
            .overlay(
                Text("3")
                    .accessibilityHidden(true)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .clipShape(Circle())
                    .offset(x: 10, y: -10),
                alignment: .topTrailing
            )
            Button(action: {
            }) {
                Image(systemName: "cart.fill")
                    .font(.system(size: 24))
            }
            .accessibilityLabel("1 item in cart")
            .overlay(
                Text("1")
                    .accessibilityHidden(true)
                    .font(.caption)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .padding(5)
                    .background(colorScheme == .dark ? .white : .black)
                    .clipShape(Circle())
                    .offset(x: 10, y: -10),
                alignment: .topTrailing
            )

        }
        .padding(.horizontal)
    }
}
