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

struct SearchSuggestionsView: View {
    @State private var searchText = ""
    @State private var searchTextBad = ""
    let suggestions = [
        "Apple", "Apricot", "Avocado", "Banana", "Bilberry", "Blackberry", "Blackcurrant", "Blueberry",
        "Boysenberry", "Breadfruit", "Canary Melon", "Cantaloupe", "Cherimoya", "Cherry", "Cherry Tomato",
        "Citron", "Coco Plum", "Coconut", "Cola Nut", "Cordial Plum", "Currant", "Custard Apple", "Damson",
        "Date", "Dewberry", "Dragonfruit", "Durian", "Elderberry", "Feijoa", "Fig", "Figue", "Finger Lime",
        "Flame Grape", "Flaxseed", "French Bean", "Grape", "Grapefruit", "Guaba", "Guava", "Halibut Berry",
        "Honeydew", "Huckleberry", "Huito", "Indian Fig", "Jackfruit", "Jabuticaba", "Jambul", "Jujube",
        "Jujubes", "Kaki", "Kiwano", "Kiwifruit", "Kumquat", "Lemon", "Lime", "Loquat", "Lychee", "Mango",
        "Mangosteen", "Marionberry", "Melon", "Mulberry", "Nectarine", "Nance", "Nektarine", "Nias Fruit",
        "Olive", "Orange", "Papaya", "Passion Fruit", "Peach", "Pear", "Peas", "Pepino", "Pineapple",
        "Pineapple Guava", "Pistachio", "Plum", "Plumcot", "Pomegranate", "Pomelo", "Pomme Grise",
        "Potato Berry", "Powdered Sugar Pear", "Prune", "Prunelle", "Pulpy Pear", "Pupunha", "Quince",
        "Rabbit Ears", "Rack Of Lamb", "Raisin", "Rambutan", "Raspberry", "Redcurrant", "Rhubarb",
        "Rose Apple", "Rowan Berry", "Royal Pineapple", "Rum Fruit", "Sapodilla", "Sapota", "Satsuma",
        "Satsuma Cherry", "Serissa", "Shrub Grapes", "Snow Apple", "Solomon's Seal", "Spiked Apple",
        "Strawberry", "Surinam Cherry", "Sweet Potato", "Sycamore", "Tamarillo", "Tamarind", "Tangelo",
        "Tangerine", "Taro", "Tatarian Cherry", "Tea Berry", "Tomato", "Tropical Blueberry", "Ugni",
        "Victoria Plum", "Watermelon", "White Mulberry", "White Passion Fruit", "Wongi", "Xigua Melon",
        "Yangmei", "Yangmei Gooseberry", "Yellow Cherry", "Yellow Mulberry", "Yellow Passion Fruit",
        "Yellow Watermelon", "Yuzu"
    ]

    
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Search Suggestions need to be spoken to VoiceOver users when displayed. Post an `AccessibilityNotification.Announcement` to announce the number of suggestions displayed to VoiceOver.")
                    .padding([.bottom])
                Text("Good Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                NavigationView {
                    List {
                        if (!filteredSuggestions().isEmpty) {
                            ForEach(filteredSuggestions(), id: \.self) { suggestion in
                                Text(suggestion)
                            }
                        } else {
                            ForEach(suggestions, id: \.self) { suggestion in
                                Text(suggestion)
                            }
                        }
                    }
                    .searchable(text: $searchText)
                    .searchSuggestions {
                        ForEach(filteredSuggestions(), id: \.self) { suggestion in
                            Text(suggestion)
                                .searchCompletion(suggestion)
                                .accessibilityLabel(Text("\(suggestion), suggestion"))
                                .accessibilityHint(Text("Inserts \(suggestion) into the search bar."))
                        }
                    }
                    .onChange(of: searchText) { _ in
                        postAccessibilityAnnouncement()
                    }
                }
                DisclosureGroup("Details") {
                    Text("The good search suggestions example posts an `AccessibilityNotification.Announcement` that speaks the number of suggestions shown. The suggestion buttons have a fake \"suggestion\" trait added to the `.accessibilityLabel` and a `.accessibilityHint` that says the suggestion buttons will insert the suggestion into the search bar.")
                }.padding(.bottom).accessibilityHint("Good Example")
                Text("Bad Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                NavigationView {
                    List {
                        if (!filteredSuggestionsBad().isEmpty) {
                            ForEach(filteredSuggestionsBad(), id: \.self) { suggestion in
                                Text(suggestion)
                            }
                        } else {
                            ForEach(suggestions, id: \.self) { suggestion in
                                Text(suggestion)
                            }
                        }
                    }
                    .searchable(text: $searchTextBad)
                    .searchSuggestions {
                        ForEach(filteredSuggestionsBad(), id: \.self) { suggestion in
                            Text(suggestion)
                                .searchCompletion(suggestion)
                        }
                    }
                }
                DisclosureGroup("Details") {
                    Text("The bad search suggestions example does not speak the number of suggestions shown to VoiceOver. The suggestion buttons do not have a fake \"suggestion\" trait added to the `.accessibilityLabel` or a `.accessibilityHint` that says the suggestion buttons will insert the suggestion into the search bar.")
                }.accessibilityHint("Bad Example")
            }
            .padding()
            .navigationTitle("Search Suggestions")

        }
 
    }
    func filteredSuggestions() -> [String] {
        if searchText.isEmpty {
            return []
        } else {
            return suggestions.filter { suggestion in
                suggestion.lowercased().contains(searchText.lowercased())
            }
        }
    }
    func filteredSuggestionsBad() -> [String] {
        if searchTextBad.isEmpty {
            return []
        } else {
            return suggestions.filter { suggestion in
                suggestion.lowercased().contains(searchTextBad.lowercased())
            }
        }
    }

    func postAccessibilityAnnouncement() {
        let count = filteredSuggestions().count
        if count >  0 {
            AccessibilityNotification.Announcement("\(count) suggestions shown.").post()
        }
    }
}

    

struct SearchSuggestionsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SearchSuggestionsView()
        }
    }
}
