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

struct User: Identifiable {
  let id: UUID
  let image: String
  let name: String
}

func showOptions() {
   print("Options button clicked.")
}

struct UserCell: View {
   var user: User

   var body: some View {
       VStack {
           Image(systemName: user.image)
           Text(user.name)
           Button("Options", action: showOptions)
               .accessibility(removeTraits: .isButton)//a11y hack fix to make sure visible Options text is included in a11ylabel when combined
       }
       .accessibilityElement(children: .combine)
       .accessibility(addTraits: .isButton)//add button trait back
   }
}
struct UserCellBad: View {
   var user: User

   var body: some View {
       VStack {
           Image(systemName: user.image)
           Text(user.name)
           Button("Options", action: showOptions)
       }
   }
}

 
struct CombiningFocusView: View {
    
    let users = [
      User(id: UUID(), image: "person.crop.circle", name: "John Doe"),
      User(id: UUID(), image: "person", name: "Jane Doe"),
      User(id: UUID(), image: "person.fill", name: "Johnny Appleseed")
    ]

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Use `.accessibilityElement(children: .combine)` to combine child views into a parent view focused by VoiceOver as a single element. When combining child elements their accessibility properties may not all transfer into the combined view as expected. If a child `Button` is combined into a parent element the button's accessibility label will not transfer unless the `.isButton` trait is removed. If important traits are removed in the child elements make sure to add them back to the combined accessibility element.")
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
                VStack {
                    ForEach(users) { user in
                        UserCell(user: user)
                    }
                }
                DisclosureGroup("Details") {
                    Text("The good combining focus example uses `.accessibilityElement(children: .combine)` to combine child views into a parent view focused by VoiceOver as a single element. `.accessibility(removeTraits: .isButton)` is used to remove the button trait off the child button element so that the button's accessibility label becomes part of the combined parent element. `.accessibility(addTraits: .isButton)` is used to add the button trait back to the combined parent element.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
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
                VStack {
                    ForEach(users) { user in
                        UserCellBad(user: user)
                    }
                }
                DisclosureGroup("Details") {
                    Text("The bad combining focus example does not use `.accessibilityElement(children: .combine)` to combine child views into a parent view focused by VoiceOver as a single element. VoiceOver focuses on each individual child element and they are not spoken in a unique and meaningful way.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
            }
            .navigationBarTitle("Combining Focus")
            .padding()
        }
 
    }
}
 
struct CombiningFocusView_Previews: PreviewProvider {
    static var previews: some View {
        CombiningFocusView()
    }
}




