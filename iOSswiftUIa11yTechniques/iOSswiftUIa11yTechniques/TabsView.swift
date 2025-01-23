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
 
struct TabsView: View {
    
    @State private var tab1Visible = true
    @State private var tab2Visible = false
    @State private var tab1VisibleBad = true
    @State private var tab2VisibleBad = false
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
//    init() {
//        UIPageControl.appearance().currentPageIndicatorTintColor = .red
//        UIPageControl.appearance().pageIndicatorTintColor = .blue
//        //UIPageControl.appearance().backgroundStyle = .prominent
//        UIPageControl.appearance().preferredIndicatorImage = UIImage(systemName: "circle")
//        UIPageControl.appearance().preferredCurrentPageIndicatorImage = UIImage(systemName: "circle.fill")
//       }

    var body: some View {
        ScrollView {
            VStack {
                Text("Tabs show and hide content inside tab panels. VoiceOver users must hear the selected tab state. Use `TabView` to create native tab controls with selected state. Give each `TabView` a unique and meaningful `.accessibilityLabel`. For custom tabs use `isTabBar` and `isSelected` Traits with `.accessibilityElement(children: .contain)`.")
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
                Text("Good Example native `TabView`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                NavigationLink(destination: TabsGoodView()) {
                    Text("Tabs Good Example")
                }.padding()
                DisclosureGroup("Details") {
                    Text("The first good tabs example uses a native `TabView` with default functionality. VoiceOver reads the tab trait and selected state as well as the number of tabs and current tab number.")
                }.padding(.bottom).accessibilityHint("Good Example native `TabView`")
                Text("Good Example `.tabViewStyle(.page)` with `.accessibilityLabel` and `backgroundDisplayMode: .always`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                TabView {
                    Text("First Slide")
                    Text("Second Slide")
                    Text("Third Slide")
                    Text("Fourth Slide")
                }
                .frame(height: 150)
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .accessibilityLabel("Slideshow")
                .accessibilityIdentifier("tabsGood2")
                .onAppear {
                      setupAppearance()
                    }
                DisclosureGroup("Details") {
                    Text("The second good tabs example uses a native `TabView` with `.tabViewStyle(.page)` and `.indexViewStyle(.page(backgroundDisplayMode: .always))` to display page indicator dots with a background. The `TabView` also has an `.accessibilityLabel`.")
                }.padding(.bottom).accessibilityHint("Good Example `.tabViewStyle(.page)` with `.accessibilityLabel` and `backgroundDisplayMode: .always`")
                Text("Good Example Custom Tabs using `isTabBar` and `isSelected` Traits with `.accessibilityElement(children: .contain)`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Button(action: {
                        tab1Visible = true
                        tab2Visible = false
                    }) {
                        VStack {
                            Image(systemName: "house")
                                .font(.system(size: 24))
                            Text("Home").underline(tab1Visible ? true : false)
                        }
                    }.padding()
                        .accessibilityAddTraits(tab1Visible ? [.isSelected] : [])
                    Button(action: {
                        tab2Visible = true
                        tab1Visible = false
                    }) {
                        VStack {
                            Image(systemName: "envelope")
                                .font(.system(size: 24))
                            Text("Messages").underline(tab2Visible ? true : false)
                        }
                    }.padding()
                        .accessibilityAddTraits(tab2Visible ? [.isSelected] : [])
                }
                .accessibilityElement(children: .contain)
                .accessibilityAddTraits(.isTabBar)
                if tab1Visible {
                    Text("Home tab panel text.")
                }
                if tab2Visible {
                    Text("Messages tab panel text.")
                }
                DisclosureGroup("Details") {
                    Text("The custom tabs good example uses `isTabBar` and `isSelected` traits with `.accessibilityElement(children: .contain)`. VoiceOver reads the tab trait and selected state as well as the number of tabs and current tab number. The custom selected Tab has an underline to show selected state without using color alone.")
                }.padding(.bottom).accessibilityHint("Good Example Custom Tabs using `isTabBar` and `isSelected` Traits with `.accessibilityElement(children: .contain)`")
                Text("Bad Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                Text("Bad Example custom tabs as buttons that show and hide text")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Button(action: {
                        tab1VisibleBad = true
                        tab2VisibleBad = false
                    }) {
                        VStack {
                            Image(systemName: "house")
                                .font(.system(size: 24))
                            Text("Home")
                        }
                    }.padding()
                    Button(action: {
                        tab1VisibleBad = false
                        tab2VisibleBad = true
                    }) {
                        VStack {
                            Image(systemName: "envelope")
                                .font(.system(size: 24))
                            Text("Messages")
                        }
                    }.padding()
                }
                if tab1VisibleBad {
                    Text("Home tab panel text.")
                }
                if tab2VisibleBad {
                    Text("Messages tab panel text.")
                }
                DisclosureGroup("Details") {
                    Text("The first bad tabs example is coded as buttons that show and hide text. VoiceOver does not hear a selected state or tab trait for the tabs. The custom selected Tab has no underline to show selected state.")
                }.padding(.bottom).accessibilityHint("Bad Example custom tabs as buttons that show and hide text")
                Text("Bad Example `.tabViewStyle(.page)` with no `.accessibilityLabel` and no `backgroundDisplayMode: .always`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                TabView {
                    Text("First Slide")
                    Text("Second Slide")
                    Text("Third Slide")
                    Text("Fourth Slide")
                }
                .frame(height: 150)
                .tabViewStyle(.page)
                .accessibilityIdentifier("tabsBad2")
                DisclosureGroup("Details") {
                    Text("The second bad tabs example uses `.tabViewStyle(.page)` which has white page indicator dots that are only visible in dark mode but are invisible in light mode. There is also no `.accessibilityLabel`.")
                }.padding(.bottom).accessibilityHint("Bad Example `.tabViewStyle(.page)` with no `.accessibilityLabel` and no `backgroundDisplayMode: .always`")
            }
            .padding()
            .navigationTitle("Tabs")

        }
 
    }
    func setupAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .red
        UIPageControl.appearance().pageIndicatorTintColor = .blue
        //UIPageControl.appearance().backgroundStyle = .prominent
        UIPageControl.appearance().preferredIndicatorImage = UIImage(systemName: "circle")
        UIPageControl.appearance().preferredCurrentPageIndicatorImage = UIImage(systemName: "circle.fill")
    }
}
 
#Preview {
    NavigationStack {
        TabsView()
    }
}
