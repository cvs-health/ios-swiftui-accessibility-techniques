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

struct TabsWatch: View {
    
    let darkBlue = Color(red: 26/255, green: 115/255, blue: 206/255)
    @State private var tab1Visible = true
    @State private var tab2Visible = false
    @State private var tab1VisibleBad = true
    @State private var tab2VisibleBad = false

    var body: some View {
        ScrollView {
            Text("Use `TabView` to create native tab controls with selected state. Give each `TabView` a unique and meaningful `.accessibilityLabel`. For custom tabs use `isTabBar` and `isSelected` Traits with `.accessibilityElement(children: .contain)`.")
            Text("Platform Defect Examples")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h2)
                .foregroundColor(.orange)
            Divider()
                .frame(height: 2.0, alignment:.leading)
                .background(.orange)
                .padding(.bottom)
            Text("`TabView` `.accessibilityLabel`")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
            NavigationLink(destination: TabsGood()) {
                Text("Tabs Good Example")
            }
                .accessibilityHint("TabView .accessibilityLabel")
                .padding()
            NavigationLink(destination: DetailTabsGood()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("TabView .accessibilityLabel")
                .buttonStyle(.plain)
                .padding(.bottom)
            Text("`.tabViewStyle(.page)` `.accessibilityLabel`")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
            TabView {
                Text("First Slide")
                Text("Second Slide")
                Text("Third Slide")
                Text("Fourth Slide")
            }
            .frame(height: 150)
            .tabViewStyle(.page)
            .indexViewStyle(.page)
            .accessibilityLabel("Slideshow")
            .accessibilityIdentifier("tabsGood2")
            NavigationLink(destination: DetailTabsGood2()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("TabView .accessibilityLabel")
                .buttonStyle(.plain)
                .padding(.bottom)
            Text("`.tabViewStyle(.verticalPage)` `.accessibilityLabel`")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
            TabView {
                Text("First Slide")
                Text("Second Slide")
                Text("Third Slide")
                Text("Fourth Slide")
            }
            .frame(height: 150)
            .tabViewStyle(.verticalPage)
            .indexViewStyle(.page)
            .accessibilityLabel("Slideshow")
            .accessibilityIdentifier("tabsGood3")
            NavigationLink(destination: DetailTabsGood3()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("TabView .accessibilityLabel")
                .buttonStyle(.plain)
                .padding(.bottom)
            Text("Custom Tabs using `isTabBar` and `isSelected` Traits")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
            HStack {
                Button(action: {
                    tab1Visible = true
                    tab2Visible = false
                }) {
                    VStack {
                        Image(systemName: "house")
                            .font(.system(size: 24))
                        Text("Home").underline(tab1Visible ? true : false)
                    }.frame(minHeight: 44)
                }.padding()
                    .accessibilityAddTraits(tab1Visible ? [.isSelected] : [])
                    .buttonStyle(.plain)
                    .padding(5)
                    .foregroundColor(Color.blue)
                .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(style: StrokeStyle(lineWidth: 1))
                            .foregroundColor(Color.blue)
                    )
                Button(action: {
                    tab2Visible = true
                    tab1Visible = false
                }) {
                    VStack {
                        Image(systemName: "envelope")
                            .font(.system(size: 24))
                        Text("Messages").underline(tab2Visible ? true : false)
                    }.frame(minHeight: 44)
                }.padding()
                    .accessibilityAddTraits(tab2Visible ? [.isSelected] : [])
                    .buttonStyle(.plain)
                    .padding(5)
                    .foregroundColor(Color.blue)
                .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(style: StrokeStyle(lineWidth: 1))
                            .foregroundColor(Color.blue)
                    )
            }
            .accessibilityElement(children: .contain)
            .accessibilityAddTraits(.isTabBar)
            .accessibilityLabel("Navigation")
            if tab1Visible {
                Text("Home tab panel text.")
            }
            if tab2Visible {
                Text("Messages tab panel text.")
            }
            NavigationLink(destination: DetailTabsGood4()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("Custom Tabs using `isTabBar` and `isSelected` Traits")
                .buttonStyle(.plain)
                .padding(.bottom)
            Text("Bad Examples")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h2)
                .foregroundColor(.red)
            Divider()
                .frame(height: 2.0, alignment:.leading)
                .background(.red)
                .padding(.bottom)
            Text("Custom tabs as buttons")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
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
            NavigationLink(destination: DetailTabsBad()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("Custom tabs as buttons")
                .buttonStyle(.plain)
                .padding(.bottom)
            Text("No `.accessibilityLabel`")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
            TabView {
                Text("First Slide")
                Text("Second Slide")
                Text("Third Slide")
                Text("Fourth Slide")
            }
            .frame(height: 150)
            .tabViewStyle(.page)
            .accessibilityIdentifier("tabsBad2")
            NavigationLink(destination: DetailTabsBad2()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("No `.accessibilityLabel`")
                .buttonStyle(.plain)

        }
    }
}

struct DetailTabsGood: View {
    var body: some View {
        ScrollView {
            Text("The first good tabs example uses a native `TabView` with default functionality. VoiceOver reads the tab trait and selected state as well as the number of tabs and current tab number.")
        }
            .navigationTitle("`.accessibilityLabel`")
    }
}
struct TabsGood: View {
    var body: some View {
        TabView {
            HomeTabView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            MessagesTabView()
                .tabItem {
                    Label("Messages", systemImage: "envelope")
                }
        }
    }
}
struct HomeTabView: View {
    var body: some View {
        VStack {
            Image(systemName: "house")
                .imageScale(.large)
                .foregroundColor(.accentColor)
                .accessibilityHidden(true)
            Text("Home")
        }
        .padding()
    }
}
struct MessagesTabView: View {
    var body: some View {
        VStack {
            Image(systemName: "envelope")
                .imageScale(.large)
                .foregroundColor(.accentColor)
                .accessibilityHidden(true)
            Text("Messages")
        }
        .padding()
    }
}
struct DetailTabsGood2: View {
    var body: some View {
        ScrollView {
            Text("The second good tabs example uses a native `TabView` with `.tabViewStyle(.page)` The `TabView` also has an `.accessibilityLabel`. VoiceOver does not read the accessibility label on watchOS.")

        }
            .navigationTitle("`.tabViewStyle(.page)` `.accessibilityLabel`")
    }
}
struct DetailTabsGood3: View {
    var body: some View {
        ScrollView {
            Text("The second good tabs example uses a native `TabView` with `.tabViewStyle(.verticalPage)` The `TabView` also has an `.accessibilityLabel`. VoiceOver does not read the accessibility label on watchOS.")

        }
            .navigationTitle("`.tabViewStyle(.verticalPage)` `.accessibilityLabel`")
    }
}
struct DetailTabsGood4: View {
    var body: some View {
        ScrollView {
            Text("The custom tabs good example uses `isTabBar` and `isSelected` traits with `.accessibilityElement(children: .contain)`. VoiceOver reads the tab trait and selected state as well as the number of tabs and current tab number. The custom selected Tab has an underline to show selected state without using color alone.")

        }
            .navigationTitle("Custom Tabs using `isTabBar` and `isSelected` Traits")
    }
}
struct DetailTabsBad: View {
    var body: some View {
        ScrollView {
            Text("The first bad tabs example is coded as buttons that show and hide text. VoiceOver does not hear a selected state or tab trait for the tabs. The custom selected Tab has no underline to show selected state.")
        }
            .navigationTitle("Custom tabs as buttons")
    }
}
struct DetailTabsBad2: View {
    var body: some View {
        ScrollView {
            Text("The second bad tabs example uses `.tabViewStyle(.page)`. There is no `.accessibilityLabel`.")
        }
            .navigationTitle("No `.accessibilityLabel`")
    }
}


#Preview {
    NavigationStack {
        TabsWatch()
    }
}
