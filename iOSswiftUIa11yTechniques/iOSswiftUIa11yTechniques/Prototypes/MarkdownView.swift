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
 
struct MarkdownView: View {
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    @State private var amount = 50.0

    
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
                //line spacing test
                VStack {
                    // Line spacing is ignored.
                    Text("Hello, World!")
                        .background(Color.green)
                        .lineSpacing(50)

                    Spacer()

                    // Line spacing is correct.
                    Text("Lorem ipsum is placeholder text commonly used in the graphic, print, and publishing industries for previewing layouts and visual mockups.")
                        .background(Color.green)
                        .lineSpacing(50)
                }
                Text("LINE SPACING TEST This is a string in a TextField with 10 point spacing applied between the bottom of one line and the top of the next.")
                    .frame(alignment: .leading)
                    .lineSpacing(10)
                Text("Hello World")
                    .tracking(20)
                VStack {
                    Text("ffi")
                        .font(.custom("AmericanTypewriter", size: 72))
                        .kerning(amount)
                    Text("ffi")
                        .font(.custom("AmericanTypewriter", size: 72))
                        .tracking(amount)

                    Slider(value: $amount, in: 0...100) {
                        Text("Adjust the amount of spacing")
                    }
                }
                Text("""
                    # Heading 1
                    
                    This is a paragraph with **bold** text and *italic* text.
                    
                    ## Heading 2
                    
                    Here's an [example link](https://www.example.com).
                
                """).frame(maxWidth: .infinity, alignment: .leading)
                Text("""
                **bold**
                  - Item 1
                  - Item 2
                  - Item 3
                
                """).frame(maxWidth: .infinity, alignment: .leading)
                Text("""
                **bold**
                  1. Item 1
                  2. Item 2
                  3. Item 3
                
                """).frame(maxWidth: .infinity, alignment: .leading)
                Text("""
                **bold**
                  - Main item 1
                    - Sub-item 1
                    - Sub-item 2
                  - Main item 2
                
                """).frame(maxWidth: .infinity, alignment: .leading)
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
            .navigationTitle("Markdown")
            .padding()
        }
 
    }
}
 
#Preview {
    NavigationStack {
        MarkdownView()
    }
}
