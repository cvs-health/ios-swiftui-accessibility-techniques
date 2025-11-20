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
 
struct DeviceOrientationView: View {
    
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("WCAG requires that both Portrait and Landscape orientations are supported. Make sure each page changes to the new orientation when the device is rotated. Don't use `AppDelegate.orientationLock = .portrait` to lock the screen orientation of a page.")
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
                NavigationLink(destination: DeviceOrientationGood()) {
                    Text("Device Orientation Good Example")
                }.padding().frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The good device orientation example does not use `AppDelegate.orientationLock = .portrait` to lock the screen orientation of the page.")
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
                NavigationLink(destination: DeviceOrientationBad()) {
                    Text("Device Orientation Bad Example")
                }.padding().frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The bad device orientation example uses `AppDelegate.orientationLock = .portrait` to lock the screen orientation of the page.")
                }.padding(.bottom).accessibilityHint("Bad Example")
            }
            .padding()
            .navigationTitle("Device Orientation")
        }
 
    }
}
 
struct DeviceOrientationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DeviceOrientationView()
        }
    }
}
