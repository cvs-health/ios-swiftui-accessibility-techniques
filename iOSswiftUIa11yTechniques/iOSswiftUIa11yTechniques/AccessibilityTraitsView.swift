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

struct AccessibilityTraitsListView: View {
    let traits: [(name: String, trait: AccessibilityTraits, iOSAvailable: Double)] = [
        ("Button", .isButton, 0),
        ("Header", .isHeader, 0),
        ("Selected", .isSelected, 0),
        ("Link", .isLink, 0),
        ("Search Field", .isSearchField, 0),
        ("Image", .isImage, 0),
        ("Plays Sound", .playsSound, 0),
        ("Keyboard Key", .isKeyboardKey, 0),
        ("Static Text", .isStaticText, 0),
        ("Summary Element", .isSummaryElement, 0),
        ("Updates Frequently", .updatesFrequently, 0),
        ("Starts Media Session", .startsMediaSession, 0),
        ("Allows Direct Interaction", .allowsDirectInteraction, 0),
        ("Causes Page Turn", .causesPageTurn, 0),
        //("Modal", .isModal, 0), //will trap the focus
        ("Toggle", {
            if #available(iOS 17, *) { return .isToggle }
            else { return .isButton } // fallback
        }(), 17),
        ("Tab Bar", {
            if #available(iOS 17, *) { return .isTabBar }
            else { return .isButton } // fallback
        }(), 17)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
               
                ForEach(traits, id: \.name) { item in
                    Text(item.name)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(itemAvailable(item) ? Color.blue.opacity(0.3) : Color.gray.opacity(0.3))
                        .cornerRadius(8)
                        .accessibilityAddTraits(item.trait)
                }
            }
            .padding()
            .navigationTitle("List of Accessibility Traits (except .isModal)")
        }
    }
    
    private func itemAvailable(_ item: (name: String, trait: AccessibilityTraits, iOSAvailable: Double)) -> Bool {
        if #available(iOS 17, *) { return true }
        return item.iOSAvailable <= 16.9
    }
}

struct AccessibilityTraitsView: View {
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    @AccessibilityFocusState private var isTriggerFocused: Bool
    @State private var showingAlertImage = false

    
    var body: some View {
        ScrollView {
            VStack {
                Text("Accessibility Traits are used to manually add roles and states to custom UI controls. Standard native controls already include accessibility traits by default.")
                NavigationLink("Accessibility Traits List (except .isModal)", destination: AccessibilityTraitsListView())
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
                VStack {
                    Image("barcode.viewfinder")
                        .resizable()
                        .frame(width: 44, height: 44)
                        .gesture(TapGesture().onEnded {
                            showingAlertImage = true
                        })
                        .accessibilityAddTraits(.isButton)
                        .accessibilityLabel("Scan Barcode")
                }
                .alert(isPresented: $showingAlertImage) {
                    Alert(title: Text("Image Tapped"), message: Text("You tapped the image!"), dismissButton: .default(Text("OK")))
                }
                DisclosureGroup("Details") {
                    Text("The good example uses an `Image` with a `TapGesture` and adds the `.isButton` Trait to make it speak a Button role to VoiceOver.")
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
                VStack {
                    Image("barcode.viewfinder")
                        .resizable()
                        .frame(width: 44, height: 44)
                        .gesture(TapGesture().onEnded {
                            showingAlertImage = true
                        })
                        .accessibilityLabel("Scan Barcode")
                }
                .alert(isPresented: $showingAlertImage) {
                    Alert(title: Text("Image Tapped"), message: Text("You tapped the image!"), dismissButton: .default(Text("OK")))
                }
                DisclosureGroup("Details") {
                    Text("The bad example uses an `Image` with a `TapGesture` but has no Button Trait to make it speak a Button role to VoiceOver.")
                }.padding(.bottom).accessibilityHint("Bad Example")
            }
            .navigationTitle("Accessibility Traits")
            .padding()
        }
 
    }
}


#Preview {
    NavigationStack {
        AccessibilityTraitsView()
    }
}
