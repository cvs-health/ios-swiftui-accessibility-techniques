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


struct CombiningFocusWatch: View {
    
    let darkBlue = Color(red: 26/255, green: 115/255, blue: 206/255)
    let users = [
      User(id: UUID(), image: "person.crop.circle", name: "John Doe"),
      User(id: UUID(), image: "person", name: "Jane Doe"),
      User(id: UUID(), image: "person.fill", name: "Johnny Appleseed")
    ]

    var body: some View {
        ScrollView {
            Text("Use `.accessibilityElement(children: .combine)` to combine child views into a parent view focused by VoiceOver as a single element. When combining child elements their accessibility properties may not all transfer into the combined view as expected. If a child `Button` is combined into a parent element the button's accessibility label will not transfer unless the `.isButton` trait is removed. If important traits are removed in the child elements make sure to add them back to the combined accessibility element.")
            Text("Good Example")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h2)
                .foregroundColor(.green)
            Divider()
                .frame(height: 2.0, alignment: .leading)
                .background(.green)
                .padding(.bottom)
            VStack {
                ForEach(users) { user in
                    UserCell(user: user)
                }
            }
            NavigationLink(destination: DetailCombiningFocusGood()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("Good Example")
                .buttonStyle(.plain)
                .padding(.bottom)
            Text("Bad Example")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h2)
                .foregroundColor(.red)
            Divider()
                .frame(height: 2.0, alignment: .leading)
                .background(.red)
                .padding(.bottom)
            VStack {
                ForEach(users) { user in
                    UserCellBad(user: user)
                }
            }
            NavigationLink(destination: DetailCombiningFocusBad()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("Bad Example")
                .buttonStyle(.plain)
                .padding(.bottom)
        }
    }
}

struct DetailCombiningFocusGood: View {
    var body: some View {
        ScrollView {
            Text("The good combining focus example uses `.accessibilityElement(children: .combine)` to combine child views into a parent view focused by VoiceOver as a single element. `.accessibility(removeTraits: .isButton)` is used to remove the button trait off the child button element so that the button's accessibility label becomes part of the combined parent element. `.accessibility(addTraits: .isButton)` is used to add the button trait back to the combined parent element.")
        }
            .navigationTitle("`Good Example`")
    }
}
struct DetailCombiningFocusBad: View {
    var body: some View {
        ScrollView {
            Text("The bad combining focus example does not use `.accessibilityElement(children: .combine)` to combine child views into a parent view focused by VoiceOver as a single element. VoiceOver focuses on each individual child element and they are not spoken in a unique and meaningful way.")
        }
            .navigationTitle("Bad Example")
    }
}


#Preview {
    NavigationStack {
        CombiningFocusWatch()
    }
}
