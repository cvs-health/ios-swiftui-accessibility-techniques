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

struct TappableTextView: View {
    let text: String
    
    @State private var showAlert = false

    
    var body: some View {
        Text(text)
            .background(
                Color.clear
                    .contentShape(Rectangle())
            )
            .onTapGesture {
                self.showAlert = true
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Text Tapped!"),
                    message: Text("You tapped: \(text)")
                )
            }
    }
}


struct AccessibilityRespondsToUserInteraction: View {
    @State private var selectedDate = Date()
    @State private var isDatePickerPresented = false
    @AccessibilityFocusState private var isTriggerFocused: Bool


    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("`.accessibilityRespondsToUserInteraction(true|false)` can control if elements are focusable and operable with accessibility features such as Switch Control, Voice Control, and Full Keyboard Access. Don't use this property unless you need to make an element focusable that is not by default or if you need to remove an element from the focus order.")
                    .padding(.bottom)
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
                HStack {
                    VStack {
                        Text("Tap Gesture Text `.accessibilityRespondsToUserInteraction(false)`")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityAddTraits(.isHeader)

                       TappableTextView(text: "Tappable Text")
                            .accessibilityRespondsToUserInteraction(false)
                            .padding()
                       
                        Text("Static Text `.accessibilityRespondsToUserInteraction(true)`")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityAddTraits(.isHeader)

                       Text("Non-Tappable Text")
                            .accessibilityRespondsToUserInteraction(true)
                            .padding()
                       }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The bad example uses `.accessibilityRespondsToUserInteraction(false)` on text with a tap gesture which blocks Switch Control, Voice Control, and Full Keyboard Access from focusing or tapping the text. `.accessibilityRespondsToUserInteraction(true)` is added to static text that is not tappable which forces Switch Control and Full Keyboard Access to focus on that text. Voice Control shows a name for the non-tappable static text but not for the tappable text.")
                }.padding(.bottom).accessibilityHint("Bad Example")
            }
            .navigationTitle("Accessibility Responds To User Interaction")
            .padding()
        }
 
    }

}
 
#Preview {
    NavigationStack {
        AccessibilityRespondsToUserInteraction()
    }
}
