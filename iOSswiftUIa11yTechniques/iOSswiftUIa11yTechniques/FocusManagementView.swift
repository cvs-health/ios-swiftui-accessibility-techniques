/*
 Copyright 2023-2024 CVS Health and/or one of its affiliates

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

struct FocusManagementView: View {
    @State var showModal: Bool = false
    @State var showModalBad: Bool = false
    @AccessibilityFocusState private var isDialogHeadingFocused: Bool
    @AccessibilityFocusState private var isTriggerFocused: Bool
    @FocusState private var isDismissKeyboardFocused: Bool
    @FocusState private var isTriggerKeyboardFocused: Bool


    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Focus Management is required when displaying custom dialogs or views. Use `.accessibilityFocused` to move VoiceOver focus when opening and closing custom dialogs or views. Use `.accessibilityAddTraits(.isModal)` to trap VoiceOver focus inside a custom modal dialog. Use `.accessibilityAction(.escape)` to close a custom dialog or view and return focus when the VoiceOver escape gesture (2 finger Z) is activated. Use `.accessibilityElement(children: .ignore)` to prevent keyboard focus of elements behind a modal dialog. See Text Fields Focus Management below to learn how to return focus after dismissing the keyboard.")
                NavigationLink(destination: TextFieldsFocusManagement()) {
                    Text("Text Fields Focus Management")
                }.padding().frame(maxWidth:.infinity, alignment:.leading)
                    .accessibilityElement(children: showModal ? .ignore : .contain)
                Text("Good Example")
                   .font(.subheadline)
                   .fontWeight(.bold)
                   .frame(maxWidth:.infinity, alignment:.leading)
                   .accessibilityAddTraits(.isHeader)
                   .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                   .frame(height: 2.0, alignment:.leading)
                   .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                   .padding(.bottom)
                Button(action: {
                    showModal.toggle()
                    DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                        isDialogHeadingFocused = true
                        isTriggerKeyboardFocused = false
                        isDismissKeyboardFocused = true
                    }
                }) {
                    Text("Show License Agreement")
                }
                .accessibilityFocused($isTriggerFocused)
                .focused($isTriggerKeyboardFocused)
                .accessibilityElement(children: showModal ? .ignore : .contain)
               .frame(maxWidth:.infinity, alignment:.leading)
                DisclosureGroup("Details") {
                    Text("The good focus management example uses `.accessibilityFocused` to set VoiceOver focus to the dialog heading when it's opened and back to the dialog trigger button when it's closed. `.accessibilityAddTraits(.isModal)` is used to trap VoiceOver focus inside the modal dialog and prevent focus of the grayed out content under the modal. `.accessibilityAction(.escape)` is used to close the modal and return focus when the VoiceOver escape gesture (2 finger Z) is activated. `.accessibilityElement(children: .ignore)` is used to prevent keyboard focus of elements behind the modal dialog.")
                }.padding(.bottom).accessibilityHint("Good Example")
                Text("Bad Example")
                   .font(.subheadline)
                   .fontWeight(.bold)
                   .frame(maxWidth:.infinity, alignment:.leading)
                   .accessibilityAddTraits(.isHeader)
                   .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                   .frame(height: 2.0, alignment:.leading)
                   .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                   .padding(.bottom)
                Button(action: {
                    showModalBad.toggle()
                }) {
                    Text("Show License Agreement")
                }
               .frame(maxWidth:.infinity, alignment:.leading)
                DisclosureGroup("Details") {
                    Text("The bad focus management example does not set VoiceOver focus to the dialog heading when it's opened or back to the dialog trigger button when it's closed. VoiceOver focus is not trapped inside the modal dialog and can focus on the grayed out content under the modal. VoiceOver users can't close the modal and return focus when the VoiceOver escape gesture (2 finger Z) is activated. Keyboard focus can move to elements behind the modal dialog.")
                }.padding(.bottom).accessibilityHint("Bad Example")
            }
           .navigationTitle("Focus Management")
           .padding()
           .accessibilityElement(children: showModal ? .ignore : .contain)
        }
        .background(showModal || showModalBad == true ? colorScheme == .dark ? Color(.gray).opacity(0.5) : Color.black.opacity(0.5) : colorScheme == .dark ? Color(.black) : Color(.white))
        .overlay(
            Group {
                if showModal {
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
                            DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                isTriggerFocused = true
                                isTriggerKeyboardFocused = true
                            }
                        })
                       .padding(.bottom)
                       .focused($isDismissKeyboardFocused)
                    }.background(colorScheme == .dark ? Color(.black) : Color(.white))
                       .accessibilityAddTraits(.isModal)
                       .accessibilityAction(.escape) {
                            showModal.toggle()
                           DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                               isTriggerFocused = true
                           }
                        }
                        .zIndex(1)
                }
                if showModalBad {
                    VStack {
                        Text("License Agreement")
                           .font(.title)
                           .padding(.top)
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
                        .zIndex(1)
                }
            }
        )
    }
}


struct FocusManagementView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FocusManagementView()
        }
    }
}
