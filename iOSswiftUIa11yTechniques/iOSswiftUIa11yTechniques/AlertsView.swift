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

struct AlertsView: View {
    @State private var showingAlert = false
    @State private var showingAlertBad = false
    @AccessibilityFocusState private var isTriggerFocused: Bool


    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("VoiceOver focus must move to the alert when displayed and back to the trigger button when the alert is closed. Use `.alert()` to code a native SwiftUI alert that receives VoiceOver focus when opened. Use `AccessibilityFocusState` to send focus back to the trigger button that opened the alert when the alert is closed.")
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
                    showingAlert = true
                }
                .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                .accessibilityFocused($isTriggerFocused)
                .alert("Are you sure you want to delete all messages?", isPresented: $showingAlert) {
                    Button("Cancel", role: .cancel) {
                        isTriggerFocused = true
                    }
//                    if #available(iOS 26.0, *) {
//                        Button ("Do Nothing", role: .confirm) {
//                            isTriggerFocused = true
//                        }
//                    } else {
//                        // Fallback on earlier versions
//                        Button ("Do Nothing") {
//                            isTriggerFocused = true
//                        }
//                    }
                    Button ("Delete All Messages", role: .destructive) {
                        isTriggerFocused = true
                    }
                } message: {
                    Text("You cannot undo deleting all messages!")
                }
                DisclosureGroup("Details") {
                    Text("The good alert example uses `.alert()` to create a native SwiftUI alert that receives VoiceOver focus when displayed. Additionally, `AccessibilityFocusState` is used to send focus back to the trigger button that opened the alert when the alert is closed.")
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
                  showingAlertBad = true
                }
                if (showingAlertBad){
                    VStack {
                        Text("Are you sure you want to delete all messages?")
                            .font(.callout).fontWeight(.bold).padding(.top)
                        Text("You cannot undo deleting all messages!")
                        Button("Delete All Messages", role: .destructive,
                               action: { showingAlertBad = false })
                        .padding()
                        Button("Cancel",
                               action: { showingAlertBad = false }).fontWeight(.bold)
                    }
                }
                DisclosureGroup("Details") {
                    Text("The bad alert example uses a custom view which does not receive VoiceOver focus when displayed and does not return focus when closed.")
                }.accessibilityHint("Bad Example")
            }
            .navigationTitle("Alerts")
            .padding()

        }
 
    }

}
 
struct AlertsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AlertsView()
        }
    }
}
