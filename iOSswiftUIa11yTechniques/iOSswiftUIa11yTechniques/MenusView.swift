/*
   Copyright 2024-2025 CVS Health and/or one of its affiliates

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
    @State private var selectedPickerOption = 0

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    private var darkOrange = Color(red: 203 / 255, green: 77 / 255, blue: 0 / 255)

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
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                //Basic Menu
                Menu("Actions") {
                    Button("Duplicate", action: duplicate)
                    Button("Rename", action: rename)
                    Button("Delete…", action: delete)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                //Menu with Picker inside can have selected state checkmark shown on the left
                Menu {
                    Picker("Sort by", selection: $selectedPickerOption) {
                        Text("Best Match").tag(0)
                        Text("Distance").tag(1)
                        Text("Rating").tag(2)
                    }
                }
                label: {
                    HStack {
                        Text(selectedPickerOption == 0 ? "Sort by Best Match" :
                             selectedPickerOption == 1 ? "Sort by Distance" : "Sort by Rating")
                        Image(systemName: "chevron.down")
                    }                    }
                .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The good menu example uses `Menu` to create a native SwiftUI menu that receives VoiceOver focus when opened. It is not possible to send focus back to the trigger button after closing a `Menu`. VoiceOver reads \"Actions, Button, Pop up button, Double tap to activate the picker\" The `Menu` with `Picker` example shows a built-in selection checkmark on the left side of the text that will be visible in all dynamic type sizes.")
                }.padding(.bottom).accessibilityHint("Good Example")
                Text("Platform Defect Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.orange) : darkOrange)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.orange) : darkOrange)
                    .padding(.bottom)
                Text("Platform Defect Example `Menu` with `Button` checkmark `Image` ")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                //Menu with buttons inside can have an image on the right side only but it will disappear in the largest dynamic type sizes
                Menu {
                    Button(action: {
                        selectedOption = "Best Match"
                    }) {
                        HStack {
                            if selectedOption == "Best Match" {
                                Image(systemName: "checkmark")
                            }
                            Text("Best Match")
                        }
                    }
                    Button(action: {
                        selectedOption = "Distance"
                    }) {
                        HStack {
                            if selectedOption == "Distance" {
                                Image(systemName: "checkmark")
                            }
                            Text("Distance")
                        }
                    }
                    Button(action: {
                        selectedOption = "Rating"
                    }) {
                        HStack {
                            if selectedOption == "Rating" {
                                Image(systemName: "checkmark")
                            }
                            Text("Rating")
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
                    VStack {
                        Text("The `Menu` with `Button` checkmark `Image` platform defect example uses menu button icon images that appear on the right side of the text and will disappear at the largest dynamic type sizes.")
                    }
                }.padding(.bottom).accessibilityHint("Platform Defect Example `Menu` with `Button` checkmark `Image`")
                Text("Platform Defect Example `Menu` `Section` `header` text and `.destructive` `Button` text have insufficient contrast. `Section` `header` text missing heading trait.")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Menu {
                    Section(header: Text("Map")) {
                        Button(action: {
                            print("Map Action")
                        }) {
                            HStack {
                                Image(systemName: "map")
                                Text("Show Map")
                            }
                        }
                    }
                    Section(header: Text("Edit")) {
                        Button(action: {
                            print("Create New Action")
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Create New")
                            }
                        }
                        
                        Button(action: {
                            print("Lock Action")
                        }) {
                            HStack {
                                Image(systemName: "lock")
                                Text("Lock")
                            }
                        }
                        Section(header: Text("Actions")) {
                            Button(action: {
                                print("Location Search Action")
                            }) {
                                HStack {
                                    Image(systemName: "mappin")
                                    Text("Location Search")
                                }
                            }
                            
                            Button(action: {
                                print("Share Action")
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share")
                                }
                            }
                            Button(role: .destructive, action: {
                                print("Delete Action")
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Delete")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                        .frame(width: 24, height: 24)
                        .accessibilityLabel("Map Options")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    VStack {
                        Text("The platform defect example uses a native `Menu` with `Section` `header` text and the `.destructive` `Button` text has insufficient contrast. The `Section` `header` text is also missing a heading trait. The menu button icon images will disappear at the largest dynamic type sizes.")
                    }
                }.padding(.bottom).accessibilityHint("Platform Defect Example `Menu` `Section` `header` text and `.destructive` `Button` text have insufficient contrast. `Section` `header` text missing heading trait.")
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
                }.padding(.bottom).accessibilityHint("Bad Example")
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
 
#Preview {
    NavigationStack {
        MenusView()
    }
}
