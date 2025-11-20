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
 
struct DecorativeView: View {
    
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Decorative images are used purely for decoration and convey no meaning to sighted users. Decorative images must be hidden from VoiceOver users. Use `Image(decorative:)` or `.accessibilityHidden(true)` to hide decorative images from VoiceOver.")
                    .padding(.bottom)
                Text("Good Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                Text("Good Example `Image(decorative:)`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Image(decorative: "newspaper")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .accessibilityIdentifier("goodImage")
                Text("Discover new offers every week and earn extra savings.")
                Link(destination: URL(string: "https://www.example.com/weeklyad")!) {
                    Text("Shop weekly ad")
                        .underline()
                        .padding(.bottom, 10)
                }
                DisclosureGroup("Details") {
                    Text("The good decorative image example uses `Image(decorative: \"newspaper\")` which prevents VoiceOver from focusing on the image.")
                }.padding(.bottom).accessibilityHint("Good Example Image(decorative:)")
                Text("Good Example `.accessibilityHidden(true)`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                    .accessibilityHidden(true)
                    .accessibilityIdentifier("goodIcon")
                Text("Hello, world!")
                DisclosureGroup("Details") {
                    Text("The good decorative icon image example uses `.accessibilityHidden(true)` which prevents VoiceOver from focusing on the icon.")
                }.padding(.bottom).accessibilityHint("Good Example `.accessibilityHidden(true)`")
                Text("Bad Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                Text("Bad Example Missing `Image(decorative:)`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Image("newspaper")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .accessibilityIdentifier("badImage")
                Text("Discover new offers every week and earn extra savings.")
                Link(destination: URL(string: "https://www.example.com/weeklyad")!) {
                    Text("Shop weekly ad")
                        .underline()
                        .padding(.bottom, 10)
                }
                DisclosureGroup("Details") {
                    Text("The bad decorative image example does not use the `decorative:` parameter which allows VoiceOver to focus on the image and read \"newspaper\" as its accessibility label.")
                }.padding(.bottom).accessibilityHint("Bad Example Missing `Image(decorative:)`")
                Text("Bad Example Missing `.accessibilityHidden(true)`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                    .accessibilityIdentifier("badIcon")
                Text("Hello, world!")
                DisclosureGroup("Details") {
                    Text("The bad decorative icon image example does not use `.accessibilityHidden(true)` which allows VoiceOver to focus on the image and read \"globe\" as its accessibility label.")
                }.padding(.bottom).accessibilityHint("Bad Example Missing `.accessibilityHidden(true)`")
            }
            .navigationTitle("Decorative Images")
            .padding()
        }
    }
}
 
struct DecorativeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DecorativeView()
        }
    }
}
