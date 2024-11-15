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

struct SignUpA: View {
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
                Text("Full Name (Required)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .bold()
                TextField("", text: $fname, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Full Name (Required)")
                    .autocorrectionDisabled(true)
                    .textContentType(.name)
                Text("Nickname")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .bold()
                Text("Max 12 characters")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.caption)
                TextField("", text: $nname, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .border(.secondary)
                    .accessibilityLabel("Nickname")
                    .accessibilityHint("Max 12 characters")
                    .autocorrectionDisabled(true)
                    .textContentType(.nickname)
                Spacer().frame(height: 20)
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
                Toggle("I confirm the above is accurate.", isOn: $confirmToggle)
                    .padding()
                    .bold()
                Button(action: {
                    print("Button tapped")
                }) {
                    HStack {
                        Image(systemName: "smiley")
                        Text("Sign Up")
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .bold()
                }
                .background(Color(red: 0, green: 0, blue: 139))
                .foregroundColor(.white)
                .clipShape(.capsule)
            }
            .navigationTitle("Sign Up A")
            .padding()

        }
 
    }
    func didDismiss() {
        isTriggerFocused = true
    }


}

#Preview {
    NavigationStack {
        SignUpA()
    }
}

