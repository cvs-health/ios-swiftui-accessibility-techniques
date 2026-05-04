/*
   Copyright 2024-2026 CVS Health and/or one of its affiliates

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

enum ColorOption: String, CaseIterable {
    case black = "Black"
    case gray = "Gray"
    case white = "White"
    case red = "Red"

    var color: Color {
        switch self {
        case .black: return .black
        case .gray: return .gray
        case .white: return .white
        case .red: return .red
        }
    }
}

struct RadioButtonsView: View {
    @State private var selectedColor: ColorOption = .black
    @State private var selectedColorBad: ColorOption = .red
    @State private var selectedSize: Int? = nil
    @State private var selectedSizeBad: Int? = nil

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    private let sizeOptions = ["Small", "Medium", "Large", "X-Large"]

    var body: some View {
        ScrollView {
            VStack {
                Text("There is no native radio button control for SwiftUI in iOS. Use another native control like a `Picker` which allows only one selection or mimic radio group behavior on the web with VoiceOver by manually adding and removing accessibility traits and values to create fake radio buttons.")
                    .padding(.bottom)
                Text("Good Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                Text("Good Example Radio Buttons")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    VStack {
                        Text("Choose Color")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ForEach(ColorOption.allCases, id: \.self) { colorOption in
                            RadioButton(title: colorOption.rawValue, isSelected: $selectedColor)
                        }
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("Choose Color")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Rectangle()
                        .fill(selectedColor.color)
                        .frame(width:  150, height:  150, alignment: .leading)
                        .overlay(Rectangle().stroke(Color.primary, lineWidth:  1))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                DisclosureGroup("Details") {
                    Text("The good radio button example uses custom `Button` elements styled to look like radio buttons. `.accessibilityRemoveTraits(.isButton)` removes the button trait. `.accessibilityAddTraits(isSelected.rawValue == title ? .isSelected : [])` adds the selected trait when checked. `.accessibilityRemoveTraits(isSelected.rawValue != title ? .isSelected : [])` removes the selected trait when unchecked. `.accessibilityValue(isSelected.rawValue == title ? Text(\"Radio button, checked\") : Text(\"Radio button, unchecked\"))` adds a fake radio button trait and a checked and unchecked state. Additionally `.accessibilityElement(children: .contain)` and `.accessibilityLabel(\"Choose Color\")` are used to give the radio group a label for VoiceOver.")
                }.padding(.bottom).accessibilityHint("Good Example Radio Buttons")
                Text("Good Example Custom Choice Buttons")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Choose a size")
                    .frame(maxWidth: .infinity, alignment: .leading)
                let columns = [GridItem(.adaptive(minimum: 100, maximum: 100), spacing: 16)]
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Array(sizeOptions.enumerated()), id: \.offset) { index, size in
                        let isSelected = selectedSize == index
                        Button(action: {
                            selectedSize = index
                        }) {
                            Text(size)
                                .frame(minWidth: 100, minHeight: 100)
                                .background(isSelected ? Color.blue : Color(.systemBackground))
                                .foregroundColor(isSelected ? .white : .primary)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(isSelected ? Color.blue : Color.secondary, lineWidth: 3)
                                )
                        }
                        .accessibilityRemoveTraits(.isButton)
                        .accessibilityAddTraits(isSelected ? .isSelected : [])
                        .accessibilityRemoveTraits(!isSelected ? .isSelected : [])
                        .accessibilityValue(isSelected ? "Radio button, checked" : "Radio button, unchecked")
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Choose a size")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 6)
                DisclosureGroup("Details") {
                    Text("The good custom choice button example uses `Button` elements styled as selectable cards in a grid. Only one button can be selected at a time, functioning as a radio group. `.accessibilityRemoveTraits(.isButton)` removes the button trait. `.accessibilityAddTraits(.isSelected)` adds the selected trait to the chosen button. `.accessibilityValue` provides \"Radio button, checked\" or \"Radio button, unchecked\" states. The `LazyVGrid` container uses `.accessibilityElement(children: .contain)` and `.accessibilityLabel(\"Choose a size\")` to give the radio group a label for VoiceOver.")
                }.padding(.bottom).accessibilityHint("Good Example Custom Choice Buttons")
                Text("Bad Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                Text("Bad Example Radio Buttons")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    VStack {
                        Text("Choose Color")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ForEach(ColorOption.allCases, id: \.self) { colorOption in
                            RadioButtonBad(title: colorOption.rawValue, isSelected: $selectedColorBad)
                    }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Rectangle()
                        .fill(selectedColorBad.color)
                        .frame(width:  150, height:  150, alignment: .leading)
                        .overlay(Rectangle().stroke(Color.primary, lineWidth:  1))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                DisclosureGroup("Details") {
                    Text("The bad radio button example uses custom `Button` elements styled to look like radio buttons. There is no additional code to add a radio button trait or a selected and checked/unchecked states. VoiceOver users don't know these are radio buttons or which button is checked or unchecked. There is also no radio group label for VoiceOver.")
                }.padding(.bottom).accessibilityHint("Bad Example Radio Buttons")
                Text("Bad Example Custom Choice Buttons")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Choose a size")
                    .frame(maxWidth: .infinity, alignment: .leading)
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Array(sizeOptions.enumerated()), id: \.offset) { index, size in
                        let isSelected = selectedSizeBad == index
                        Button(action: {
                            selectedSizeBad = index
                        }) {
                            Text(size)
                                .frame(minWidth: 100, minHeight: 100)
                                .background(isSelected ? Color.blue : Color(.systemBackground))
                                .foregroundColor(isSelected ? .white : .primary)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(isSelected ? Color.blue : Color.secondary, lineWidth: 3)
                                )
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 6)
                DisclosureGroup("Details") {
                    Text("The bad custom choice button example uses `Button` elements styled as selectable cards in a grid but has no accessibility modifications. There is no radio button trait, no selected trait, no checked/unchecked value, and no group label. VoiceOver users hear each choice as a generic button with no indication of selection state or that the buttons form a single-select group.")
                }.padding(.bottom).accessibilityHint("Bad Example Custom Choice Buttons")
            }
            .navigationTitle("Radio Buttons")
            .padding()
        }
    }
}


struct RadioButton: View {
    let title: String
    @Binding var isSelected: ColorOption

    var body: some View {
        Button(action: {
            self.isSelected = ColorOption(rawValue: title)!
        }) {
            HStack {
                Circle()
                    .fill(.white)
                    .opacity(isSelected.rawValue == title ?  0.2 :  1)
                    .frame(width:  15, height:  15)
                    .overlay(Circle().stroke(isSelected.rawValue == title ? Color.blue : Color.primary, lineWidth:  isSelected.rawValue == title ?  6 :  2))
                Text(title)
                    .foregroundColor(.primary)
            }
        }
        .accessibilityRemoveTraits(.isButton)
        .accessibilityAddTraits(isSelected.rawValue == title ? .isSelected : [])
        .accessibilityRemoveTraits(isSelected.rawValue != title ? .isSelected : [])
        .accessibilityValue(isSelected.rawValue == title ? Text("Radio button, checked") : Text("Radio button, unchecked"))
    }
}
struct RadioButtonBad: View {
    let title: String
    @Binding var isSelected: ColorOption

    var body: some View {
        Button(action: {
            self.isSelected = ColorOption(rawValue: title)!
        }) {
            HStack {
                Circle()
                    .fill(.white)
                    .opacity(isSelected.rawValue == title ?  0.2 :  1)
                    .frame(width:  15, height:  15)
                    .overlay(Circle().stroke(isSelected.rawValue == title ? Color.blue : Color.primary, lineWidth:  isSelected.rawValue == title ?  6 :  2))
                Text(title)
                    .foregroundColor(.primary)
            }
        }

    }
}

#Preview {
    NavigationStack {
        RadioButtonsView()
    }
}
