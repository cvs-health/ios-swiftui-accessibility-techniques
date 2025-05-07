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
 
struct ResponsiveLayoutsView: View {
    
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var card1body = "Sign up for our newsletter and get 10% off first purchase. We'll email your code."
    var card2body = "Save on summer go‐tos when you choose same‐day delivery or FREE pickup."
    var card3body = "Get same-day delivery on your orders when you checkout before 4pm."

    var body: some View {
        ScrollView {
            VStack {
                Text("Use size classes to create layouts that respond to the user's screen size and device orientation to present a more usable view. Make sure that text is readable in landscape and portrait orientations.")
                Text("Your Device Size Class:")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                    .frame(maxWidth: .infinity, alignment: .leading)
                //this code from https://github.com/renaudjenny/SwiftUI-with-Size-Classes
                if verticalSizeClass == .regular && horizontalSizeClass == .compact {
                    // iPhone Portrait or iPad 1/3 split view for Multitasking for instance
                    Text("verticalSizeClass == .regular && horizontalSizeClass == .compact")
                } else if verticalSizeClass == .compact && horizontalSizeClass == .compact {
                    // some "standard" iPhone Landscape (iPhone SE, X, XS, 7, 8, ...)
                    Text("verticalSizeClass == .compact && horizontalSizeClass == .compact")
                } else if verticalSizeClass == .compact && horizontalSizeClass == .regular {
                    // some "bigger" iPhone Landscape (iPhone Xs Max, 6s Plus, 7 Plus, 8 Plus, ...)
                    Text("verticalSizeClass == .compact && horizontalSizeClass == .regular")
                } else if verticalSizeClass == .regular && horizontalSizeClass == .regular {
                    // macOS or iPad without split view - no Multitasking
                    Text("verticalSizeClass == .regular && horizontalSizeClass == .regular")
                }
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
                let layout = (horizontalSizeClass == .regular && verticalSizeClass == .regular || verticalSizeClass == .compact && horizontalSizeClass == .compact || verticalSizeClass == .compact && horizontalSizeClass == .regular) ? AnyLayout(HStackLayout()) : AnyLayout(VStackLayout())
                layout {
                    VStack(alignment: .leading) {
                        Text("Sign Up for Newsletter")
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)
                        Image("get10off")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 130)
                            .accessibilityLabel("Get 10% off")
                        Text(card1body)
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
                    .accessibilityElement(children: .contain)
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
                    VStack(alignment: .leading) {
                        Text("Get 20% off with code SUMMER20")
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)
                        Text("🏖️")
                            .font(.system(size: 100))
                        Text(card2body)
                        Button(action: {
                            print("Your action function here")
                        }) {
                            Text("Shop Now").font(.headline)
                        }
                        .accessibilityLabel("Shop Now for summer essentials")
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.green)
                                .shadow(color: .gray, radius: 1, x: 0, y: 2)
                        )
                        .foregroundColor(colorScheme == .dark ? Color.black : Color.black)
                        .buttonStyle(PlainButtonStyle())
                    }
                    .accessibilityElement(children: .contain)
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
                    VStack(alignment: .leading) {
                        Text("Get Same-Day Delivery")
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)
                        Text("🚚")
                            .font(.system(size: 100))
                        Text(card3body)
                        Button(action: {
                            print("Your action function here")
                        }) {
                            Text("Deliver Today").font(.headline)
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
                    .accessibilityElement(children: .contain)
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
                    Text("The good example presents 3 cards in a vertical stack for iPhones in portrait orientation and a horizontal stack for iPhones in landscape orientation and iPads in both orientations. The cards have adequate spacing and readable text in both orientations on iPad and iPhone.")
                }.padding(.bottom).accessibilityHint("Good Example")
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
                HStack {
                    VStack(alignment: .leading) {
                        Text("Sign Up for Newsletter")
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)
                            .lineLimit(2)
                        Image("get10off")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 140)
                            .accessibilityLabel("Get 10% off")
                        ScrollView {
                            Text(card1body)
                        }
                        .frame(maxWidth:.infinity, maxHeight: 130)
                        Button(action: {
                            print("Your action function here")
                        }) {
                            Text("Sign Up").font(.headline)
                                .lineLimit(1)
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
                    VStack(alignment: .leading) {
                        Text("Get 20% off with code SUMMER20")
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)
                            .lineLimit(2)
                        Text("🏖️")
                            .font(.system(size: 100))
                        ScrollView {
                            Text(card2body)
                        }
                        .frame(maxWidth:.infinity, maxHeight: 130)
                        Button(action: {
                            print("Your action function here")
                        }) {
                            Text("Shop Now").font(.headline)
                                .lineLimit(1)
                        }
                        .accessibilityLabel("Shop Now for summer essentials")
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
                    VStack(alignment: .leading) {
                        Text("Get Same-Day Delivery")
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)
                            .lineLimit(2)
                        Text("🚚")
                            .font(.system(size: 100))
                        ScrollView {
                            Text(card3body)
                        }
                        .frame(maxWidth:.infinity, maxHeight: 130)
                        Button(action: {
                            print("Your action function here")
                        }) {
                            Text("Deliver Today").font(.headline)
                                .lineLimit(1)
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
                }
                DisclosureGroup("Details") {
                    Text("The bad example presents 3 cards in a horizontal stack in both portrait and landscape orientation on both iPhone and iPad. The cards have inadequate spacing and truncated text in portrait orientation on iPhone. The card body text is placed in a ScrollView preventing the full text from being readable without scrolling when shown in portrait orientation on iPhone.")
                }.padding(.bottom).accessibilityHint("Bad Example")
            }
            .padding()
            .navigationTitle("Responsive Layouts")
        }
 
    }
}
 
struct ResponsiveLayoutsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ResponsiveLayoutsView()
        }
    }
}
