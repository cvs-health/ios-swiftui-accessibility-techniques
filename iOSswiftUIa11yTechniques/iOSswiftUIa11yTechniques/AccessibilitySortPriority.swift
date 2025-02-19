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

struct AccessibilitySortPriority: View {
    @State private var selectedDate = Date()
    @State private var isDatePickerPresented = false
    @AccessibilityFocusState private var isTriggerFocused: Bool


    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("`.accessibilitySortPriority(#)` can be used to control VoiceOver reading order if the default order is not meaningful. Higher numbers are sorted first, e.g. 99 is read before 1. The default sort priority is 0.")
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
                HStack {
                    Text("Birth Date")
                    Button(action: {
                         isDatePickerPresented = true
                     }) {
                         HStack {
                             Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                                 .padding(10)
                                 .background(Color.gray.opacity(0.2))
                                 .foregroundColor(colorScheme == .dark ? .white : .black)
                                 .cornerRadius(10)
                         }
                     }
                     .accessibilityLabel("Birth Date")
                     .accessibilityValue(selectedDate.formatted(date: .abbreviated, time: .omitted))
                     .accessibilityFocused($isTriggerFocused)
                     .sheet(isPresented: $isDatePickerPresented) {
                         HStack {
                             Spacer()
                             Button("Done") {
                                 isDatePickerPresented = false
                                 isTriggerFocused = true
                             }
                         }.padding()
                         DatePicker("Birth Date", selection: $selectedDate, displayedComponents: [.date])
                             .datePickerStyle(.wheel)
                             .labelsHidden()
                             .accessibilitySortPriority(1) // make VoiceOver focus go here first when sheet opens
                         .presentationDetents([.height(300)])
                         .presentationDragIndicator(.hidden)
                     }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The good example uses `DatePicker` with `.accessibilitySortPriority(1)` to make VoiceOver focus go to the wheel style date picker first when the sheet opens. Without a sort priority, focus would go to the Done button first.")
                }.padding(.bottom).accessibilityHint("Good Example")
            }
            .navigationTitle("Accessibility Sort Priority")
            .padding()
        }
 
    }

}
 
#Preview {
    NavigationStack {
        AccessibilitySortPriority()
    }
}
