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
 
struct MagicTapView: View {
    @State private var showingAlert = false

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Magic Tap allows VoiceOver users to toggle the most important state or feature in an app. Use `.accessibilityAction(.magicTap)` on the pages you want to enable the Magic Tap gesture.")
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
                Text("Turn on VoiceOver and double tap with 2 fingers to activate Magic Tap.")
                DisclosureGroup("Details") {
                    Text("The good Magic Tap example uses `.accessibilityAction(.magicTap)` to display an alert dialog when VoiceOver users double tap with 2 fingers anywhere on this page.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
            }
            .navigationBarTitle("Magic Tap")
            .padding()
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Magic Tap Activated"), message: Text("You activated Magic Tap by double-tapping with 2 fingers!"), dismissButton: .default(Text("OK")))
            }
            .accessibilityAction(.magicTap) {
                showingAlert = true
            }

        }
 
    }
}
 
struct MagicTapView_Previews: PreviewProvider {
    static var previews: some View {
        MagicTapView()
    }
}
