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

struct DOBpicker: View {
    @State private var selectedDate = Calendar.current.date(byAdding: DateComponents(year: -40), to: Date()) ?? Date()
    @State private var isDatePickerPresented = false
    @AccessibilityFocusState private var isTriggerFocused: Bool
    @Environment(\.colorScheme) var colorScheme

    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Birth Date")
                    Spacer()
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
                     .sheet(isPresented: $isDatePickerPresented, onDismiss: didDismiss) {
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
                         .presentationDetents([.height(300)])
                         .presentationDragIndicator(.hidden)
                     }
                }
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(colorScheme == .dark ? .white : .black, lineWidth: 1)
                )
            }
            .navigationTitle("Date of Birth Picker")
            .padding()

        }
 
    }
    func didDismiss() {
        isTriggerFocused = true
    }


}

#Preview {
    NavigationStack {
        DOBpicker()
    }
}

