/*
   Copyright 2025 CVS Health and/or one of its affiliates

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

struct ContentViewWatch: View {
    @State var searchKeyword = ""
    @State var selection: UUID?
    
    var filteredAndSortedItems: [Techniques] {
        let filtered = techniques.filter { item in
            searchKeyword.isEmpty || item.name.lowercased().contains(searchKeyword.lowercased())
        }
        return filtered.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredAndSortedItems) { technique in
                    NavigationLink(value: technique.id) {
                        Text(technique.name)
                    }
                }
            }
            .navigationTitle("SwiftUI A11y Techniques")
            .navigationViewStyle(.stack)
            .searchable(text: $searchKeyword, placement: .toolbar)
            .navigationDestination(for: UUID.self) { id in
                if let technique = techniques.first(where: { $0.id == id }) {
                    getItemDetailView(for: technique)
                        .navigationTitle(technique.name)
                }
            }
        }
    }
    
    @ViewBuilder
    func getItemDetailView(for technique: Techniques) -> some View {
        switch technique.name.lowercased() {
        case "informative images":
            InformativeImagesWatch()
        case "decorative images":
            DecorativeImagesWatch()
        case "tabs":
            TabsWatch()
        case "headings":
            HeadingsWatch()
        case "text fields":
            TextFieldsWatch()
        case "functional images":
            FunctionalImagesWatch()
        default:
            InformativeImagesWatch()
        }
    }
    
}

#Preview {
    ContentViewWatch()
}
