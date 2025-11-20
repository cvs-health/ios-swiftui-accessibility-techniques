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

struct ConfirmationDialogsView: View {
    @State private var isPresentingDialog = false
    @State private var isPresentingBadDialog = false
    @AccessibilityFocusState private var isTriggerFocused: Bool


    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("VoiceOver focus must move to the confirmation dialog when displayed. Use `.confirmationDialog()` to code a native SwiftUI confirmation dialog that receives VoiceOver focus when displayed. Use `AccessibilityFocusState` to send focus back to the trigger button that opened the dialog when the dialog is closed.")
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
                Button("Delete All Messages", role: .destructive) {
                  isPresentingDialog = true
                }
                .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                .accessibilityFocused($isTriggerFocused)
               .confirmationDialog("Are you sure you want to delete all messages?",
                                   isPresented: $isPresentingDialog, titleVisibility: .visible) {
                 Button("Delete All Messages", role: .destructive) {
                     isTriggerFocused = true
                  }
                 Button("Cancel", role: .cancel) {
                     isTriggerFocused = true
                 }
                } message: {
                    Text("You cannot undo deleting all messages!")
                  }
                DisclosureGroup("Details") {
                    Text("The good confirmation dialog example uses `.confirmationDialog()` to create a native SwiftUI confirmation dialog that receives VoiceOver focus when displayed. `AccessibilityFocusState` is used to send focus back to the trigger button that opened the dialog when the dialog is closed.")
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
                Button("Delete All Messages", role: .destructive) {
                  isPresentingBadDialog = true
                }
                if (isPresentingBadDialog){
                    VStack {
                        Text("Are you sure you want to delete all messages?")
                            .font(.callout).fontWeight(.bold).padding(.top)
                        Text("You cannot undo deleting all messages!")
                        Button("Delete All Messages", role: .destructive,
                               action: { isPresentingBadDialog = false })
                        .padding()
                        Button("Cancel",
                               action: { isPresentingBadDialog = false }).fontWeight(.bold)
                    }
                }
                DisclosureGroup("Details") {
                    Text("The bad confirmation dialog example uses a custom view which does not receive VoiceOver focus when displayed. `AccessibilityFocusState` is not used to send focus back to the trigger button that opened the dialog when the dialog is closed.")
                }.accessibilityHint("Bad Example")
            }
            .navigationTitle("Confirmation Dialogs")
            .padding()
        }
 
    }

}
 
struct ConfirmationDialogsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ConfirmationDialogsView()
        }
    }
}
