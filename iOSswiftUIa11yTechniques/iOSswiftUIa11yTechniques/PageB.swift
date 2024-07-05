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

struct PageB: View {
    @State private var isShowingSheet3 = false
    @AccessibilityFocusState private var isTriggerFocused3: Bool
    @State private var isShowingSheet4 = false
    @AccessibilityFocusState private var isTriggerFocused4: Bool

    
    var body: some View {
        ScrollView {
            VStack {
                Text("Texas Swimming Club")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h2)
                Text("Texas Swimming Club has been home to recreation and swimmers since 1909. To join the club please read our terms and conditions.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button("Terms and Conditions") {
                    self.isShowingSheet3 = true
                }
                .accessibilityLabel("Terms and Conditions, Texas Swimming Club")
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityFocused($isTriggerFocused3)
                .sheet(isPresented: $isShowingSheet3,
                       onDismiss: didDismiss3) {
                    Text("Terms and Conditions")
                        .font(.headline)
                        .padding()
                        .accessibilityAddTraits(.isHeader)
                    Text("""
                        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
                        """)
                        .padding()
                    Button("Dismiss",
                           action: { isShowingSheet3.toggle() })
                    .padding()
                }
                Text("Miami Boat Rentals")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h2)
                Text("You can rent a boat for as low as $250 at Miami Boat Rentals. Please read the terms and conditions before making a reservation.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button("Terms and Conditions") {
                    self.isShowingSheet4 = true
                }
                .accessibilityLabel("Terms and Conditions, Miami Boat Rentals")
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityFocused($isTriggerFocused4)
                .sheet(isPresented: $isShowingSheet4,
                       onDismiss: didDismiss4) {
                    Text("Terms and Conditions")
                        .font(.headline)
                        .padding()
                        .accessibilityAddTraits(.isHeader)
                    Text("""
                        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
                        """)
                        .padding()
                    Button("Dismiss",
                           action: { isShowingSheet4.toggle() })
                    .padding()
                }
            }
            .navigationTitle("Summer Adventures B")
            .padding()

        }
 
    }
    func didDismiss3() {
        isTriggerFocused3 = true
    }
    func didDismiss4() {
        isTriggerFocused4 = true
    }


}
 
struct PageB_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PageB()
        }
    }
}
