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

struct AccessibilitySortPriorityWatch: View {
    
    let darkBlue = Color(red: 26/255, green: 115/255, blue: 206/255)
    @State private var selectedDate = Date()
    @State private var isDatePickerPresented = false
    @AccessibilityFocusState private var isTriggerFocused: Bool

    var body: some View {
        ScrollView {
            Text("`.accessibilitySortPriority(#)` can be used to control VoiceOver reading order if the default order is not meaningful. Higher numbers are sorted first, e.g. 99 is read before 1. The default sort priority is 0.")
            Text("Platform Defect Example")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h2)
                .foregroundColor(.orange)
            Divider()
                .frame(height: 2.0, alignment:.leading)
                .background(.orange)
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
                             .cornerRadius(10)
                     }
                 }
                 .buttonStyle(.plain)
                 .accessibilityLabel("Birth Date")
                 .accessibilityValue(selectedDate.formatted(date: .abbreviated, time: .omitted))
                 .accessibilityFocused($isTriggerFocused)
                 .sheet(isPresented: $isDatePickerPresented, onDismiss: didDismiss) {
                     DatePicker("Birth Date", selection: $selectedDate, displayedComponents: [.date])
                         .datePickerStyle(.wheel)
                         .accessibilitySortPriority(1) // make VoiceOver focus go here first when sheet opens
                     .toolbar {
                         ToolbarItemGroup(placement: .confirmationAction) {
                             Spacer()
                             Button("Done") {
                                 isDatePickerPresented = false
                             }
                         }
                     }

                 }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            NavigationLink(destination: DetailSortPriorityGood()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("Good Example")
                .buttonStyle(.plain)
                .padding(.bottom)
        }
    }
    func didDismiss() {
        isTriggerFocused = true
    }
}

struct DetailSortPriorityGood: View {
    var body: some View {
        ScrollView {
            Text("The good example uses `DatePicker` with `.accessibilitySortPriority(1)` to make VoiceOver focus go to the wheel style date picker first when the sheet opens. Without a sort priority, focus would go to the Done button first. This is a platform defect with VoiceOver on watchOS sort priority does not work on a DatePicker in a Sheet.")
        }
            .navigationTitle("`Good Example`")
    }
}


#Preview {
    NavigationStack {
        AccessibilitySortPriorityWatch()
    }
}
