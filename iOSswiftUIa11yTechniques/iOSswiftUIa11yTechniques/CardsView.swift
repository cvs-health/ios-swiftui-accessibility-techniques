/*
   Copyright 2023 CVS Health and/or one of its affiliates

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
 
struct CardsView: View {
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Cards need a heading as the first focused element with VoiceOver. Card call to action button or link needs to be unique and specific when spoken to VoiceOver users and may require an `.accessibilityLabel`.")
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
                VStack(alignment: .leading) {
                    Text("Sign Up for Newsletter")
                        .font(.headline)
                        .accessibilityAddTraits(/*@START_MENU_TOKEN@*/.isHeader/*@END_MENU_TOKEN@*/)
                    Image("get10off")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 170)
                        .accessibilityLabel("Get 10% off")
                    Text("Sign up for our newsletter and get 10% off your first purchase. We'll send you a coupon code after you enter your email address.")
                    Button(action: {
                        print("Your action function here")
                    }) {
                        Text("Sign Up").font(.headline)
                    }
                    .accessibilityLabel("Sign Up for Newsletter")
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
                    Text("The good card example uses a heading element at the top of the card and a more specific `.accessibilityLabel` for the call to action button.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
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
                VStack(alignment: .leading) {
                    Image("get10off")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 170)
                    Text("Sign Up for Newsletter")
                        .font(.headline)
                        .accessibilityAddTraits(/*@START_MENU_TOKEN@*/.isHeader/*@END_MENU_TOKEN@*/)
                    Text("Sign up for our newsletter and get 10% off your first purchase. We'll send you a coupon code after you enter your email address.")
                    Button(action: {
                        print("Your action function here")
                    }) {
                        Text("Sign Up").font(.headline)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.green)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
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
                    Text("The bad card example uses a heading element that is not at the top of the card and a generic call to action button.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
            }
            .navigationBarTitle("Cards")
            .padding()
        }
 
    }
}
 
struct CardsView_Previews: PreviewProvider {
    static var previews: some View {
        CardsView()
    }
}
