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

struct LargeContentViewerView: View {

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Large Content Viewer allows a large text size user to view a large version of content that does not resize with dynamic type. Enable Larger Accessibility Sizes under Large Text settings and then hold one finger on top an element that does not resize with dynamic type and a large version of the element will display in the middle of the screen. Use `.accessibilityShowsLargeContentViewer{}` to display a button's `Label` and `systemImage` in the large content viewer.")
                    .padding([.bottom])
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
                VStack {
                    Button(action: newMessage) {
                        Image(systemName: "questionmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }
                    .accessibilityLabel("Get Help")
                    .accessibilityShowsLargeContentViewer {
                        Label("Get Help", systemImage: "questionmark")
                    }
                    .padding(.bottom)
                    Button(action: {
                        // Handle button tap here
                    }) {
                        Image(systemName: "location.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.red)
                    }
                    .accessibilityLabel("Show My Location")
                    .accessibilityShowsLargeContentViewer {
                        Label("Show My Location", systemImage: "location.fill")
                    }
                    Button(action: {
                        // Handle button tap here
                    }) {
                        Image(systemName: "envelope.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                            .overlay(
                                Text("9")
                                    .accessibilityHidden(true)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                                    .clipShape(Circle())
                                    .offset(x: 10, y: -10),
                                alignment: .topTrailing
                            )
                    }
                    .accessibilityLabel("Messages")
                    .accessibilityShowsLargeContentViewer {
                        Label("9 Messages", systemImage: "envelope.fill")
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                DisclosureGroup("Details") {
                    Text("The good large content viewer example uses `.accessibilityShowsLargeContentViewer{}` to display the fixed sized button's `Label` and `systemImage` in the large content viewer. When holding one finger on the Get Help and Show My Location buttons they display a large version in the middle of the screen.")
                }.padding(.bottom).accessibilityHint("Good Example")
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
                VStack {
                    Button(action: newMessage) {
                            Image(systemName: "questionmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }
                    .padding(.bottom)
                    Button(action: {
                        // Handle button tap here
                    }) {
                        Image(systemName: "location.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.red)
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                DisclosureGroup("Details") {
                    Text("The bad large content viewer example does not use `.accessibilityShowsLargeContentViewer{}` to display the fixed sized button's `Label` and `systemImage` in the large content viewer. When holding one finger on the Get Help and Show My Location buttons they do not display a large version in the middle of the screen.")
                }.padding(.bottom).accessibilityHint("Bad Example")
            }
            .padding()
            .navigationTitle("Large Content Viewer")
        }
 
    }
    func newMessage() {
        
    }


}
 
struct LargeContentViewerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LargeContentViewerView()
        }
    }
}
