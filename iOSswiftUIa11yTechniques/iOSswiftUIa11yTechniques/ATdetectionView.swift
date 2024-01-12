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

struct ATdetectionView: View {
    @State private var showingAlert = false
    @State private var showingAlertBad = false
    @AccessibilityFocusState private var isTriggerFocused: Bool


    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Detecting assistive technology running on a user's device is not recommended because it may lead to creating unequal experiences between all users. However, sometimes it may be necessary to detect if an assistive technology is running, for example, if you need to provide a specific message to VoiceOver users only.")
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
                if (UIAccessibility.isVoiceOverRunning){
                    Text("VoiceOver was turned on when the page loaded.")
                }
                if (!UIAccessibility.isVoiceOverRunning){
                    Text("VoiceOver was turned off when this page loaded.")
                }
                DisclosureGroup("Details") {
                    Text("The good alert example uses `.alert()` to create a native SwiftUI alert that receives VoiceOver focus when displayed. Additionally, `AccessibilityFocusState` is used to send focus back to the trigger button that opened the alert when the alert is closed.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
            }.onAppear {
                if UIAccessibility.isVoiceOverRunning {
                    showingAlert = true
                } else {
                    showingAlert = false
                }
            }
            .alert("VoiceOver is turned on!", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {
                    isTriggerFocused = true
                }
            } message: {
                Text("This application uses VoiceOver Accessibility Hints to improve the accessibility of controls so if a control does not appear to be fully accessible to VoiceOver please make sure you have not disabled VoiceOver Hints.")
            }
            .navigationBarTitle("Assistive Technology Detection")
            .padding()

        }
 
    }

}
 
struct ATdetectionView_Previews: PreviewProvider {
    static var previews: some View {
        ATdetectionView()
    }
}
