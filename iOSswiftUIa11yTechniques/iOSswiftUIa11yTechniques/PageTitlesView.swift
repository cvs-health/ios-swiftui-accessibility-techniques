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
 
struct PageTitlesView: View {
    
    @State private var pageTitle: String = "Page Titles"

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Page titles must describe the purpose of the page and be unique for each page in the app. Use `.navigationTitle` to create a title for each page. VoiceOver will speak the page title as a Heading. The page title can be updated using a variable.")
                    .padding([.bottom])
                Text("Good Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                Text("Good Example 1")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                NavigationLink(destination: PageTitleGood()) {
                    Text("Page Titles Good Example")
                }.padding().frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The first good page title example uses `.navigationTitle` to create a page title that describes the purpose of the page.")
                }.padding()
                Text("Good Example 2")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button(action: {
                        self.pageTitle = "New Page Title"
                    }) {
                        Text("Update Page Title")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading).padding()
                DisclosureGroup("Details") {
                    Text("The second good page title example uses a variable for the value of the `.navigationTitle` which is dynamically updated after tapping the Button.")
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
                NavigationLink(destination: PageTitleBad()) {
                    Text("Page Titles Bad Example")
                }.padding().frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The bad page title example does not use a `.navigationTitle` to create a page title.")
                }.padding()
            }
            .padding()
            //.navigationTitle("Page Titles")//static title
            //.navigationTitle($pageTitle)//editable title
            .navigationTitle(pageTitle)//dynamic title
        }
 
    }
}
 
struct PageTitlesView_Previews: PreviewProvider {
    static var previews: some View {
        PageTitlesView()
    }
}
