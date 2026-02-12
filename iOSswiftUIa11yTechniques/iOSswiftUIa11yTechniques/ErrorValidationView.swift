/*
   Copyright 2023-2026 CVS Health and/or one of its affiliates

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

// Helper to conditionally apply a view modifier within a chain
private struct AnyViewModifier: ViewModifier {
    let transform: (AnyView) -> AnyView
    func body(content: Content) -> some View {
        transform(AnyView(content))
    }
}

struct ErrorValidationView: View {
    @State private var text = ""
    @State private var fname = ""
    @State private var lname = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var firstNameErrorVisible = false
    @AccessibilityFocusState private var isFirstNameA11yFocused: Bool
    @FocusState private var isFirstNameFocused: Bool
    @State private var fnameLabel = "First Name *"
    @State private var fnameError = "⚠ First Name is required. Please enter your first name."
    @State private var lnameLabel = "Last Name *"
    @State private var lnameError = "⚠ Last Name is required. Please enter your last name."
    @State private var lastNameErrorVisible = false
    @AccessibilityFocusState private var isLastNameA11yFocused: Bool
    @FocusState private var isLastNameFocused: Bool
    @State private var emailLabel = "Email *"
    @State private var emailError = "⚠ Email is required. Please enter your email address."
    @State private var emailErrorVisible = false
    @AccessibilityFocusState private var isEmailA11yFocused: Bool
    @FocusState private var isEmailFocused: Bool
    
    @State private var fnameBad = ""
    @State private var lnameBad = ""
    @State private var phoneBad = ""
    @State private var emailBad = ""
    @State private var firstNameErrorVisibleBad = false
    @State private var fnameLabelBad = "First Name"
    @State private var fnameErrorBad = "This field is required."
    @State private var lnameLabelBad = "Last Name"
    @State private var lnameErrorBad = "This field is required."
    @State private var lastNameErrorVisibleBad = false
    @State private var emailLabelBad = "Email"
    @State private var emailErrorBad = "This field is required."
    @State private var emailErrorVisibleBad = false

    // Added state variables for Good Example Choice Button Group Error Message
    @State private var selectedChoice: Int? = nil
    @State private var choiceGroupErrorVisible = false
    @State private var selectedChoiceBad: Int? = nil
    @State private var choiceGroupErrorVisibleBad = false
    @State private var choiceGroupError = "⚠ Please select one of the options."
    @State private var choiceGroupLabel = "Choose an option"
    @AccessibilityFocusState private var isFirstChoiceA11yFocused: Bool

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Computed Colors
    private var errorColor: Color { colorScheme == .dark ? Color(.systemRed) : darkRed }
    private var successColor: Color { colorScheme == .dark ? Color(.systemGreen) : darkGreen }
    private func borderColor(isError: Bool) -> Color { isError ? errorColor : .secondary }

    // MARK: - Subviews to simplify type-checker load
    @ViewBuilder
    private func GoodExampleForm() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Good Examples")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .foregroundColor(successColor)
            Divider()
                .frame(height: 2.0, alignment: .leading)
                .background(successColor)
                .padding(.bottom)

            Text("Good Example Using .accessibilityHint")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)

            Text("* indicates required fields")
                .frame(maxWidth: .infinity, alignment: .leading)
                .italic()
                .font(.caption)

            // First name
            Text(fnameLabel)
                .frame(maxWidth: .infinity, alignment: .leading)
            if firstNameErrorVisible {
                Text(fnameError)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(errorColor)
            }
            TextField("", text: $fname, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .border(borderColor(isError: firstNameErrorVisible))
                .accessibilityLabel(fnameLabel)
                .accessibilityHint(firstNameErrorVisible ? fnameError : "")
                .autocorrectionDisabled(true)
                .textContentType(.givenName)
                .accessibilityIdentifier("fNameGood")
                .accessibilityFocused($isFirstNameA11yFocused)
                .focused($isFirstNameFocused)

            // Last name
            Text(lnameLabel)
                .frame(maxWidth: .infinity, alignment: .leading)
            if lastNameErrorVisible {
                Text(lnameError)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(errorColor)
            }
            TextField("", text: $lname, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .border(borderColor(isError: lastNameErrorVisible))
                .accessibilityLabel(lnameLabel)
                .accessibilityHint(lastNameErrorVisible ? lnameError : "")
                .autocorrectionDisabled(true)
                .textContentType(.familyName)
                .accessibilityIdentifier("lNameGood")
                .accessibilityFocused($isLastNameA11yFocused)
                .focused($isLastNameFocused)

            // Phone
            Text("Phone Number")
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("", text: $phone, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .border(.secondary)
                .accessibilityLabel("Phone Number")
                .keyboardType(.phonePad)
                .accessibilityIdentifier("phoneGood")

            // Email
            Text(emailLabel)
                .frame(maxWidth: .infinity, alignment: .leading)
            if emailErrorVisible {
                Text(emailError)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(errorColor)
            }
            TextField("", text: $email, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .border(borderColor(isError: emailErrorVisible))
                .accessibilityLabel(emailLabel)
                .accessibilityHint(emailErrorVisible ? emailError : "")
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .textContentType(.emailAddress)
                .accessibilityIdentifier("emailGood")
                .accessibilityFocused($isEmailA11yFocused)
                .focused($isEmailFocused)

            Button(action: validateGoodForm) {
                Text("Join Newsletter")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .font(.title2)
                    .fontWeight(.bold)
                    .opacity(0.8)
            }
            .padding()

            DisclosureGroup("Details") {
                Text("The first good error validation example uses `AccessibilityFocusState` to move VoiceOver focus to the first invalid input when submitting the form with invalid data. Each invalid input has an `.accessibilityHint` matching the visible error message text so that VoiceOver users hear the error message when focused on the invalid inputs. Error messages are meaningful and specific. Required fields are indicated with a * and the meaning of the * is defined at the top of the form. Errors are placed above the input so that the keyboard does not cover the message when the textfield has focus.")
            }
            .padding(.bottom)
            .accessibilityHint("Good Example Using .accessibilityHint")
        }
    }

    @ViewBuilder
    private func ChoiceGroupHeader() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Good Example Choice Button Group Error Message")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)

            Text(choiceGroupLabel)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    @ViewBuilder
    private func ChoiceGroupHeaderBad() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Bad Example Choice Button Group Error Message")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)

            Text(choiceGroupLabel)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private func ChoiceButton(idx: Int) -> some View {
        let isSelected = selectedChoice == idx
        let showErrorBorder = choiceGroupErrorVisible && selectedChoice == nil

        Button(action: {
            if isSelected {
                selectedChoice = nil
            } else {
                selectedChoice = idx
            }
            choiceGroupErrorVisible = false
        }) {
            Text("Option \(idx)")
                .frame(minWidth: 100, minHeight: 100)
                .background(isSelected ? Color.blue : Color(.systemBackground))
                .foregroundColor(.primary)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(showErrorBorder ? errorColor : Color.secondary, lineWidth: 3)
                )
        }
        .id("choice_\(idx)")
        .accessibilityAddTraits(.isToggle)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint(choiceGroupErrorVisible ? choiceGroupError : "")
        .accessibilityValue(
            isSelected ? "checked" : (showErrorBorder ? "invalid entry, unchecked" : "unchecked")
        )
        .modifier(
            idx == 1 ? AnyViewModifier { view in
                AnyView(view.accessibilityFocused($isFirstChoiceA11yFocused))
            } : AnyViewModifier { view in AnyView(view) }
        )
    }
    @ViewBuilder
    private func ChoiceButtonBad(idx: Int) -> some View {
        let isSelected = selectedChoiceBad == idx
        let showErrorBorder = choiceGroupErrorVisibleBad && selectedChoiceBad == nil

        Button(action: {
            if isSelected {
                selectedChoiceBad = nil
            } else {
                selectedChoiceBad = idx
            }
            choiceGroupErrorVisibleBad = false
        }) {
            Text("Option \(idx)")
                .frame(minWidth: 100, minHeight: 100)
                .background(isSelected ? Color.blue : Color(.systemBackground))
                .foregroundColor(.primary)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(showErrorBorder ? errorColor : Color.secondary, lineWidth: 3)
                )
        }
    }

    @ViewBuilder
    private func ChoiceGroupSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ChoiceGroupHeader()

            let columns = [GridItem(.adaptive(minimum: 100, maximum: 100), spacing: 24)]

            LazyVGrid(columns: columns, spacing: 24) {
                ForEach(1...4, id: \.self) { idx in
                    ChoiceButton(idx: idx)
                }
            }
            .padding(.vertical, 6)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(choiceGroupLabel)

            VStack(alignment: .leading, spacing: 8) {
                if choiceGroupErrorVisible {
                    Text(choiceGroupError)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(errorColor)
                        .accessibilityHint(choiceGroupError)
                }
                Button(action: validateChoiceGroup) {
                    Text("Submit Choice")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .font(.title3)
                        .fontWeight(.bold)
                        .opacity(0.8)
                }
            }
            .padding()

            DisclosureGroup("Details") {
                Text("The good example choice button error group uses the group label text as the accessibility label for the group container. Each choice button has an `.isToggle` trait and a `\"checked\"` or `\"unchecked\"` `.accessibilityValue` state. When the choice buttons are invalid the error message is set as the `.accessibilityHint` and the string `\"invalid entry\"` is added to the `.accessibilityValue`. `AccessibilityFocusState` is used to send VoiceOver focus to the first invalid choice button on a bad submit. `ScrollViewReader` is used to scroll the invalid choice button into view so that VoiceOver focus can move to it if the invalid button was scrolled out of view.")
            }
            .padding(.bottom)
            .accessibilityHint("Good Example Choice Button Group Error Message")
        }
    }
    @ViewBuilder
    private func ChoiceGroupSectionBad() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ChoiceGroupHeaderBad()

            let columns = [GridItem(.adaptive(minimum: 100, maximum: 100), spacing: 24)]

            LazyVGrid(columns: columns, spacing: 24) {
                ForEach(1...4, id: \.self) { idx in
                    ChoiceButtonBad(idx: idx)
                }
            }
            .padding(.vertical, 6)

            VStack(alignment: .leading, spacing: 8) {
                if choiceGroupErrorVisibleBad {
                    Text(choiceGroupError)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(errorColor)
                }
                Button(action: validateChoiceGroupBad) {
                    Text("Submit Choice")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .font(.title3)
                        .fontWeight(.bold)
                        .opacity(0.8)
                }
            }
            .padding()

            DisclosureGroup("Details") {
                Text("The bad example choice button error group has no accessibility label for the group container. The choice buttons have no toggle trait or checked/unchecked states. When the choice buttons are invalid the error message is not associated and there is no invalid state. Nothing is spoken to VoiceOver on a bad submit because the focus is not moved to the invalid button.")
            }
            .padding(.bottom)
            .accessibilityHint("Bad Example Choice Button Group Error Message")
        }
    }

    @ViewBuilder
    private func BadExampleForm() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Bad Example")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .foregroundColor(errorColor)
            Divider()
                .frame(height: 2.0, alignment: .leading)
                .background(errorColor)
                .padding(.bottom)
            Text("Bad Example")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
            Text(fnameLabelBad)
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("", text: $fnameBad, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .border(borderColor(isError: firstNameErrorVisibleBad))
                .accessibilityLabel(fnameLabelBad)
                .autocorrectionDisabled(true)
                .textContentType(.givenName)
                .accessibilityIdentifier("fNameBad")
            if firstNameErrorVisibleBad {
                Text(fnameErrorBad)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(errorColor)
            }

            Text(lnameLabelBad)
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("", text: $lnameBad, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .border(borderColor(isError: lastNameErrorVisibleBad))
                .accessibilityLabel(lnameLabelBad)
                .autocorrectionDisabled(true)
                .textContentType(.familyName)
                .accessibilityIdentifier("lNameBad")
            if lastNameErrorVisibleBad {
                Text(lnameErrorBad)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(errorColor)
            }

            Text("Phone Number")
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("", text: $phoneBad, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .border(.secondary)
                .accessibilityLabel("Phone Number")
                .keyboardType(.phonePad)
                .accessibilityIdentifier("phoneBad")

            Text(emailLabelBad)
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("", text: $emailBad, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .border(borderColor(isError: emailErrorVisibleBad))
                .accessibilityLabel(emailLabel)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .textContentType(.emailAddress)
                .accessibilityIdentifier("emailBad")
            if emailErrorVisibleBad {
                Text(emailErrorBad)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(errorColor)
            }

            Button(action: validateBadForm) {
                Text("Join Newsletter")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .font(.title2)
                    .fontWeight(.bold)
                    .opacity(0.8)
            }
            .padding()

            DisclosureGroup("Details") {
                Text("The bad error validation example does not move VoiceOver focus to the first invalid input when submitting the form with invalid data. Each invalid input does not speak its error message text to VoiceOver users when focused on the invalid inputs. Error messages are generic and not specific. Required fields are not indicated. Errors are placed below the input which causes the keyboard to cover the message when the textfield has focus.")
            }
            .padding(.bottom)
            .accessibilityHint("Bad Example")
        }
    }

    // MARK: - Actions
    private func validateGoodForm() {
        firstNameErrorVisible = false
        isFirstNameFocused = false
        isFirstNameA11yFocused = false
        lastNameErrorVisible = false
        isLastNameFocused = false
        isLastNameA11yFocused = false
        emailErrorVisible = false
        isEmailFocused = false
        isEmailA11yFocused = false
        if email.isEmpty {
            emailErrorVisible = true
            isEmailFocused = true
            isEmailA11yFocused = true
        }
        if lname.isEmpty {
            lastNameErrorVisible = true
            isLastNameFocused = true
            isLastNameA11yFocused = true
        }
        if fname.isEmpty {
            firstNameErrorVisible = true
            isFirstNameFocused = true
            isFirstNameA11yFocused = true
        }
    }

    private func validateChoiceGroup() {
        choiceGroupErrorVisible = false
        if selectedChoice == nil {
            choiceGroupErrorVisible = true
        }
        if selectedChoice == nil {
            isFirstChoiceA11yFocused = true
        } else {
            isFirstChoiceA11yFocused = false
        }
    }
    private func validateChoiceGroupBad() {
        choiceGroupErrorVisibleBad = false
        if selectedChoiceBad == nil {
            choiceGroupErrorVisibleBad = true
        }
    }

    private func validateBadForm() {
        firstNameErrorVisibleBad = false
        lastNameErrorVisibleBad = false
        emailErrorVisibleBad = false
        if emailBad.isEmpty {
            emailErrorVisibleBad = true
        }
        if lnameBad.isEmpty {
            lastNameErrorVisibleBad = true
        }
        if fnameBad.isEmpty {
            firstNameErrorVisibleBad = true
        }
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Error validation is used to convey error messages for missing or incorrectly entered data. Use `AccessibilityFocusState` to move VoiceOver focus to the first invalid input or error text when submitting a form with invalid data. Use an `.accessibilityHint` matching the visible error message text for each invalid input. Visually indicate required fields e.g. with an *.")
                        .padding(.bottom)

                    GoodExampleForm()
                    ChoiceGroupSection()
                    BadExampleForm()
                    ChoiceGroupSectionBad()
                }
                .padding()
                .navigationTitle("Error Validation")
            }
            .onChange(of: selectedChoice) { newValue in
                if newValue != nil {
                    choiceGroupErrorVisible = false
                }
            }
            .onChange(of: choiceGroupErrorVisible) { visible in
                if visible && selectedChoice == nil {
                    withAnimation {
                        proxy.scrollTo("choice_1", anchor: .center)
                    }
                    // Delay to ensure the view is on-screen before moving accessibility focus
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isFirstChoiceA11yFocused = true
                    }
                }
            }
            .onChange(of: selectedChoiceBad) { newValue in
                if newValue != nil {
                    choiceGroupErrorVisibleBad = false
                }
            }
        }
    }
}

struct ErrorValidationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ErrorValidationView()
        }
    }
}

