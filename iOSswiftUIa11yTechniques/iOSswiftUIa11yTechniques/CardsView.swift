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
    
    @State private var showShopAlert = false
    @AccessibilityFocusState private var isShopTriggerFocused: Bool
    
    @State private var showDetailView: Bool = false
    
    @State private var actionTitle = ""
    @State private var isExpanded: Bool = false

    @State private var showingAlert = false
    @State private var showingAlertBad = false
    @AccessibilityFocusState private var isTriggerFocused: Bool

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Cards need a heading as the first focused element with VoiceOver. Card call to action button or link needs to be unique and specific when spoken to VoiceOver users and may require an `.accessibilityLabel`. Cards with many actions can be combined as one focusable element by wrapping the card in a `NavigationLink` or using `.accessibilityElement(children: .combine)` and any actions missing when combined can be included using `.accessibilityAction`.")
                    .padding(.bottom)
                Text("Good Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                Text("Good Example Card with correct heading placement and `.accessibilityLabel`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack(alignment: .leading) {
                    Text("Sign Up for Newsletter")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
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
                    Text("The good example card with correct heading placement and `.accessibilityLabel` example uses a heading element at the top of the card and a more specific `.accessibilityLabel` for the call to action button.")
                }.padding([.bottom,.top]).accessibilityHint("Good Example Card with correct heading placement and .accessibilityLabel")
                Text("Good Card with heading, `.accessibilityElement(children: .combine)`, and button label fix")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack(alignment: .leading) {
                    Text("Get 20% off with code SUMMER20")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                    Text("Save on summer go‐tos when you choose same‐day delivery or FREE pickup.")
                    HStack {
                        Text("🏖️")
                            .font(.system(size: 70))
                        Button(action: {
                            self.showShopAlert.toggle()
                        }) {
                            Text("Shop Now").font(.headline)
                        }.accessibility(removeTraits: .isButton)//a11y hack fix to make sure button label is included when combined
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.green)
                                .shadow(color: .gray, radius: 1, x: 0, y: 2)
                        )
                        .foregroundColor(colorScheme == .dark ? Color.black : Color.black)
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityFocused($isShopTriggerFocused)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibility(addTraits: .isButton)//add button trait back
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
                .alert(isPresented: $showShopAlert) { 
                    Alert(title: Text("Success"), message: Text("You activated Shop Now."),
                          dismissButton:.default(Text("OK")) {
                            isShopTriggerFocused = true
                          })
                 }
                DisclosureGroup("Details") {
                    Text("The good card with heading, `.accessibilityElement(children: .combine)`, and button label fix combines the card into one focusable element which retains its child heading semantics. The card button label will not be spoken to VoiceOver unless the a11y hack fix of using `accessibility(removeTraits: .isButton)` is applied to the child button. The Button trait will also not be spoken to VoiceOver unless you manually add it back to the combined card element using `.accessibility(addTraits: .isButton)`.")
                }.padding([.bottom,.top]).accessibilityHint("Good Card with heading, `.accessibilityElement(children: .combine)`, and button label fix")
                Text("Good Example Card with Focus Combined & Accessibility Actions")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                NavigationLink(destination: DetailView()) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("NEW")
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding(8)
                                .background(colorScheme == .dark ? Color(.white) : Color(.blue))
                                .foregroundColor(colorScheme == .dark ? Color(.black) : Color(.white))
                                .foregroundColor(.white)
                                .cornerRadius(4)
                                .offset(x: -5, y: -5)
                            Spacer()
                            Text("$3.00 off")
                                .font(.largeTitle).bold()
                                .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                                .offset(x: -10, y: 0)
                            Spacer()
                            Spacer()
                        }
                        HStack(alignment: .top) {
                            Image("barber-shop")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 150)
                                .clipped()
                                .accessibilityLabel("Barber Shop")
                            VStack(alignment: .leading) {
                                Text("$3.00 off any haircut, trim, or shave with purchase of any styling products or shave cream.")
                                    .foregroundColor(colorScheme == .dark ? Color(.white) : Color(.black))
                                HStack {
                                    VStack {
                                        DisclosureGroup("Show details", isExpanded: $isExpanded) {
                                            Text("Must purchase at least one styling or shave cream product. Valid only during time of purchase.")
                                                .foregroundColor(colorScheme == .dark ? Color(.white) : Color(.black))
                                        }
                                        Text("Expires 05/31/24").frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(colorScheme == .dark ? Color(.white) : Color(.black))
                                    }
                                    Button(action: {
                                        showingAlert = true
                                        }) {
                                            Image(systemName: "plus")
                                                .font(.title.weight(.semibold))
                                                .padding(8)
                                                .background(colorScheme == .dark ? Color(.white) : darkRed)
                                                .foregroundColor(colorScheme == .dark ? darkRed : Color(.white))
                                                .clipShape(Circle())
                                                .shadow(radius: 2, x: 1, y: 2)
                                                .offset(x: 5, y: 5)
                                            
                                        }
                                        .accessibilityLabel("Add coupon to wallet")
                                        .accessibilityFocused($isTriggerFocused)
                                        .alert("Coupon added to wallet.", isPresented: $showingAlert) {
                                            Button("OK", role: .cancel) {
                                                isTriggerFocused = true
                                            }
                                        } message: {
                                            Text("The coupon has been added to your digital wallet.")
                                        }
                                }
                            }
                        }
                    }
                    .accessibilityAction(named: "Show details") {
                        actionTitle = "Show details"
                        isExpanded.toggle()
                    }
                    .accessibilityAction(named: "Add coupon to wallet") {
                        actionTitle = "Add coupon to wallet"
                        showingAlert = true
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
                }
                DisclosureGroup("Details") {
                    Text("The good example card with combined focus and accessibility actions example wraps the card in a `NavigationLink` to combine it as one focusable element and adds `.accessibilityAction(named: \"Show details\")` to include the Show details accordion in the list of accessibility actions. There is a platform defect using `NavigationLink` and `.accessibilityAction` where the child controls' accessibility labels are not included in the accessibility label of the combined parent element.")
                }.padding([.top,.bottom]).accessibilityHint("Good Example Card with Focus Combined & Accessibility Actions")
                Text("Bad Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                Text("Bad Example Card with incorrect heading placement and no `.accessibilityLabel`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
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
                    Text("The bad example card with incorrect heading placement and no `.accessibilityLabel` example uses a heading element that is not at the top of the card and a generic call to action button with no `.accessibilityLabel`.")
                }.padding([.top,.bottom]).accessibilityHint("Bad Example Card with incorrect heading placement and no .accessibilityLabel")
                Text("Bad Example Card without Focus Combined or Accessibility Actions")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack(alignment: .leading) {
                    HStack {
                        Text("NEW")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(8)
                            .background(colorScheme == .dark ? Color(.white) : Color(.blue))
                            .foregroundColor(colorScheme == .dark ? Color(.black) : Color(.white))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                            .offset(x: -5, y: -5)
                        Spacer()
                        Text("$3.00 off")
                            .font(.largeTitle).bold()
                            .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                            .offset(x: -10, y: 0)
                        Spacer()
                        Spacer()
                    }
                    HStack(alignment: .top) {
                        Image("barber-shop")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 150)
                            .clipped()
                        VStack(alignment: .leading) {
                            Text("$3.00 off any haircut, trim, or shave with purchase of any styling products or shave cream.")
                                .foregroundColor(colorScheme == .dark ? Color(.white) : Color(.black))
                            HStack {
                                VStack {
                                    DisclosureGroup("Show details") {
                                        Text("Must purchase at least one styling or shave cream product. Valid only during time of purchase.")
                                            .foregroundColor(colorScheme == .dark ? Color(.white) : Color(.black))
                                    }
                                    Text("Expires 05/31/24").frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(colorScheme == .dark ? Color(.white) : Color(.black))
                                }
                                Button(action: {
                                    showingAlert = true
                                    }) {
                                        Image(systemName: "plus")
                                            .font(.title.weight(.semibold))
                                            .padding(8)
                                            .background(colorScheme == .dark ? Color(.white) : darkRed)
                                            .foregroundColor(colorScheme == .dark ? darkRed : Color(.white))
                                            .clipShape(Circle())
                                            .shadow(radius: 2, x: 1, y: 2)
                                            .offset(x: 5, y: 5)
                                        
                                    }
                                    .alert("Coupon added to wallet.", isPresented: $showingAlert) {
                                        Button("OK", role: .cancel) {
                                            isTriggerFocused = false
                                        }
                                    } message: {
                                        Text("The coupon has been added to your digital wallet.")
                                    }
                            }
                        }
                    }
                }
                .onTapGesture {
                    showDetailView = true
                }
                .sheet(isPresented: $showDetailView) {
                    DetailView()
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
                    Text("The bad example card without combined focus or accessibility actions example does not combine the card as one focusable element and does not include the Show details accordion in the list of accessibility actions.")
                }.padding([.top,.bottom]).accessibilityHint("Bad Example Card without Focus Combined or Accessibility Actions")

            }
            .navigationTitle("Cards")
            .padding()
        }
 
    }
}
 
struct CardsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CardsView()
        }
    }
}
