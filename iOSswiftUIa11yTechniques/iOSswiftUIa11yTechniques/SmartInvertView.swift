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
 
struct SmartInvertView: View {

    
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Invert colors is an accessibility setting enabled by users with visual disabilities or light sensitivity which prevents them from using bright colored screens. Smart Invert reverses the colors of the display except for images, media, and controls like Toggles. Use `.accessibilityIgnoresInvertColors()` on images or other views that should not be inverted when Smart Invert is enabled.")
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
                Image("mardi-gras")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .shadow(color: Color.black.opacity(0.3), radius:  6, x:  0, y:  3)
                    .accessibilityLabel("A float with a large jester figure wearing a purple, yellow, and green hat.")
                    .accessibilityIgnoresInvertColors()
                Text("Mardi Gras Parade, New Orleans, Louisiana. Digital photo by Carol M. Highsmith, 2011.")
                    .padding(.top,4)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image("stained-glass")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .shadow(color: Color.black.opacity(0.3), radius:  6, x:  0, y:  3)
                    .accessibilityLabel("View looking up at the domed ceiling made of alternating blue, red, and yellow glass pieces.")
                    .accessibilityIgnoresInvertColors()
                Text("Stained glass ceiling, Old State Capitol, Baton Rouge, Louisiana. Digital photo by Carol M. Highsmith, 2021.")
                    .padding(.top,4)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image("carousel")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .shadow(color: Color.black.opacity(0.3), radius:  6, x:  0, y:  3)
                    .accessibilityLabel("Multi-color painted horses on a carousel.")
                    .accessibilityIgnoresInvertColors()
                Text("Carousel, Asbury Park, New Jersey. Color slide photo by John Margolies, 1978.")
                    .padding(.top,4)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The good smart invert example uses `.accessibilityIgnoresInvertColors()` on each `Image` to prevent them from inverting so that they display their natural colors.")
                }.padding()
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
                Image("mardi-gras")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .shadow(color: Color.black.opacity(0.3), radius:  6, x:  0, y:  3)
                    .accessibilityLabel("A float with a large jester figure wearing a purple, yellow, and green hat.")
                Text("Mardi Gras Parade, New Orleans, Louisiana. Digital photo by Carol M. Highsmith, 2011.")
                    .padding(.top,4)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image("stained-glass")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .shadow(color: Color.black.opacity(0.3), radius:  6, x:  0, y:  3)
                    .accessibilityLabel("View looking up at the domed ceiling made of alternating blue, red, and yellow glass pieces.")
                Text("Stained glass ceiling, Old State Capitol, Baton Rouge, Louisiana. Digital photo by Carol M. Highsmith, 2021.")
                    .padding(.top,4)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image("carousel")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .shadow(color: Color.black.opacity(0.3), radius:  6, x:  0, y:  3)
                    .accessibilityLabel("Multi-color painted horses on a carousel.")
                Text("Carousel, Asbury Park, New Jersey. Color slide photo by John Margolies, 1978.")
                    .padding(.top,4)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The bad smart invert example does not use `.accessibilityIgnoresInvertColors()` on each `Image` to prevent them from inverting which causes the images to display in reversed colors.")
                }.padding()
            }
            .navigationTitle("Smart Invert")
            .padding()
        }
 
    }
}
 
struct SmartInvertView_Previews: PreviewProvider {
    static var previews: some View {
        SmartInvertView()
    }
}
