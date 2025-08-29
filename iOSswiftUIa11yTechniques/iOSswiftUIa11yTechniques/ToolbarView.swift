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

struct ToolbarGoodView: View {
    
    @State private var isOn = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Exploring the Coastline")
                    .font(.title)
                    .fontWeight(.bold)
                Text("""
                The quiet rhythm of the tide has a way of slowing everything down. 
                Morning light spreads across the water, and gulls trace wide circles 
                above the harbor. People gather at the pier for coffee, exchanging 
                small bits of news before the day begins.
                """)
                    .font(.body)
                Text("""
                Just beyond the cliffs, trails weave through pine and cedar. 
                It’s the kind of place where you lose track of time, noticing 
                only the wind, the salt in the air, and the sound of waves 
                breaking far below.
                """)
                    .font(.body)
            }
            .padding()
        }
            .background(.regularMaterial) // Liquid Glass effect
            .toolbarBackground(.ultraThinMaterial)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button {
                        print("Back tapped")
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                    }.accessibilityLabel("Previous Page")
                        .accessibilityShowsLargeContentViewer {
                            Label("Previous Page", systemImage: "arrow.uturn.backward")
                        }
                    Button {
                        print("Folder tapped")
                    } label: {
                        Image(systemName: "folder")
                    }.accessibilityLabel("Files")
                        .accessibilityShowsLargeContentViewer {
                            Label("Files", systemImage: "folder")
                        }
                    Toggle(isOn: $isOn) {
                        Image(systemName: isOn ? "heart.fill" : "heart")
                    }
                    .accessibilityLabel("Favorite")
                    .accessibilityShowsLargeContentViewer {
                        Label("Favorite", systemImage: isOn ? "heart.fill" : "heart")
                    }
                    .accessibilityHint(isOn ? "Removes this page from your favorites" : "Adds this page to your favorites")
                    Spacer()
                    Button {
                        print("Share tapped")
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    Spacer()
                    Button {
                        print("Trash tapped")
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            print("Edit tapped")
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }.accessibilityLabel("Edit")
                            .accessibilityShowsLargeContentViewer {
                                Label("Edit", systemImage: "square.and.pencil")
                            }

                    }
                }
                .toolbarBackground(.ultraThinMaterial, for: .bottomBar)
                .toolbarBackground(.visible, for: .bottomBar)
            .navigationTitle("Toolbars Good Example")
    }
}


struct ToolbarBadView: View {
    @State private var isOn = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Exploring the Coastline")
                    .font(.title)
                    .fontWeight(.bold)
                Text("""
                The quiet rhythm of the tide has a way of slowing everything down. 
                Morning light spreads across the water, and gulls trace wide circles 
                above the harbor. People gather at the pier for coffee, exchanging 
                small bits of news before the day begins.
                """)
                    .font(.body)
                Text("""
                Just beyond the cliffs, trails weave through pine and cedar. 
                It’s the kind of place where you lose track of time, noticing 
                only the wind, the salt in the air, and the sound of waves 
                breaking far below.
                """)
                    .font(.body)
            }
            .padding()
        }
            .background(.regularMaterial) // Liquid Glass effect
            .toolbarBackground(.ultraThinMaterial)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button {
                        print("Back tapped")
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                    }
                    Button {
                        print("Folder tapped")
                    } label: {
                        Image(systemName: "folder")
                    }
                    Toggle(isOn: $isOn) {
                        Image(systemName: isOn ? "heart.fill" : "heart")
                    }
                    Spacer()
                    Button {
                        print("Share tapped")
                    } label: {
                        Label("", systemImage: "square.and.arrow.up")
                    }
                    Spacer()
                    Button {
                        print("Trash tapped")
                    } label: {
                        Label("", systemImage: "trash")
                    }
                }
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            print("Edit tapped")
                        } label: {
                            Image(systemName: "square.and.pencil") //BAD EXAMPLE FOR LARGE TEXT VIEWER
                        }
                    }
                }
                .toolbarBackground(.ultraThinMaterial, for: .bottomBar)
                .toolbarBackground(.visible, for: .bottomBar)
            .navigationTitle("Toolbars Bad Example")
    }
}


struct ToolbarView: View {
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Toolbar image buttons need meaningful `Label` or `.accessibilityLabel` text that describes their purpose to VoiceOver users and shows a useful name to Voice Control users. `Label` text will display in the Large Content Viewer automatically but if using `.accessibilityLabel` you will need to manually add `.accessibilityShowsLargeContentViewer` to make the label text visible in the Large Content Viewer. An `.accessibilityHint` text can be added if necessary to describe what happens when a VoiceOver user activates the button.")
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
                NavigationLink("Toolbars Good Example", destination: ToolbarGoodView())
                DisclosureGroup("Details") {
                    Text("The good example uses `Label` or `.accessibilityLabel` text for VoiceOver and Voice Control users. `.accessibilityShowsLargeContentViewer` is used when there is no `Label` text to show in the Large Content Viewer. An `.accessibilityHint` is added to describe what happens when the Favorite toggle is activated.")
                }.padding(.bottom).accessibilityHint("Good Example")
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
                NavigationLink("Toolbars Bad Example", destination: ToolbarBadView())
                DisclosureGroup("Details") {
                    Text("The bad example has no `Label` or `.accessibilityLabel` text for VoiceOver and Voice Control users. `.accessibilityShowsLargeContentViewer` is not used to label text in the Large Content Viewer.")
                }.padding(.bottom).accessibilityHint("Bad Example")
            }
            .navigationTitle("Toolbars")
            .padding()
        }
 
    }
}



#Preview {
    NavigationStack {
        ToolbarView()
    }
}
