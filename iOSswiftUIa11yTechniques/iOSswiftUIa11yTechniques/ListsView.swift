/*
   Copyright 2023 CVS Health and/or one of its affiliates

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
 
struct ListsView: View {
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Lists need to have list items that are individually focusable with VoiceOver. The entire list must not be focused as one single paragraph.")
                    .padding(.bottom)
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
                Text("Milk").frame(maxWidth: .infinity, alignment: .leading)
                Text("Eggs").frame(maxWidth: .infinity, alignment: .leading)
                Text("Bread").frame(maxWidth: .infinity, alignment: .leading)
                Text("Cheese").frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Text("1. Fork repository.").frame(maxWidth: .infinity, alignment: .leading)
                Text("2. Make code changes.").frame(maxWidth: .infinity, alignment: .leading)
                Text("3. Submit pull request.").frame(maxWidth: .infinity, alignment: .leading)
                Text("4. Merge into main branch.").frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The good list example uses lists with a separate `Text()` element for each list item.")
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
                Text("Milk\nEggs\nBread\nCheese").frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Text("1. Fork repository.\n2. Make code changes.\n3. Submit pull request.\n4. Merge into main branch.").frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The bad list example uses lists with a single `Text()` element for the entire list and each list item visually separated using the `\\n` new line character.")
                }.padding(.bottom).accessibilityHint("Bad Example")
            }
            .navigationTitle("Lists")
            .padding()
        }
 
    }
}
 
#Preview {
    NavigationStack {
        ListsView()
    }
}
