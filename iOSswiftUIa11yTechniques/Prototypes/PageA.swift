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

struct PageA: View {
    @State private var isShowingSheet = false
    @AccessibilityFocusState private var isTriggerFocused: Bool
    @State private var isShowingSheet2 = false
    @AccessibilityFocusState private var isTriggerFocused2: Bool

    
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
                Button("Texas Swimming Club Terms and Conditions") {
                    self.isShowingSheet = true
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityFocused($isTriggerFocused)
                .sheet(isPresented: $isShowingSheet,
                       onDismiss: didDismiss) {
                    Text("Terms and Conditions")
                        .font(.headline)
                        .padding()
                        .accessibilityAddTraits(.isHeader)
                    Text("""
                        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
                        """)
                        .padding()
                    Button("Dismiss",
                           action: { isShowingSheet.toggle() })
                    .padding()
                }
                Text("Miami Boat Rentals")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h2)
                Text("You can rent a boat for as low as $250 at Miami Boat Rentals. Please read the terms and conditions before making a reservation.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button("Miami Boat Rentals Terms and Conditions") {
                    self.isShowingSheet2 = true
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityFocused($isTriggerFocused2)
                .sheet(isPresented: $isShowingSheet2,
                       onDismiss: didDismiss2) {
                    Text("Terms and Conditions")
                        .font(.headline)
                        .padding()
                        .accessibilityAddTraits(.isHeader)
                    Text("""
                        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
                        """)
                        .padding()
                    Button("Dismiss",
                           action: { isShowingSheet2.toggle() })
                    .padding()
                }
            }
            .navigationTitle("Summer Adventures A")
            .padding()

        }
 
    }
    func didDismiss() {
        isTriggerFocused = true
    }
    func didDismiss2() {
        isTriggerFocused2 = true
    }

}
 
struct PageA_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PageA()
        }
    }
}
