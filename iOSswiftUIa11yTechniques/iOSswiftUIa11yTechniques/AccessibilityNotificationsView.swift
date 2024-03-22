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

struct AccessibilityNotificationsView: View {

    @State private var cartMessageGoodVisible = false
    @State private var cartMessageBadVisible = false
    
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Accessibility Notifications are used to speak announcements to VoiceOver users without moving their focus. Post an `AccessibilityNotification.Announcement` when you need to make an announcement to VoiceOver.")
                    .padding([.bottom])
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
                    if cartMessageGoodVisible {
                        Text("1 Item added to cart.")
                    }
                    Button(action: {
                        cartMessageGoodVisible = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            AccessibilityNotification.Announcement("1 Item added to cart.").post()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            cartMessageGoodVisible = false
                        }
                    }) {
                        Text("Add to Cart")
                    }.padding().frame(maxWidth: .infinity, alignment: .leading)
                }
                DisclosureGroup("Details") {
                    Text("The good Accessibility Notifications example posts an `AccessibilityNotification.Announcement` that speaks the \"1 Item added to cart.\" status message to VoiceOver when activating the Add to Cart button. The announcement is posted with a 0.1 second delay to make it speak correctly to VoiceOver.")
                }.padding([.bottom]).accessibilityLabel("Details, Good Example")
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
                    if cartMessageBadVisible {
                        Text("1 Item added to cart.")
                    }
                    Button(action: {
                        cartMessageBadVisible = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            cartMessageBadVisible = false
                        }
                    }) {
                        Text("Add to Cart")
                    }.padding().frame(maxWidth: .infinity, alignment: .leading)
                }
                DisclosureGroup("Details") {
                    Text("The bad Accessibility Notifications example does not speak an accessibility announcement notification to VoiceOver when the \"1 Item added to cart.\" status message displays.")
                }.accessibilityLabel("Details, Bad Example")
            }
            .padding()
            .navigationTitle("Accessibility Notifications")

        }
 
    }
}
 
struct AccessibilityNotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        AccessibilityNotificationsView()
    }
}
