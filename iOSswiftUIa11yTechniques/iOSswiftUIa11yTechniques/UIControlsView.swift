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

struct UIControlsView: View {

    var body: some View {
        List {
            Text("Use the native UI Controls included with SwiftUI. Native controls have accessibility support included by default. Custom controls require extra code to make them accessible. \nUI Controls require an accessibility label and a trait. Accessibility value and state are required when present in the design.")
            NavigationLink(destination: AccordionsView()) {
                Text("Accordions")
            }
            NavigationLink(destination: ButtonsView()) {
                Text("Buttons")
            }
            NavigationLink(destination: DetailView()) {
                Text("Checkboxes")
            }.disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
            NavigationLink(destination: DialogsView()) {
                Text("Confirmation Dialogs")
            }
            NavigationLink(destination: GroupingControlsView()) {
                Text("Grouping Controls")
            }
            NavigationLink(destination: DetailView()) {
                Text("Input Instructions")
            }.disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
            NavigationLink(destination: LinksView()) {
                Text("Links")
            }
            NavigationLink(destination: DetailView()) {
                Text("Menus")
            }.disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
            NavigationLink(destination: PickersView()) {
                Text("Pickers")
            }
            NavigationLink(destination: DetailView()) {
                Text("Popovers")
            }.disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
            NavigationLink(destination: DetailView()) {
                Text("Radio Buttons")
            }.disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
            NavigationLink(destination: SegmentedControlsView()) {
                Text("Segmented Controls")
            }
            NavigationLink(destination: SheetsView()) {
                Text("Sheets")
            }
            NavigationLink(destination: SlidersView()) {
                Text("Sliders")
            }
            NavigationLink(destination: SteppersView()) {
                Text("Steppers")
            }
            NavigationLink(destination: TabsView()) {
                Text("Tabs")
            }
            NavigationLink(destination: TextFieldsView()) {
                Text("Text Fields")
            }
            NavigationLink(destination: TogglesView()) {
                Text("Toggles")
            }
        }
        .navigationBarTitle("UI Controls")
    }
}

struct UIControlsView_Previews: PreviewProvider {
    static var previews: some View {
        UIControlsView()
    }
}
