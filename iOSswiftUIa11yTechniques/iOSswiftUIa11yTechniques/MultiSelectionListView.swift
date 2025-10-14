//
//  MultiSelectionListView.swift
//  iOSswiftUIa11yTechniques
//
//  Created by Paul Adam on 9/10/25.
//

import SwiftUI

struct MultiSelectionList<Item: Hashable & CustomStringConvertible>: View {
    let items: [Item]
    @Binding var selection: Set<Item>

    var body: some View {
        List(items, id: \.self) { item in
            Button {
                toggle(item)
            } label: {
                HStack {
                    Text(item.description)
                        .foregroundColor(.primary)
                    Spacer()
                    if selection.contains(item) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .listStyle(.insetGrouped) // nice iOS look
    }

    private func toggle(_ item: Item) {
        if selection.contains(item) {
            selection.remove(item)
        } else {
            selection.insert(item)
        }
    }
}

struct MultiSelectionListView: View {
    let fruits = ["Apple", "Banana", "Cherry", "Grape"]

    @State private var selected: Set<String> = []

    var body: some View {
            MultiSelectionList(items: fruits, selection: $selected)
                .navigationTitle("Fruits")
    }
}

#Preview {
    NavigationStack {
        MultiSelectionListView()
    }
}
