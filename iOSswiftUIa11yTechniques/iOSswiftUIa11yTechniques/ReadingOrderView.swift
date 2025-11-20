/*
   Copyright 2023-20024 CVS Health and/or one of its affiliates

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
 
struct ReadingOrderView: View {
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    private var darkOrange = Color(red: 203 / 255, green: 77 / 255, blue: 0 / 255)

    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("The VoiceOver reading order should match the visual reading order presented to sighted users. If the visual layout of a page disrupts the expected VoiceOver reading order then use `.accessibilityElement(children: .contain)` to make VoiceOver read all elements in the group before moving to the next element. Or use `.accessibilityElement(children: .combine)` which causes VoiceOver to read the combined elements as a single element with one focus point.")
                    .padding(.bottom)
                Text("Good Example `.accessibilityElement(children: .contain)`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                HStack(alignment: .top) {
                    VStack(alignment: .leading){
                        Text("Starter").font(.headline).accessibilityAddTraits(.isHeader)
                        Text("2 websites")
                        Text("10GB storage")
                    }.accessibilityElement(children: .contain)
                    VStack(alignment: .leading){
                        Text("Business").font(.headline).accessibilityAddTraits(.isHeader)
                        Text("10 websites")
                        Text("100GB storage")
                    }.accessibilityElement(children: .contain)
                    VStack(alignment: .leading){
                        Text("Enterprise").font(.headline).accessibilityAddTraits(.isHeader)
                        Text("∞ websites")
                        Text("∞ storage")
                    }.accessibilityElement(children: .contain)
                }
                DisclosureGroup("Details") {
                    Text("The good reading order example uses `.accessibilityElement(children: .contain)` on each `VStack{}` container which causes VoiceOver to read the full text of each column before moving to the next column.")
                }.padding(.bottom).accessibilityHint("Good Example `.accessibilityElement(children: .contain)`")
                Text("Good Example `.accessibilityElement(children: .combine)`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                HStack(alignment: .top) {
                    VStack(alignment: .leading){
                        Text("Starter").font(.headline).accessibilityAddTraits(.isHeader)
                        Text("2 websites")
                        Text("10GB storage")
                    }.accessibilityElement(children: .combine)
                    VStack(alignment: .leading){
                        Text("Business").font(.headline).accessibilityAddTraits(.isHeader)
                        Text("10 websites")
                        Text("100GB storage")
                    }.accessibilityElement(children: .combine)
                    VStack(alignment: .leading){
                        Text("Enterprise").font(.headline).accessibilityAddTraits(.isHeader)
                        Text("∞ websites")
                        Text("∞ storage")
                    }.accessibilityElement(children: .combine)
                }
                DisclosureGroup("Details") {
                    Text("The good reading order example uses `.accessibilityElement(children: .combine)` on each `VStack{}` container which causes VoiceOver to read the full column as a single element before moving to the next column.")
                }.padding(.bottom).accessibilityHint("Good Example `.accessibilityElement(children: .combine)`")
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
                HStack(alignment: .top) {
                    VStack(alignment: .leading){
                        Text("Starter").font(.headline)
                        Text("2 websites")
                        Text("10GB storage")
                    }
                    VStack(alignment: .leading){
                        Text("Business").font(.headline)
                        Text("10 websites")
                        Text("100GB storage")
                    }
                    VStack(alignment: .leading){
                        Text("Enterprise").font(.headline)
                        Text("∞ websites")
                        Text("∞ storage")
                    }
                }
                DisclosureGroup("Details") {
                    Text("The bad reading order example does not use `.accessibilityElement(children: .contain)` on each `VStack{}` container which causes VoiceOver to read the first line of each column then read the next line of each column which does not match the expected visual reading order.")
                }.accessibilityHint("Bad Example")
            }
            .navigationTitle("Reading Order")
            .padding()
        }
 
    }
}
 
#Preview {
    NavigationStack {
        ReadingOrderView()
    }
}
