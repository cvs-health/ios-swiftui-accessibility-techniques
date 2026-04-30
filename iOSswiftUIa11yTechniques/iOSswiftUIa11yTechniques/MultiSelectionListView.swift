/*
   Copyright 2025-2026 CVS Health and/or one of its affiliates

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

struct MultiSelectionListView: View {
    @State private var goodSelection: Set<String> = []
    @State private var goodCustomSelection: Set<String> = []
    @State private var badSelection: Set<String> = []
    private let fruits = ["Apple", "Banana", "Cherry", "Grape", "Mango"]

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Multi-selection lists allow users to select multiple items from a list. Native `List` views automatically provide the selected trait to VoiceOver. When building custom list views with `ForEach`, use `.accessibilityAddTraits(.isSelected)` to communicate the selected state to VoiceOver. Use `.accessibilityValue(\"Not Selected\")` only when unselected, since there is no \"not selected\" trait. Use `.accessibilityElement(children: .contain)` and `.accessibilityLabel()` on the list container so VoiceOver users hear the group label when first moving focus into the list.")
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
                Text("Good Example Native List")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Favorite Fruits")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                    .accessibilityAddTraits(.isHeader)
                List(fruits, id: \.self) { fruit in
                    let isSelected = goodSelection.contains(fruit)
                    Button {
                        toggleSelection(fruit, in: &goodSelection)
                    } label: {
                        HStack {
                            Text(fruit)
                                .foregroundColor(.primary)
                            Spacer()
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .accessibilityValue(isSelected ? "" : "Not Selected")
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Favorite Fruits")
                .listStyle(.insetGrouped)
                .frame(height: 280)
                DisclosureGroup("Details") {
                    Text("The good native list example uses a `List` with `Button` rows and `.listStyle(.insetGrouped)` for a native iOS look. The native `List` automatically provides the selected trait to VoiceOver so no `.accessibilityAddTraits(.isSelected)` is needed. `.accessibilityValue(\"Not Selected\")` is used only when unselected since there is no \"not selected\" trait. `.accessibilityElement(children: .contain)` and `.accessibilityLabel(\"Favorite Fruits\")` on the `List` container lets VoiceOver users hear the group label when first moving focus into the list.")
                }
                .padding(.bottom).accessibilityHint("Good Example Native List")
                Text("Good Example Custom List View")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Favorite Fruits")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                    .accessibilityAddTraits(.isHeader)
                VStack {
                    ForEach(fruits, id: \.self) { fruit in
                        let isSelected = goodCustomSelection.contains(fruit)
                        Button {
                            toggleSelection(fruit, in: &goodCustomSelection)
                        } label: {
                            HStack {
                                Text(fruit)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                                    .fontWeight(.bold)
                                    .opacity(isSelected ? 1 : 0)
                                    .accessibilityHidden(true)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(isSelected ? Color.accentColor.opacity(0.12) : Color(.secondarySystemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                            )
                        }
                        .accessibilityAddTraits(isSelected ? .isSelected : [])
                        .accessibilityValue(isSelected ? "" : "Not Selected")
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Favorite Fruits")
                DisclosureGroup("Details") {
                    Text("The good custom list view example uses `ForEach` with `Button` rows and custom rounded rectangle styling instead of a native `List`. `.accessibilityAddTraits(.isSelected)` is used to communicate the selected state since `ForEach` does not provide it automatically. `.accessibilityValue(\"Not Selected\")` is used only when unselected since there is no \"not selected\" trait. `.accessibilityElement(children: .contain)` and `.accessibilityLabel(\"Favorite Fruits\")` on the container lets VoiceOver users hear the group label. The checkmark uses `.opacity()` instead of a conditional `if` so the view tree stays stable and VoiceOver does not lose its focus position after selection changes.")
                }
                .padding(.bottom).accessibilityHint("Good Example Custom List View")
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
                Text("Bad Example Custom List View")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Favorite Fruits")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                    .accessibilityAddTraits(.isHeader)
                ForEach(fruits, id: \.self) { fruit in
                    let isSelected = badSelection.contains(fruit)
                    Button {
                        toggleSelection(fruit, in: &badSelection)
                    } label: {
                        HStack {
                            Text(fruit)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                                .fontWeight(.bold)
                                .opacity(isSelected ? 1 : 0)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isSelected ? Color.accentColor.opacity(0.12) : Color(.secondarySystemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                        )
                    }
                }
                DisclosureGroup("Details") {
                    Text("The bad custom list view example uses `ForEach` with `Button` rows but has no `.accessibilityAddTraits(.isSelected)` to provide the selected trait and no `.accessibilityValue(\"Not Selected\")` to communicate unselected state. VoiceOver may still guess the selected state by reading the checkmark image, but this is not a reliable or proper way to communicate selection. There is no `.accessibilityElement(children: .contain)` or `.accessibilityLabel()` group container so VoiceOver users do not hear a group label.")
                }
                .padding(.bottom).accessibilityHint("Bad Example Custom List View")
            }
            .padding()
            .navigationTitle("Multi-Selection Lists")
        }
    }

    private func toggleSelection(_ item: String, in selection: inout Set<String>) {
        if selection.contains(item) {
            selection.remove(item)
        } else {
            selection.insert(item)
        }
    }
}

struct MultiSelectionListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MultiSelectionListView()
        }
    }
}
