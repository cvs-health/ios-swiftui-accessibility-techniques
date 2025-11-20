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
import TipKit


struct TipKitView: View {
    // Define your tip's content.
    struct FavoriteLandmarkTip: Tip {
        var title: Text { Text("Save as a Favorite") }
        var message: Text? { Text("Your favorite landmarks always appear at the top of the list.") }
        var image: Image? { Image(systemName: "star") }
    }
    struct FavoriteLandmarkTipBad: Tip {
        var title: Text { Text("Save as a Favorite") }
        var message: Text? { Text("Your favorite landmarks always appear at the top of the list.") }
        var image: Image? { Image(systemName: "star") }
    }
    // Create an instance of your tip.
    var favoriteLandmarkTip = FavoriteLandmarkTip()
    var favoriteLandmarkTipBad = FavoriteLandmarkTipBad()

    
    struct PasswordResetTip: Tip {
        var title: Text {
            Text("Need Help?")
        }


        var message: Text? {
            Text("Do you need help logging in to your account?")
        }


        var image: Image? {
            Image(systemName: "lock.shield")
        }


        var actions: [Action] {
            // Define a reset password button.
            Action(id: "reset-password", title: "Reset Password")
            // Define a FAQ button.
            Action(id: "faq", title: "View our FAQ")
        }
    }
    
    @Environment(\.openURL) var openURL

    // Create an instance of your tip content.
    let passwordResetTip = PasswordResetTip()


    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    @AccessibilityFocusState private var isTriggerFocused: Bool
    @AccessibilityFocusState private var isTriggerFocused2: Bool

    
    var body: some View {
        ScrollView {
            VStack {

                Text("`TipKit` is used to show popovers that point to controls on the page to explain their purpose to the user. Add an `.accessibilityLabel` or `.accessibilityHint` to give the `TipView` a unique label or hint to explain Tip's purpose to VoiceOver users. Use `AccessibilityFocusState` to return focus to the Tip's control when dismissed.")
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
                VStack {
                    // Place the tip view near the feature you want to highlight.
                    TipView(favoriteLandmarkTip, arrowEdge: .bottom)
                        .accessibilityLabel("Save as a Favorite Tip Dialog")
                        .accessibilityHint("Explains how to save a landmark as a favorite")
                        .onDisappear(){
                            isTriggerFocused = true
                        }
                    Button(action: {
                        // Handle button action
                    }) {
                        Image(systemName: "star")
                            .imageScale(.large)
                    }
                    .accessibilityLabel("Favorite")
                    .accessibilityFocused($isTriggerFocused)

                }
                .task {
                    do {
                        // Configure TipKit with immediate display frequency
                        try Tips.configure([
                            .displayFrequency(.immediate)
                        ])
                        
                        // Reset all tips so they appear fresh every time
                        try Tips.resetDatastore()
                    } catch {
                        print("Error initializing TipKit: \(error)")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                VStack(spacing: 20) {
                            Text("`TipView` action buttons.")
                            
                            // Place your tip near the feature you want to highlight.
                            TipView(passwordResetTip, arrowEdge: .bottom) { action in
                                // Define the closure that executes when someone presses the reset button.
                                if action.id == "reset-password", let url = URL(string: "https://iforgot.apple.com") {
                                    openURL(url) { accepted in
                                        print(accepted ? "Success Reset" : "Failure")
                                    }
                                }


                                // Define the closure that executes when someone presses the FAQ button.
                                if action.id == "faq", let url = URL(string: "https://appleid.apple.com/faq") {
                                    openURL(url) { accepted in
                                        print(accepted ? "Success FAQ" : "Failure")
                                    }
                                }
                            }
                            .accessibilityLabel("Need Help? Tip Dialog")
                            .accessibilityHint("Includes Reset Password and View our FAQ links")
                            .onDisappear(){
                                isTriggerFocused2 = true
                            }
                            Button("Login") {
                                // Perform login action.
                            }
                            .accessibilityFocused($isTriggerFocused2)
                            Spacer()
                        }
                        .padding()
                DisclosureGroup("Details") {
                    Text("The good `TipKit` example uses `.accessibilityLabel` and `.accessibilityHint` to provide a unique label and hint for the `TipView`. `AccessibilityFocusState` is used to send VoiceOver focus to the tip's control after it is closed.")
                }.padding(.bottom).accessibilityHint("Good Example")
                Text("Bad Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                VStack {
                    // Place the tip view near the feature you want to highlight.
                    TipView(favoriteLandmarkTipBad, arrowEdge: .bottom)
                    Button(action: {
                        // Handle button action
                    }) {
                        Image(systemName: "star")
                            .imageScale(.large)
                    }
                }
                .task {
                    do {
                        // Configure TipKit with immediate display frequency
                        try Tips.configure([
                            .displayFrequency(.immediate)
                        ])
                        
                        // Reset all tips so they appear fresh every time
                        try Tips.resetDatastore()
                    } catch {
                        print("Error initializing TipKit: \(error)")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                DisclosureGroup("Details") {
                    Text("The bad `TipKit` example has no `.accessibilityLabel` or `.accessibilityHint` to make the Tip unique for VoiceOver users. There is no `AccessibilityFocusState` focus management used to send focus to the Tip's control when it is closed.")
                }.padding(.bottom).accessibilityHint("Bad Example")

            }
            .navigationTitle("TipKit")
            .padding()
        }
 
    }

}
 
#Preview {
    NavigationStack {
        TipKitView()
    }
}
