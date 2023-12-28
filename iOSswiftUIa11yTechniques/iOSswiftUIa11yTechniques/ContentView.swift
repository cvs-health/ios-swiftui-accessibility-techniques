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

struct ContentView: View {
    
    @State private var showingAlert = false

    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: HeadingsView()) {
                    Text("Headings")
                }
                NavigationLink(destination: ImagesView()) {
                    VStack {
                        Text("Images").frame(maxWidth: .infinity, alignment: .leading)
                        Text("Informative, Decorative, or Functional").frame(maxWidth: .infinity, alignment: .leading).font(.footnote).foregroundColor(.primary.opacity(0.7))
                    }
                }.accessibilityIdentifier("Images")
                NavigationLink(destination: UIControlsView()) {
                    VStack {
                        Text("UI Controls").frame(maxWidth: .infinity, alignment: .leading)
                        Text("Accordions, Buttons, Pickers, TextFields, Toggles, etc. ").frame(maxWidth: .infinity, alignment: .leading).font(.footnote).foregroundColor(.primary.opacity(0.7))
                    }
                }.accessibilityIdentifier("UI Controls")
                NavigationLink(destination: PageTitlesView()) {
                    Text("Page Titles")
                }
                NavigationLink(destination: AnnouncementsView()) {
                    VStack {
                        Text("Announcements").frame(maxWidth: .infinity, alignment: .leading)
                        Text("Accessibility Notifications, Error Validation").frame(maxWidth: .infinity, alignment: .leading).font(.footnote).foregroundColor(.primary.opacity(0.7))
                    }
                }.accessibilityIdentifier("Announcements")
                NavigationLink(destination: ReadingOrderView()) {
                    Text("Reading Order")
                }
                NavigationLink(destination: DetailView()) {
                    Text("Focus Management")
                }.disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                NavigationLink(destination: A11yEnhancementsView()) {
                    Text("Accessibility UX Enhancements")
                }
                NavigationLink(destination: DetailView()) {
                    Text("Motion Animations") //Reduce motion
                }.disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                NavigationLink(destination: DynamicTypeView()) {
                    Text("Dynamic Type")
                }
                NavigationLink(destination: DetailView()) {
                    Text("Language")
                }.disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                NavigationLink(destination: DetailView()) {
                    Text("Navigation")
                }.disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                NavigationLink(destination: DataTablesView()) {
                    Text("Data Tables")
                }
                NavigationLink(destination: ListsView()) {
                    Text("Lists")
                }
                NavigationLink(destination: CardsView()) {
                    Text("Cards")
                }
                NavigationLink(destination: DetailView()) {
                    Text("Touch Target Size")
                }.disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                NavigationLink(destination: DetailView()) {
                    Text("Responding to User Accessibility Preferences") // dark mode, smart invert, bold text, differientate without colors, reduce transparancy, motion, ignore invert colors, increase contrast
                }.disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                NavigationLink(destination: ProgressIndicatorsView()) {
                    Text("Progress Indicators")
                }
                NavigationLink(destination: DetailView()) {
                    Text("Custom Controls using .accessibilityRepresentation")
                }.disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                NavigationLink(destination: DetailView()) {
                    Text("Meaningful Accessible Names")
                }.disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                NavigationLink(destination: DetailView()) {
                    Text("Combining Focus")
                }.disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                NavigationLink(destination: DetailView()) {
                    Text("Device Orientation")
                }.disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                NavigationLink(destination: DetailView()) {
                    Text("Siri Shortcuts")
                }.disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
            }
            .navigationBarTitle("iOS SwiftUI Accessibility")
            Text("👩‍🦯🦼🧏‍♂️♿️🦮👨‍🦽🦻 \n \nWelcome to the iOS SwiftUI Accessibility Techniques Demo App! \n \nActivate the navigation menu button to view the iOS SwiftUI Accessibility Techniques. \n \nUse VoiceOver to set focus to the good and bad examples. Expand the details for an explanation of each example.")
                .font(.largeTitle)
                .padding()
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Magic Tap Activated"), message: Text("You activated Magic Tap by double-tapping with 2 fingers!"), dismissButton: .default(Text("OK")))
            }
            .accessibilityAction(.magicTap) {
                showingAlert = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
