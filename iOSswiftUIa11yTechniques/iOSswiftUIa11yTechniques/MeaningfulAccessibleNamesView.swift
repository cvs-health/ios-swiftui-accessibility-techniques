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
 
struct MeaningfulAccessibleNamesView: View {
    @State private var username: String = "jdoe24"
    @State private var email: String = "jdoe24@gmail.com"
    @State private var username2: String = ""
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Accessible names of UI controls must be meaningful when spoken to VoiceOver users. Use unique and specific label text to create meaningful accessible names for VoiceOver users. Use a unique and specific `.accessibilityLabel` if the visible label text does not meaningfully describe its specific function. If modifying the accessible name of a control, make sure to add the visible label text at the beginning of the `.accessibilityLabel`.")
                    .padding([.bottom])
                Text("Good Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                Text("Good Example Meaningful Label Text")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack(spacing:10) {
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.").padding(.top)
                    Button(action: {
                        // Handle button action
                    }) {
                        Text("Read More about Lorem Ipsum").padding(.leading)
                    }
                    
                    .frame(maxWidth: .infinity, alignment: .leading)
                }.frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The good meaningful label text example uses `Text(\"Read More about Lorem Ipsum\")` to give the button a unique and specific accessible name for VoiceOver users.")
                }.padding(.bottom).accessibilityHint("Good Example Meaningful Label Text")
                Text("Good Example Meaningful `.accessibilityLabel`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack(alignment: .leading) {
                    Text("ACME® Inc. BOOM-ERANG")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                    Text("🪃")
                        .font(.largeTitle)
                    Text("Guaranteed to return.")
                    Button(action: {
                        print("Your action function here")
                    }) {
                        Text("ADD TO CART").font(.headline)
                    }
                    .accessibilityLabel("Add to cart, ACME® Inc. BOOM-ERANG")
                    .accessibilityInputLabels(["Add to Cart", "Add Boomerang to Cart"])
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.green)
                            .shadow(color: .gray, radius: 1, x: 0, y: 2)
                    )
                    .foregroundColor(colorScheme == .dark ? Color.black : Color.black)
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 2)
                )
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(colorScheme == .dark ? Color.black : Color.white)
                        .shadow(color: .gray, radius: 5, x: 4, y: 4)
                )
                DisclosureGroup("Details") {
                    Text("The good meaningful `.accessibilityLabel` example uses `.accessibilityLabel(\"Add to cart, ACME® Inc. BOOM-ERANG\")` to modify the accessible name of the ADD TO CART button by adding the specific product name to the end of the `.accessibilityLabel` and adding the visible label text to the beginning of the `.accessibilityLabel`. VoiceOver does not say \"A D D to cart\" because \"Add\" has been written lower-case. Additionally, `.accessibilityInputLabels([\"Add to Cart\", \"Add Boomerang to Cart\"])` is added so that Voice Control users can speak the visible label text when they say a \"Tap\" command.")
                }.padding(.bottom).accessibilityHint("Good Example Meaningful `.accessibilityLabel`")
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
                Text("Bad Example no Meaningful Label Text")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack(spacing:10) {
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.").padding(.top)
                    Button(action: {
                        // Handle button action
                    }) {
                        Text("Read More").padding(.leading)
                    }
                    
                    .frame(maxWidth: .infinity, alignment: .leading)
                }.frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The bad meaningful label text example uses `Text(\"Read More\")` to give the button a generic accessible name that is not unique and specific for VoiceOver users.")
                }.padding(.bottom).accessibilityHint("Bad Example no Meaningful Label Text")
                Text("Bad Example no Meaningful `.accessibilityLabel`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack(alignment: .leading) {
                    Text("ACME® Inc. BOOM-ERANG")
                        .font(.headline)
                        .accessibilityAddTraits(/*@START_MENU_TOKEN@*/.isHeader/*@END_MENU_TOKEN@*/)
                    Text("🪃")
                        .font(.largeTitle)
                    Text("Guaranteed to return.")
                    Button(action: {
                        print("Your action function here")
                    }) {
                        Text("ADD TO CART").font(.headline)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.green)
                            .shadow(color: .gray, radius: 1, x: 0, y: 2)
                    )
                    .foregroundColor(colorScheme == .dark ? Color.black : Color.black)
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 2)
                )
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(colorScheme == .dark ? Color.black : Color.white)
                        .shadow(color: .gray, radius: 5, x: 4, y: 4)
                )
                DisclosureGroup("Details") {
                    Text("The bad meaningful `.accessibilityLabel` example uses `Text(\"ADD TO CART\")` as the the accessible name of the ADD TO CART button which does specifically include the name of the product that will be added to the cart.")
                }.padding(.bottom).accessibilityHint("Bad Example no Meaningful `.accessibilityLabel`")
            }
            .padding()
            .navigationTitle("Meaningful Accessible Names")

        }
 
    }
}
 
struct MeaningfulAccessibleNamesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MeaningfulAccessibleNamesView()
        }
    }
}
