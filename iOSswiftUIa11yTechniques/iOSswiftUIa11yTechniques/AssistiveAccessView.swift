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

struct AssistiveAccessView: View {
    @State private var showingAlert = false
    @State private var showingAlertBad = false
    @AccessibilityFocusState private var isTriggerFocused: Bool


    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Assistive Access simplifies the iOS experience for users with cognitive disabilities. Use `UISupportsFullScreenInAssistiveAccess` for the app to appear as full screen in Assistive Access. Add the \"Supports full screen in Assistive Access\" Boolean property with the value `YES` to your `Info.plist` which is: `<key>UISupportsFullScreenInAssistiveAccess</key>`\n `<true/>` \n if editing the `Info.plist` source code. Do not used fixed screen sizes in the app.")
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
                Text("This app supports Assistive Access which allows the UI to expand into all available space above the Back button.")
                DisclosureGroup("Details") {
                    Text("The good assistive access example uses `<key>UISupportsFullScreenInAssistiveAccess</key>`\n `<true/>`\n on the `Info.plist` so the app appears as full screen in Assistive Access. Fixed screen sizes are not used in the app.")
                }.padding(.bottom).accessibilityHint("Good Example")
                Text("To learn more about supporting Assistive Access in your app, visit the `UISupportsFullScreenInAssistiveAccess` Apple Developer Documentation link below:").padding(.bottom)
                Link(destination: URL(string: "https://developer.apple.com/documentation/bundleresources/information_property_list/uisupportsfullscreeninassistiveaccess")!, label: {
                    Text("UISupportsFullScreenInAssistiveAccess")
                }).accessibilityRemoveTraits(.isButton)
            }
            .navigationTitle("Assistive Access")
            .padding()

        }
 
    }

}
 
struct AssistiveAccessView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AssistiveAccessView()
        }
    }
}
