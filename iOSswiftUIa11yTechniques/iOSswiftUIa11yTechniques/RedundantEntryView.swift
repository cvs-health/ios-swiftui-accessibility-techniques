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

struct RedundantEntryView: View {
    @State private var currentPage = 0
    @State private var invoice = ""
    @State private var plate = ""
    @State private var card = ""
    @State private var name = ""
    @State private var email = ""
    @State private var showingStep1Alert = false
    @AccessibilityFocusState private var isNextFocused: Bool
    @State private var showingStep2Alert = false
    @AccessibilityFocusState private var isSubmitFocused: Bool
    @AccessibilityFocusState private var isSuccessFocused: Bool
    @AccessibilityFocusState private var isStep1Focused: Bool
    @AccessibilityFocusState private var isStep2Focused: Bool
    @State private var currentPageBad = 0
    @State private var invoiceBad = ""
    @State private var plateBad = ""
    @State private var invoiceBad2 = ""
    @State private var plateBad2 = ""
    @State private var cardBad = ""
    @State private var nameBad = ""
    @State private var emailBad = ""
    @State private var showingStep1AlertBad = false
    @State private var showingStep2AlertBad = false
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("WCAG 2.2's Redundant Entry Success Criterion requires that information previously entered into a process that is required to be entered again either be auto-populated or available for the user to select (e.g. via copy/paste).")
                    .padding([.bottom])
                Text("Good Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                if (currentPage == 0) {
                    VStack {
                        Text("Step 1 - Pay Toll Bill")
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityFocused($isStep1Focused)
                        Text("Name *")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TextField("", text: $name, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .border(.secondary)
                            .accessibilityLabel("Name *, required")
                            .autocorrectionDisabled(true)
                            .textContentType(.name)
                        Text("Invoice Number *")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TextField("", text: $invoice, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .border(.secondary)
                            .accessibilityLabel("Invoice Number *, required")
                            .autocorrectionDisabled(true)
                            .keyboardType(.numberPad)
                        Text("License Plate *")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TextField("", text: $plate, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .border(.secondary)
                            .accessibilityLabel("License Plate, * required")
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled(true)
                        HStack {
                            Spacer()
                            Button("Next") {
                                if name.isEmpty || invoice.isEmpty || plate.isEmpty {
                                    showingStep1Alert = true
                                } else {
                                    currentPage = 1
                                    DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                        isStep2Focused = true
                                    }
                                }
                            }
                            .accessibilityFocused($isNextFocused)
                            .alert("All fields are required.", isPresented: $showingStep1Alert) {
                                Button("Ok", role: .cancel) {
                                    DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                        isNextFocused = true
                                    }
                                }
                            } message: {
                                Text("Complete all fields to continue.")
                            }
                        }
                    }
                }
                if (currentPage == 1) {
                    VStack {
                        Text("Step 2 - Pay Toll Bill")
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityFocused($isStep2Focused)
                        Text("Invoice Number *")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TextField("", text: $invoice, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .border(.secondary)
                            .accessibilityLabel("Invoice Number *, required")
                            .autocorrectionDisabled(true)
                            .keyboardType(.numberPad)
                        Text("License Plate *")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TextField("", text: $plate, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .border(.secondary)
                            .accessibilityLabel("License Plate, * required")
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled(true)
                        Text("Credit Card *")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TextField("", text: $card, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .border(.secondary)
                            .accessibilityLabel("Credit Card Number, * required")
                            .autocorrectionDisabled(true)
                            .textContentType(.creditCardNumber)
                        HStack {
                            Button("Back") {
                                currentPage = 0
                                DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                    isStep1Focused = true
                                }
                            }
                            Spacer()
                            Button("Submit Payment") {
                                if plate.isEmpty || invoice.isEmpty || card.isEmpty {
                                    showingStep2Alert = true
                                } else {
                                    currentPage = 2
                                    DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                        isSuccessFocused = true
                                    }
                                }
                            }
                            .accessibilityFocused($isSubmitFocused)
                            .alert("All fields are required.", isPresented: $showingStep2Alert) {
                                Button("Ok", role: .cancel) {
                                    DispatchQueue.main.asyncAfter(deadline:.now() + 0.1) {
                                        isSubmitFocused = true
                                    }
                                }
                            } message: {
                                Text("Complete all fields to submit payment.")
                            }
                        }
                    }
                }
                if (currentPage == 2) {
                    VStack {
                        Text("Toll Payment Submitted Successfully")
                            .accessibilityFocused($isSuccessFocused)
                            .font(.title)
                    }
                }
                DisclosureGroup("Details") {
                    Text("The good example saves the Invoice Number and License Plate between the 2 steps so that users don't have to type that information again. The good example also uses focus management to place VoiceOver focus in the most logical areas after closing the alerts or moving between steps.")
                }.padding(.bottom).accessibilityHint("Good Example")
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
                if (currentPageBad == 0) {
                    VStack {
                        Text("Step 1 - Pay Toll Bill")
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Name *")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TextField("", text: $nameBad, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .border(.secondary)
                            .accessibilityLabel("Name *, required")
                            .autocorrectionDisabled(true)
                            .textContentType(.name)
                        Text("Invoice Number *")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TextField("", text: $invoiceBad, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .border(.secondary)
                            .accessibilityLabel("Invoice Number *, required")
                            .autocorrectionDisabled(true)
                            .keyboardType(.numberPad)
                        Text("License Plate *")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TextField("", text: $plateBad, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .border(.secondary)
                            .accessibilityLabel("License Plate, * required")
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled(true)
                        HStack {
                            Spacer()
                            Button("Next") {
                                if nameBad.isEmpty || invoiceBad.isEmpty || plateBad.isEmpty {
                                    showingStep1AlertBad = true
                                } else {
                                    currentPageBad = 1
                                }
                            }
                            .alert("All fields are required.", isPresented: $showingStep1AlertBad) {
                                Button("Ok", role: .cancel) {
                                }
                            } message: {
                                Text("Complete all fields to continue.")
                            }
                        }
                    }
                }
                if (currentPageBad == 1) {
                    VStack {
                        Text("Step 2 - Pay Toll Bill")
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Invoice Number *")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TextField("", text: $invoiceBad2, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .border(.secondary)
                            .accessibilityLabel("Invoice Number *, required")
                            .autocorrectionDisabled(true)
                            .keyboardType(.numberPad)
                        Text("License Plate *")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TextField("", text: $plateBad2, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .border(.secondary)
                            .accessibilityLabel("License Plate, * required")
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled(true)
                        Text("Credit Card *")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TextField("", text: $cardBad, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .border(.secondary)
                            .accessibilityLabel("Credit Card Number, * required")
                            .autocorrectionDisabled(true)
                            .textContentType(.creditCardNumber)
                        HStack {
                            Spacer()
                            Button("Submit Payment") {
                                if plateBad.isEmpty || invoiceBad.isEmpty || cardBad.isEmpty {
                                    showingStep2AlertBad = true
                                } else {
                                    currentPageBad = 2
                                }
                            }
                            .alert("All fields are required.", isPresented: $showingStep2AlertBad) {
                                Button("Ok", role: .cancel) {
                                }
                            } message: {
                                Text("Complete all fields to submit payment.")
                            }
                        }
                    }
                }
                if (currentPageBad == 2) {
                    VStack {
                        Text("Toll Payment Submitted Successfully")
                            .font(.title)
                    }
                }

                DisclosureGroup("Details") {
                    Text("The bad example does not save the Invoice Number and License Plate between the 2 steps which requires users to type that information again. The bad example is also missing focus management after closing the alerts or moving between steps.")
                }.padding(.bottom).accessibilityHint("Bad Example")
            }
            .padding()
            .navigationTitle("Redundant Entry")
        }
 
    }
}

 
struct RedundantEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RedundantEntryView()
        }
    }
}


