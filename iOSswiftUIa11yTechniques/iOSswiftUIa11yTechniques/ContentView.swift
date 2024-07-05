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
                    .accessibilityInputLabels(["Images"])
                NavigationLink(destination: UIControlsView()) {
                    VStack {
                        Text("UI Controls").frame(maxWidth: .infinity, alignment: .leading)
                        Text("Accordions, Buttons, Pickers, TextFields, Toggles, etc. ").frame(maxWidth: .infinity, alignment: .leading).font(.footnote).foregroundColor(.primary.opacity(0.7))
                    }
                }.accessibilityIdentifier("UI Controls")
                    .accessibilityInputLabels(["UI Controls"])
                NavigationLink(destination: PageTitlesView()) {
                    Text("Page Titles")
                }
                NavigationLink(destination: AnnouncementsView()) {
                    VStack {
                        Text("Announcements").frame(maxWidth: .infinity, alignment: .leading)
                        Text("Accessibility Notifications, Error Validation").frame(maxWidth: .infinity, alignment: .leading).font(.footnote).foregroundColor(.primary.opacity(0.7))
                    }
                }.accessibilityIdentifier("Announcements")
                    .accessibilityInputLabels(["Announcements"])
                NavigationLink(destination: ReadingOrderView()) {
                    Text("Reading Order")
                }
//                NavigationLink(destination: ActivityIndicatorView()) {
//                    Text("Activity Ring Indicator")
//                }
                NavigationLink(destination: FocusManagementView()) {
                    Text("Focus Management")
                }
                NavigationLink(destination: A11yEnhancementsView()) {
                    VStack {
                        Text("Accessibility UX Enhancements").frame(maxWidth: .infinity, alignment: .leading)
                        Text("Assistive Access, Magic Tap, Actions, Rotor, VoiceOver Proununciation, etc.").frame(maxWidth: .infinity, alignment: .leading).font(.footnote).foregroundColor(.primary.opacity(0.7))
                    }
                }.accessibilityIdentifier("Accessibility UX Enhancements")
                    .accessibilityInputLabels(["Accessibility UX Enhancements"])
                NavigationLink(destination: DynamicTypeView()) {
                    Text("Dynamic Type")
                }
                NavigationLink(destination: LanguageView()) {
                    Text("Language")
                }
                NavigationLink(destination: NavigationLinkView()) {
                    Text("Navigation")
                }
                NavigationLink(destination: DataTablesView()) {
                    Text("Data Tables")
                }
                NavigationLink(destination: ListsView()) {
                    Text("Lists")
                }
                NavigationLink(destination: CardsView()) {
                    Text("Cards")
                }
                NavigationLink(destination: TouchTargetSize()) {
                    Text("Touch Target Size")
                }
                NavigationLink(destination: UserPreferencesView()) {
                    Text("User Accessibility Preferences") // dark mode, smart invert, bold text, differientate without colors, reduce transparancy, motion, ignore invert colors, increase contrast
                }
                NavigationLink(destination: ProgressIndicatorsView()) {
                    Text("Progress Indicators")
                }
                NavigationLink(destination: AccessibilityRepresentationView()) {
                    Text("Accessibility Representation Custom Controls")
                }
                NavigationLink(destination: MeaningfulAccessibleNamesView()) {
                    Text("Meaningful Accessible Names")
                }
                NavigationLink(destination: CombiningFocusView()) {
                    Text("Combining Focus")
                }
                NavigationLink(destination: DeviceOrientationView()) {
                    Text("Device Orientation")
                }
//                NavigationLink(destination: DetailView()) {
//                    Text("Siri Shortcuts") // https://www.kodeco.com/40950083-creating-shortcuts-with-app-intents
//                }.disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
//                NavigationLink(destination: MapView()) {
//                    Text("Maps")
//                }
                NavigationLink(destination: ScrollViews()) {
                    Text("Scroll Views")
                }
                NavigationLink(destination: AccessibilityHidden()) {
                    Text("Accessibility Hidden")
                }
                NavigationLink(destination: ResponsiveLayoutsView()) {
                    Text("Responsive Layouts")
                }
                NavigationLink(destination: PrototypesView()) {
                    Text("Prototypes")
                }
//                NavigationLink(destination: WebView()) {
//                    Text("Web View")
//                }
//                NavigationLink(destination: ContactFormView()) {
//                    Text("Contact Form")
//                }
            }
            .navigationViewStyle(.stack) // stops the back button from activating when rotating the device
            .navigationTitle("SwiftUI A11y Techniques")
            Text("👩‍🦯🦼🧏‍♂️♿️🦮👨‍🦽🦻 \n \nWelcome to the iOS SwiftUI Accessibility Techniques Demo App! \n \nActivate the navigation menu button to view the iOS SwiftUI Accessibility Techniques. \n \nUse VoiceOver and other iOS accessibility features to explore the good and bad examples. Expand the details for an explanation of each example.")
                .font(.largeTitle)
                .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
