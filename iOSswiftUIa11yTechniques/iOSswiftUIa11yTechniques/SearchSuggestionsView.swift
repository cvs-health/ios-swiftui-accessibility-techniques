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
    let suggestions = ["Apple", "Banana", "Cherry", "Date", "Fig", "Grape"]
    
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
                    Text("The good Accessibility Notifications example posts an `AccessibilityNotification.Announcement` that speaks the \"1 Item added to cart.\" status message to VoiceOver when activating the Add to Cart button. The announcement is posted with a 0.1 second delay to make it speak correctly to VoiceOver.")
                }.padding()
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
                DisclosureGroup("Details") {
                    Text("The bad Accessibility Notifications example does not speak an accessibility announcement notification to VoiceOver when the \"1 Item added to cart.\" status message displays.")
                }.padding()
            }
            .padding()
            .navigationTitle("Accessibility Notifications")

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
    
    func postAccessibilityAnnouncement() {
        let count = filteredSuggestions().count
        if count >  0 {
            AccessibilityNotification.Announcement("\(count) suggestions are now available.").post()
        }
    }
}

    

struct SearchSuggestionsView_Previews: PreviewProvider {
    static var previews: some View {
        SearchSuggestionsView()
    }
}
