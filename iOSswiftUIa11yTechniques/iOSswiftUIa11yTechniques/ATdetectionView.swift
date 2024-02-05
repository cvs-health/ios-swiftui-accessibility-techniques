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
                Text("Detecting assistive technology running on a user's device is not recommended because it may lead to creating unequal experiences between all users. However, sometimes it may be necessary to detect if an assistive technology is running, for example, if you need to provide a specific message to VoiceOver users only. e.g., using `UIAccessibility.isVoiceOverRunning` to check if VoiceOver is running when the page loads and then show an alert reminding the VoiceOver user not to disable VoiceOver Hints. All of the iOS assistive technologies can be detected, i.e., using `UIAccessibility.is{AsstiveTechnology}Running` and replacing `{AsstiveTechnology}` with the name of the assistive technology you're detecting.")
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
                Text("If VoiceOver was running when you loaded this page then an alert would have displayed.").padding(.bottom)
                if (UIAccessibility.isVoiceOverRunning){
                    Text("VoiceOver was turned on when this page loaded.").font(.title)
                }
                if (!UIAccessibility.isVoiceOverRunning){
                    Text("VoiceOver was turned off when this page loaded.").font(.title)
                }
                DisclosureGroup("Details") {
                    Text("The good assistive technology detection example uses `UIAccessibility.isVoiceOverRunning` check if VoiceOver is running when the page loads and then shows an alert reminding the VoiceOver user not to disable VoiceOver Hints.")
                }.padding()
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
            .navigationTitle("Assistive Technology Detection")
            .padding()

        }
 
    }

}
 
struct ATdetectionView_Previews: PreviewProvider {
    static var previews: some View {
        ATdetectionView()
    }
}
