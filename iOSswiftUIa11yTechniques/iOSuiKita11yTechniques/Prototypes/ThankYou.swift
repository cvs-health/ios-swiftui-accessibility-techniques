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

struct ThankYou: View {
    @State private var selectedDate = Calendar.current.date(byAdding: DateComponents(year: -40), to: Date()) ?? Date()
    @State private var isDatePickerPresented = false
    @AccessibilityFocusState private var isTriggerFocused: Bool
    @Environment(\.colorScheme) var colorScheme
    @State private var fname = ""
    @State private var nname = ""
    @State private var confirmToggle = false

    
    var body: some View {
        ScrollView {
            VStack {
                Text("Thank you for completing the form! You can now close this page.")
            }
            .navigationTitle("Thank You")
            .padding()

        }
 
    }


}

#Preview {
    NavigationStack {
        ThankYou()
    }
}

