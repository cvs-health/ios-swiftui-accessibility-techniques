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
 
struct SteppersView: View {
    @FocusState var isInputActive: Bool
    
    @State private var copies = 1
    @State private var tickets = 1
    
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Steppers are used to increase or decrease incremental values. Use internal `Stepper` `Text(\"Label\")` to create a visible label that becomes the accessibility label for VoiceOver users.")
                    .padding([.bottom])
                Text("Good Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                Text("Good Example 1")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Stepper(value: $tickets) {
                    Text("Tickets: \(tickets)")
                }
                .accessibilityIdentifier("stepperGood1")
                DisclosureGroup("Details") {
                    Text("The first good Stepper example uses `Text(\"Tickets: \\(tickets)\")` as the visible label text which becomes the VoiceOver accessibility label.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                Text("Good Example 2")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Text("Copies")
                    TextField("", value: $copies, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .border(.secondary)
                        .frame(alignment: .leading)
                        .accessibilityLabel("Copies")
                        .keyboardType(.numberPad)
                        .focused($isInputActive)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    isInputActive = false
                                }
                            }
                        }
                    Stepper("", value: $copies).accessibilityLabel("Copies")
                        .accessibilityIdentifier("stepperGood2")
                }
                DisclosureGroup("Details") {
                    Text("The second good Stepper example includes a text field so that users can quickly enter a large value, e.g., 50 copies. The Stepper uses `.accessibilityLabel(\"Copies\")` to create an accessibility label for VoiceOver because the visible stepper text is empty.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                Text("Bad Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                Text("Bad Example 1")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Text("Tickets: \(tickets)").frame(maxWidth: .infinity, alignment: .leading)
                    Stepper(value: $tickets) {}
                        .accessibilityIdentifier("stepperBad1")
                }
                DisclosureGroup("Details") {
                    Text("The first bad Stepper example has no internal `Stepper` label text so there is no accessibility label spoken to VoiceOver.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                Text("Bad Example 2")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Text("Copies: \(copies)")
                    Stepper("", value: $copies)
                        .accessibilityIdentifier("stepperBad2")
                }
                DisclosureGroup("Details") {
                    Text("The second bad Stepper example has no text field for users to quickly enter a large value, e.g., 50 copies. The Stepper has no internal label text and no `.accessibilityLabel` for VoiceOver users.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
            }
            .padding()
            .navigationBarTitle("Steppers")

        }
 
    }
}
 
struct SteppersView_Previews: PreviewProvider {
    static var previews: some View {
        SteppersView()
    }
}
