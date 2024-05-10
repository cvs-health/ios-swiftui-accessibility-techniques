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

struct MenusView: View {
    @State private var isShowingPopover = false
    @State private var isShowingPopoverBad = false

    @State private var selectedOption = "Best Match"

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("VoiceOver focus must move to the menu when opened. Use `Menu` to code a native SwiftUI menu that receives VoiceOver focus when opened. SwiftUI native `Menu` does not return focus back to the trigger button when closed. It is not possible to return focus using `AccessibilityFocusState` as you can with a `.sheet()` or `.popover()`. This can be considered a defect in the native `Menu` component and bugs should be filed with Apple.")
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
                Menu("Actions") {
                    Button("Duplicate", action: duplicate)
                    Button("Rename", action: rename)
                    Button("Delete…", action: delete)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Menu {
                    Button(action: {
                        selectedOption = "Best Match"
                    }) {
                        HStack {
                            Text("Best Match")
                            Spacer()
                            if selectedOption == "Best Match" {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    Button(action: {
                        selectedOption = "Distance"
                    }) {
                        HStack {
                            Text("Distance")
                            Spacer()
                            if selectedOption == "Distance" {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    Button(action: {
                        selectedOption = "Rating"
                    }) {
                        HStack {
                            Text("Rating")
                            Spacer()
                            if selectedOption == "Rating" {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text("Sort by \(selectedOption)")
                         Image(systemName: "chevron.down")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The good menu example uses `Menu` to create a native SwiftUI menu that receives VoiceOver focus when opened. It is not possible to send focus back to the trigger button after closing a `Menu`. VoiceOver reads \"Actions, Button, Pop up button, Double tap to activate the picker\"")
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
                Button(action: {
                    isShowingPopoverBad.toggle()
                }) {
                    Text("Actions")
                }
                .frame(maxWidth: .infinity, alignment: .leading).padding(.bottom)
                if (isShowingPopoverBad){
                    VStack {
                        Button("Duplicate",
                               action: { isShowingPopoverBad.toggle() }).padding(.leading).frame(maxWidth: .infinity, alignment: .leading)
                        Button("Rename",
                               action: { isShowingPopoverBad.toggle() }).padding([.leading]).frame(maxWidth: .infinity, alignment: .leading)
                        Button("Delete",
                               action: { isShowingPopoverBad.toggle() }).padding(.leading).frame(maxWidth: .infinity, alignment: .leading)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
                DisclosureGroup("Details") {
                    Text("The bad menu example uses a custom view which does not receive VoiceOver focus when displayed and does not return focus when closed. VoiceOver reads \"Actions, Button\" and does not read that it is a popup button that activates a picker.")
                }.padding()
            }
            .navigationTitle("Menus")
            .padding()

        }
 
    }

    func duplicate() {
        // Implement duplicate action here
    }

    func rename() {
        // Implement rename action here
    }

    func delete() {
        // Implement delete action here
    }

}
 
struct MenusView_Previews: PreviewProvider {
    static var previews: some View {
        MenusView()
    }
}
