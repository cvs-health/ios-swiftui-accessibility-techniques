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
 
struct FunctionalView: View {
    
    @AccessibilityFocusState private var isTriggerFocused: Bool
    @State private var showingAlert = false
    @State private var showingAlertImage = false
    @State private var isSuperFavorite = false
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
 
    var body: some View {
        ScrollView {
            VStack {
                Text("Functional images are actionable images used as buttons or links. Functional images need accessibility labels that describe their function rather than their appearance. Use an `.accessibilityLabel` if the functional image has no visible text.")
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
                Text("Good Example `Image` `Button` `.accessibilityLabel`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button(action: {
                    showingAlert = true
                }) {
                    Image(systemName: "barcode.viewfinder")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 44, height: 44)
                        .accessibilityLabel("Scan barcode")
                }
                .accessibilityFocused($isTriggerFocused)
                .accessibilityIdentifier("goodImage")
                .alert("Button Activated", isPresented: $showingAlert) {
                    Button("OK", role: .cancel) {
                        isTriggerFocused = true
                    }
                } message: {
                    Text("You activated the button!")
                }
                DisclosureGroup("Details") {
                    Text("The good functional image example uses an image button with `.accessibilityLabel(\"Scan barcode\"))` to give the button a meaningful accessibility label that describes its purpose to VoiceOver users.")
                }.padding(.bottom).accessibilityHint("Good Example `Image` `Button` `.accessibilityLabel`")
                if #available(iOS 18.0, *) {
                    Text("iOS 18+ Good Example `Image` `Button` `accessibilityLabel(_:isEnabled:)`")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityAddTraits(.isHeader)
                    Button(action: {
                        isSuperFavorite.toggle()
                    }) {
                        Image(systemName: isSuperFavorite ? "sparkles" : "star.fill")
                    }
                    .accessibilityLabel("Super Favorite", isEnabled: isSuperFavorite)
                    DisclosureGroup("Details") {
                        Text("The iOS 18+ good example image button uses `accessibilityLabel(_:isEnabled:)` to change the accessibility label to be \"Super Favorite\" when toggled and use the default SF Symbols VoiceOver label of \"Favorite\" when not toggled.")
                    }.padding(.bottom).accessibilityHint("iOS 18+ Good Example `Image` `Button` `accessibilityLabel(_:isEnabled:)`")
                }
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
                Text("Bad Example `Image` `Button` no `.accessibilityLabel`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button(action: {
                    showingAlert = true
                }) {
                    Image("barcode.viewfinder")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 44, height: 44)
                }
                .accessibilityIdentifier("badImage1")
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Button Activated"), message: Text("You activated the button!"), dismissButton: .default(Text("OK")))
                }
                DisclosureGroup("Details") {
                    Text("The bad functional image example uses no `.accessibilityLabel` to give the image button a meaningful accessibility label causing VoiceOver to read the image filename \"barcode.viewfinder\" as the name of the button.")
                }.padding(.bottom).accessibilityHint("Bad Example `Image` `Button` no `.accessibilityLabel`")
                Text("Bad Example `Image` `TapGesture()` no `.accessibilityLabel`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack {
                    Image("barcode.viewfinder")
                        .resizable()
                        .frame(width: 44, height: 44)
                        .gesture(TapGesture().onEnded {
                            showingAlertImage = true
                        })
                        .accessibilityIdentifier("badImage2")
                }
                .alert(isPresented: $showingAlertImage) {
                    Alert(title: Text("Image Tapped"), message: Text("You tapped the image!"), dismissButton: .default(Text("OK")))
                }
                DisclosureGroup("Details") {
                    Text("The second bad functional image example is incorrectly coded as an `Image` element with a `TapGesture` rather than as a `Button` which prevents VoiceOver users from hearing the \"Button\" trait spoken and they won't know the image is an actionable control. There is also no `.accessibilityLabel`.")
                }.padding(.bottom).accessibilityHint("Bad Example `Image` `TapGesture()` no `.accessibilityLabel`")
            }
            .navigationTitle("Functional Images")
            .padding()
        }
    }
}
 
struct FunctionalView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FunctionalView()
        }
    }
}
