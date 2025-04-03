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
            NavigationLink(destination: AlertsView()) {
                Text("Alerts")
            }
            NavigationLink(destination: ButtonsUIKitView()) {
                Text("Buttons")
            }
            NavigationLink(destination: CheckboxesView()) {
                Text("Checkboxes")
            }
            NavigationLink(destination: ConfirmationDialogsView()) {
                Text("Confirmation Dialogs")
            }
            NavigationLink(destination: DateTimePickersView()) {
                Text("Date & Time Pickers")
            }
            NavigationLink(destination: GroupingControlsView()) {
                Text("Grouping Controls")
            }
            NavigationLink(destination: InputInstructionsView()) {
                Text("Input Instructions")
            }
            NavigationLink(destination: LinksView()) {
                Text("Links")
            }
            NavigationLink(destination: MenusView()) {
                Text("Menus")
            }
            NavigationLink(destination: PickersView()) {
                Text("Pickers")
            }
            NavigationLink(destination: PopoversView()) {
                Text("Popovers")
            }
            NavigationLink(destination: RadioButtonsView()) {
                Text("Radio Buttons")
            }
            NavigationLink(destination: SearchSuggestionsView()) {
                Text("Search Suggestions")
            }
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
        .navigationTitle("UI Controls")
    }
}

struct UIControlsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            UIControlsView()
        }
    }
}
