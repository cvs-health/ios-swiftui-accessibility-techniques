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
 
struct DarkModeView: View {

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Make sure that text and non-text content has sufficient contrast in both light and dark mode. Use `@Environment(\\.colorScheme)` to check if the user is in dark or light mode and then adjust the colors to meet contrast requirements for both modes.")
                    .padding(.bottom)
                Text(colorScheme == .dark ? "`.dark` mode `colorScheme` Detected" : "`.light` Mode `colorScheme` Detected").bold()
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
                VStack(alignment:.leading) {
                    Text("Enabling Dark Mode").font(.title).accessibilityAddTraits(/*@START_MENU_TOKEN@*/.isHeader/*@END_MENU_TOKEN@*/).accessibilityHeading(.h1).bold().foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    Text("1. Open iOS Settings")
                    Button(action: { self.openSettings() }) {
                       Text("Open Settings")
                    }.padding(.leading).tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                    Text("2. Go to **Display & Brightness** from the Settings home page.")
                    Text("3. Choose between Light or Dark appearance or select Automatic.")
                    Text("**Dark Mode** improves readability for users with visual impairments and for users when reading at night or in low light conditions.").padding()
                        .background(colorScheme == .dark ? .white : .black)
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                    Button("Tap here if you love Dark Mode!") {
                    }.padding(.init(top: 10, leading: 40, bottom: 10, trailing: 40)).tint(Color(colorScheme == .dark ? .black : .white)).bold()
                        .frame(width: 300)
                        .background(Color(colorScheme == .dark ? .white : .black))
                        .cornerRadius(10)
                }
                DisclosureGroup("Details") {
                    Text("The good dark mode example uses `.tint(Color(colorScheme == .dark ? .systemBlue : .blue))` to give the blue button text sufficient contrast in light and dark mode. `.background(colorScheme == .dark ? .white : .black)` and `.foregroundColor(colorScheme == .dark ? .black : .white)` are used to provide sufficient contrasting colors in dark and light mode. The custom button uses `.tint(Color(colorScheme == .dark ? .black : .white))` and `.background(Color(colorScheme == .dark ? .white : .black))` to change between colors with sufficient contrast in dark and light mode.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
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
                VStack(alignment:.leading) {
                    Text("Enabling Dark Mode").font(.title).bold().foregroundColor(darkRed)
                    Text("1. Open iOS Settings")
                    Button(action: { self.openSettings() }) {
                       Text("Open Settings")
                    }.padding(.leading)
                    Text("2. Go to **Display & Brightness** from the Settings home page.")
                    Text("3. Choose between Light or Dark appearance or select Automatic.")
                    VStack {
                        Text("**Dark Mode** improves readability for users with visual impairments and for users when reading at night or in low light conditions.").padding()
                    }.background(.black)
                    Button("Tap here if you love Dark Mode!") {
                    }.padding(.init(top: 10, leading: 40, bottom: 10, trailing: 40)).tint(.white).bold()
                        .frame(width: 300)
                        .background(Color(colorScheme == .dark ? .white : .black))
                        .cornerRadius(10)
                }
                DisclosureGroup("Details") {
                    Text("The bad dark mode example uses the default blue button text which has insufficient contrast in light mode. `.background(.black)` is used without providing a foreground color or changing colors for dark and light mode. The custom button uses `.tint(.white)` and `.background(Color(colorScheme == .dark ? .white : .black))` which changes the background color but does not change the button text color to a sufficient contrasting color in dark mode.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
            }
            .navigationBarTitle("Dark Mode")
            .padding()
        }
 
    }
    
    private func openSettings() {
          if let url = URL(string: UIApplication.openSettingsURLString) {
              if UIApplication.shared.canOpenURL(url) {
                  UIApplication.shared.open(url, options: [:], completionHandler: nil)
              }
          }
      }
}
 
struct DarkModeView_Previews: PreviewProvider {
    static var previews: some View {
        DarkModeView()
    }
}
