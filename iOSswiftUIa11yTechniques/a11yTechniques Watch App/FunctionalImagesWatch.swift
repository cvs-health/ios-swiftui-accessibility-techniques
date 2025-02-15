/*
   Copyright 2025 CVS Health and/or one of its affiliates

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

struct FunctionalImagesWatch: View {
    
    @AccessibilityFocusState private var isTriggerFocused: Bool
    @State private var showingAlert = false
    @State private var showingAlertImage = false
    @State private var isSuperFavorite = false
    let darkBlue = Color(red: 26/255, green: 115/255, blue: 206/255)
    
    var body: some View {
        ScrollView {
            Text("Functional images are actionable images used as buttons or links. Functional images need accessibility labels that describe their function rather than their appearance. Use an `.accessibilityLabel` if the functional image has no visible text.")
            Text("Good Examples")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h2)
                .foregroundColor(.green)
            Divider()
                .frame(height: 2.0, alignment:.leading)
                .background(.green)
                .padding(.bottom)
            Text("`Image` `Button` `.accessibilityLabel`")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
            Button(action: {
                showingAlert = true
            }) {
                Image(systemName: "tray.and.arrow.down")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 44)
                    .accessibilityLabel("Download files")
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
            NavigationLink(destination: DetailFunctionalGood()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("`Image` `Button` `.accessibilityLabel`")
                .buttonStyle(.plain)
                .padding(.bottom)
            if #available(watchOS 11.0, *) {
                Text("`.accessibilityLabel(_:isEnabled:)`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h3)
                Button(action: {
                    isSuperFavorite.toggle()
                }) {
                    Image(systemName: isSuperFavorite ? "sparkles" : "star.fill")
                }
                .accessibilityLabel("Super Favorite", isEnabled: isSuperFavorite)
                NavigationLink(destination: DetailFunctionalGood2()) {
                    Text("Details")
                        .frame(maxWidth: .infinity)
                        .padding(15)
                        .background(darkBlue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                    .accessibilityHint(".accessibilityLabel(_:isEnabled:)")
                    .buttonStyle(.plain)
                    .padding(.bottom)
            }
            Text("Bad Examples")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h2)
                .foregroundColor(.red)
            Divider()
                .frame(height: 2.0, alignment:.leading)
                .background(.red)
                .padding(.bottom)
            Text("No `Image` `Button` `.accessibilityLabel`")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
            Button(action: {
                showingAlert = true
            }) {
                Image(systemName: "tray.and.arrow.down")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 44)
            }
            .accessibilityIdentifier("badImage")
            .alert("Button Activated", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {
                }
            } message: {
                Text("You activated the button!")
            }
            NavigationLink(destination: DetailFunctionalBad()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("No `Image` `Button` `.accessibilityLabel`")
                .buttonStyle(.plain)
                .padding(.bottom)
            Text("`Image` `TapGesture()` no `.accessibilityLabel`")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
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
            NavigationLink(destination: DetailFunctionalBad2()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("`Image` `TapGesture()` no `.accessibilityLabel`")
                .buttonStyle(.plain)

        }
    }
}

struct DetailFunctionalGood: View {
    var body: some View {
        ScrollView {
            Text("The good functional image example uses an image button with `.accessibilityLabel(\"Download files\")` to give the button a meaningful accessibility label that describes its purpose to VoiceOver users.")
        }
            .navigationTitle("`Image` `Button` `.accessibilityLabel`")
    }
}
struct DetailFunctionalGood2: View {
    var body: some View {
        ScrollView {
            Text("The iOS 18+ good example image button uses `accessibilityLabel(_:isEnabled:)` to change the accessibility label to be \"Super Favorite\" when toggled and use the default SF Symbols VoiceOver label of \"Favorite\" when not toggled.")
        }
            .navigationTitle("`.accessibilityLabel(_:isEnabled:)`")
    }
}
struct DetailFunctionalBad: View {
    var body: some View {
        ScrollView {
            Text("The bad functional image example uses no `.accessibilityLabel` to give the image button a meaningful accessibility label causing VoiceOver to read the default image name \"Inbox\" as the name of the button.")
        }
        .navigationTitle("No `Image(decorative:)`")
    }
}
struct DetailFunctionalBad2: View {
    var body: some View {
        ScrollView {
            Text("The second bad functional image example is incorrectly coded as an `Image` element with a `TapGesture` rather than as a `Button` which prevents VoiceOver users from hearing the \"Button\" trait spoken and they won't know the image is an actionable control. There is also no `.accessibilityLabel`.")
        }
        .navigationTitle("No `.accessibilityHidden(true)`")
    }
}

#Preview {
    NavigationStack {
        FunctionalImagesWatch()
    }
}
