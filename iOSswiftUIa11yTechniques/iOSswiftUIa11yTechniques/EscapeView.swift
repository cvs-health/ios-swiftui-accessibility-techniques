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
 
struct EscapeView: View {
    @State var showModal: Bool = false
    @State var showModalBad: Bool = false
    @AccessibilityFocusState private var isDialogHeadingFocused: Bool
    @AccessibilityFocusState private var isDialogBadHeadingFocused: Bool
    @AccessibilityFocusState private var isTriggerFocused: Bool

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("The escape action is built into native dialogs and navigation views and allows VoiceOver users to perform a 2-finger scrub gesture by drawing the letter Z with 2 fingers which then closes the dialog or activates the back button in a navigation view. Use `.accessibilityAction(.escape)` to close a custom dialog or view and return focus when the VoiceOver escape gesture (2 finger Z) is activated.")
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
                Button(action: {
                    showModal.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isDialogHeadingFocused = true
                    }
                }) {
                    Text("Show License Agreement")
                        .accessibilityFocused($isTriggerFocused)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if (showModal){
                    VStack {
                        Text("License Agreement")
                            .font(.title)
                            .padding(.top)
                            .accessibilityAddTraits(.isHeader)
                            .accessibilityFocused($isDialogHeadingFocused)
                        Text("""
                            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
                            """)
                            .padding(20)
                        Button("Dismiss",
                               action: {
                            showModal.toggle()
                            isTriggerFocused = true
                        })
                        .padding(.bottom)
                    }.background(colorScheme == .dark ? Color(.black) : Color(.white))
                        .accessibilityAddTraits(.isModal)
                        .accessibilityAction(.escape) {
                            showModal.toggle()
                            isTriggerFocused = true
                        }
                }
                DisclosureGroup("Details") {
                    Text("The good escape example uses `.accessibilityAction(.escape)` to close the modal and return focus when the VoiceOver escape gesture (2 finger Z) is activated.")
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
                Button(action: {
                    showModalBad.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isDialogBadHeadingFocused = true
                    }
                }) {
                    Text("Show License Agreement")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if (showModalBad){
                    VStack {
                        Text("License Agreement")
                            .font(.title)
                            .padding(.top)
                            .accessibilityAddTraits(.isHeader)
                            .accessibilityFocused($isDialogBadHeadingFocused)
                        Text("""
                            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
                            """)
                            .padding(20)
                        Button("Dismiss",
                               action: {
                            showModalBad.toggle()
                        })
                        .padding(.bottom)
                    }.background(colorScheme == .dark ? Color(.black) : Color(.white))
                }
                DisclosureGroup("Details") {
                    Text("The bad escape example does not use `.accessibilityAction(.escape)` to close the modal and return focus when the VoiceOver escape gesture (2 finger Z) is activated.")
                }.padding(.bottom).accessibilityHint("Bad Example")
            }
            .background(showModal || showModalBad == true ? colorScheme == .dark ? Color(.gray).opacity(0.5) : Color.black.opacity(0.5) : colorScheme == .dark ? Color(.black) : Color(.white))
            .navigationTitle("Escape Action")
            .padding()
        }
 
    }
}
 
struct EscapeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EscapeView()
        }
    }
}
