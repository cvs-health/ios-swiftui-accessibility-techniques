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

struct DragDropView: View {
    @State private var goodItems = ["Apples", "Bananas", "Cherries", "Dates", "Elderberries"]
    @State private var badItems = ["Apples", "Bananas", "Cherries", "Dates", "Elderberries"]
    @State private var goodSelectedItem: String?
    @State private var goodDraggingItem: String?
    @State private var badDraggingItem: String?

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Drag and drop allows users to reorder items by dragging them to a new position. Provide visible single-tap move buttons so users who cannot perform drag gestures can still reorder items. Additionally, use `accessibilityAction`s for \"Move Up\" and \"Move Down\" so VoiceOver and Switch Control users can reorder items without gestures. Use `.accessibilityHint` to communicate that items are reorderable.")
                    .padding(.bottom)
                Text("Good Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                Text("Good Example Reorderable List")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                ForEach(goodItems, id: \.self) { item in
                    reorderableRow(item: item, items: $goodItems, draggingItem: $goodDraggingItem, selectedItem: $goodSelectedItem, accessible: true)
                }
                if let selected = goodSelectedItem, let index = goodItems.firstIndex(of: selected) {
                    HStack(spacing: 16) {
                        Button {
                            guard index > 0 else { return }
                            withAnimation {
                                goodItems.move(fromOffsets: IndexSet(integer: index), toOffset: index - 1)
                            }
                        } label: {
                            Label("Move Up", systemImage: "arrow.up")
                                .frame(maxWidth: .infinity)
                        }
                        .disabled(index == 0)
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        Button {
                            guard index < goodItems.count - 1 else { return }
                            withAnimation {
                                goodItems.move(fromOffsets: IndexSet(integer: index), toOffset: index + 2)
                            }
                        } label: {
                            Label("Move Down", systemImage: "arrow.down")
                                .frame(maxWidth: .infinity)
                        }
                        .disabled(index == goodItems.count - 1)
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }
                    .padding(.top, 8)
                }
                DisclosureGroup("Details") {
                    Text("The good drag and drop example lets users tap a row to select it, then use visible \"Move Up\" and \"Move Down\" buttons below the list to reorder. This provides a single-tap alternative to drag gestures. It also uses `.accessibilityAction` to add \"Move Up\" and \"Move Down\" custom actions for each item. VoiceOver users can swipe up or down to access these actions, and Switch Control or Full Keyboard Access users can open the Actions menu. Each item has an `.accessibilityHint` telling users they can reorder it using actions.")
                }
                .padding(.bottom).accessibilityHint("Good Example Reorderable List")
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
                Text("Bad Example Reorderable List")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                ForEach(badItems, id: \.self) { item in
                    reorderableRow(item: item, items: $badItems, draggingItem: $badDraggingItem, selectedItem: .constant(nil), accessible: false)
                }
                DisclosureGroup("Details") {
                    Text("The bad drag and drop example only supports touch-based drag and drop with no single-tap alternative. There are no visible move buttons for users who cannot perform drag gestures, and no `.accessibilityAction` custom actions for VoiceOver, Switch Control, or Full Keyboard Access users to reorder items.")
                }
                .padding(.bottom).accessibilityHint("Bad Example Reorderable List")
            }
            .padding()
            .navigationTitle("Drag & Drop")
        }
    }

    @ViewBuilder
    private func reorderableRow(item: String, items: Binding<[String]>, draggingItem: Binding<String?>, selectedItem: Binding<String?>, accessible: Bool) -> some View {
        let index = items.wrappedValue.firstIndex(of: item)!
        let isFirst = index == 0
        let isLast = index == items.wrappedValue.count - 1

        let isSelected = accessible && selectedItem.wrappedValue == item

        HStack {
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
            Text(item)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
                    .fontWeight(.bold)
                    .accessibilityHidden(true)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if accessible {
                withAnimation {
                    selectedItem.wrappedValue = selectedItem.wrappedValue == item ? nil : item
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? Color.accentColor.opacity(0.12) : Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 3)
        )
        .onDrag {
            draggingItem.wrappedValue = item
            return NSItemProvider(object: item as NSString)
        }
        .onDrop(of: [.text], delegate: ReorderDropDelegate(
            item: item,
            items: items,
            draggingItem: draggingItem
        ))
        .if(accessible) { view in
            view
                .accessibilityHint("Reorderable. Use actions to move.")
                .accessibilityAction(named: "Move Up") {
                    if !isFirst {
                        withAnimation {
                            items.wrappedValue.move(fromOffsets: IndexSet(integer: index), toOffset: index - 1)
                        }
                    }
                }
                .accessibilityAction(named: "Move Down") {
                    if !isLast {
                        withAnimation {
                            items.wrappedValue.move(fromOffsets: IndexSet(integer: index), toOffset: index + 2)
                        }
                    }
                }
        }
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct ReorderDropDelegate: DropDelegate {
    let item: String
    @Binding var items: [String]
    @Binding var draggingItem: String?

    func performDrop(info: DropInfo) -> Bool {
        draggingItem = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let draggingItem,
              draggingItem != item,
              let fromIndex = items.firstIndex(of: draggingItem),
              let toIndex = items.firstIndex(of: item)
        else { return }
        withAnimation {
            items.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}

#Preview {
    NavigationStack {
        DragDropView()
    }
}
