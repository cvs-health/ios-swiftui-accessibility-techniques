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
                Text("Multi-selection lists allow users to select multiple items from a list. Use `.accessibilityAddTraits(.isSelected)` to communicate the selected state to VoiceOver. Use `.accessibilityRemoveTraits(.isButton)` on the row `Button` so VoiceOver does not speak the redundant \"Button\" trait. Use `.accessibilityValue()` with \"Selected\" or \"Not Selected\" to provide clear state information.")
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
                    .accessibilityRemoveTraits(.isButton)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                    .accessibilityValue(isSelected ? "Selected" : "Not Selected")
                }
                .listStyle(.insetGrouped)
                .frame(height: 280)
                DisclosureGroup("Details") {
                    Text("The good native list example uses a `List` with `Button` rows and `.listStyle(.insetGrouped)` for a native iOS look. `.accessibilityAddTraits(.isSelected)` is applied when the item is selected so VoiceOver announces the selected state. `.accessibilityRemoveTraits(.isButton)` removes the redundant \"Button\" trait. `.accessibilityValue()` provides \"Selected\" or \"Not Selected\" value text.")
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
                ForEach(fruits, id: \.self) { fruit in
                    let isSelected = goodCustomSelection.contains(fruit)
                    Button {
                        toggleSelection(fruit, in: &goodCustomSelection)
                    } label: {
                        HStack {
                            Text(fruit)
                                .foregroundColor(.primary)
                            Spacer()
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                                    .fontWeight(.bold)
                            }
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
                    .accessibilityRemoveTraits(.isButton)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                    .accessibilityValue(isSelected ? "Selected" : "Not Selected")
                }
                DisclosureGroup("Details") {
                    Text("The good custom list view example uses `ForEach` with `Button` rows and custom rounded rectangle styling instead of a native `List`. The same accessibility modifiers are applied: `.accessibilityAddTraits(.isSelected)`, `.accessibilityRemoveTraits(.isButton)`, and `.accessibilityValue()` with \"Selected\" or \"Not Selected\".")
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
                Text("Bad Example Multi-Selection List")
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
                    let isSelected = badSelection.contains(fruit)
                    Button {
                        toggleSelection(fruit, in: &badSelection)
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
                }
                .listStyle(.insetGrouped)
                .frame(height: 280)
                DisclosureGroup("Details") {
                    Text("The bad multi-selection list example has no `.accessibilityAddTraits(.isSelected)` so VoiceOver does not announce the selected state. There is no `.accessibilityValue()` to communicate whether an item is selected. VoiceOver speaks the redundant \"Button\" trait because `.accessibilityRemoveTraits(.isButton)` is not used. VoiceOver users have no way to know which items are currently selected.")
                }
                .padding(.bottom).accessibilityHint("Bad Example Multi-Selection List")
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
