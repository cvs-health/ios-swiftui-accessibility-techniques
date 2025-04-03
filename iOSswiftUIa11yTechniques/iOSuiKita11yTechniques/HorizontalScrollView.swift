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


 
struct HorizontalScrollView: View {
    var card1body = "Sign up for our newsletter and get 10% off first purchase. We'll email your code."
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var offset: CGFloat = 0

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Your Width")
                    Text(UIScreen.main.bounds.size.width.description)
                    Text("Height")
                    Text(UIScreen.main.bounds.size.height.description)
                }
                Text("WCAG's Reflow success criterion requires no horizontal scrolling for vertically scrolling content at a width of 320 pixels or less. When horizontal scrolling is used then it must have single tap alternatives to the gestures used to scroll the content.")
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
                let layout = (UIScreen.main.bounds.size.width <= 320) ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())
                if UIScreen.main.bounds.size.width <= 320 {
                } else {
                    HStack {
                        Spacer()
                        Button("⬅️") {
                            withAnimation {
                                offset += 150
                            }
                        }.frame(height:24)
                            .accessibilityLabel("Scroll Left")
                        Button("➡️") {
                            withAnimation {
                                offset -= 150
                            }
                        }.frame(height:24)
                            .accessibilityLabel("Scroll Right")
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                ScrollView(UIScreen.main.bounds.size.width <= 320 ? .vertical : .horizontal) {
                    layout {
                        ForEach(0..<10) { i in
                            Button(action: {
                                // Handle button action
                            }) {
                                Text(UIScreen.main.bounds.size.width <= 320 ? "Vertical Button \(i)" : "Horizontal Button \(i)")
                                    .padding()
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.green)
                                    .shadow(color: .gray, radius: 1, x: 0, y: 2)
                            )
                            .buttonStyle(PlainButtonStyle())
                            .foregroundColor(colorScheme == .dark ? Color.black : Color.black)
                        }
                    }
                    .scrollTargetLayout()
                    .offset(x: UIScreen.main.bounds.size.width <= 320 ? 0 : offset)
                }
                .scrollTargetBehavior(.viewAligned)
                .safeAreaPadding(.horizontal, 40)
                DisclosureGroup("Details") {
                    Text("The good example switches from horizontal scrolling to a vertically stacked layout when the screen width is 320 or less. When horizontal scrolling is present there are right and left arrow buttons that can be tapped to scroll right and left without using gestures.")
                }.padding(.bottom)
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
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(0..<10) { i in
                            Button(action: {
                                // Handle button action
                            }) {
                                Text("Horizontal Button \(i)")
                                    .padding()
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.green)
                                    .shadow(color: .gray, radius: 1, x: 0, y: 2)
                            )
                            .buttonStyle(PlainButtonStyle())
                            .foregroundColor(colorScheme == .dark ? Color.black : Color.black)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .safeAreaPadding(.horizontal, 40)
                Spacer().padding()
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(0..<10) { i in
                            VStack(alignment: .leading) {
                                Text("Card \(i)")
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
                            .frame(maxWidth: UIScreen.main.bounds.width - 100, maxHeight: 300)
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
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .safeAreaPadding(.horizontal, 40)
                DisclosureGroup("Details") {
                    Text("The bad examples always display as horizontal scrolling regardless of screen width. There are no right and left arrow buttons that can be tapped to scroll right and left without using gestures.")
                }.padding(.bottom)
            }
            .navigationTitle("Horizontal Scroll Views")
            .padding()
        }
 
    }
}
 
#Preview {
    NavigationStack {
        HorizontalScrollView()
    }
}

