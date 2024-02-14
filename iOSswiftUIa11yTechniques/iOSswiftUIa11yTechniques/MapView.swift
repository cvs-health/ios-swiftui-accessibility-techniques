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
import MapKit
 
struct MapView: View {
    let storeCoordinates = CLLocationCoordinate2D(latitude:  37.7749, longitude: -122.4194)
        
        @State private var region: MKCoordinateRegion
        
        init() {
            _region = State(initialValue: MKCoordinateRegion(
                center: storeCoordinates,
                span: MKCoordinateSpan(latitudeDelta:  0.01, longitudeDelta:  0.01)
            ))
        }

    
    @State var showModal: Bool = false
    @State var showModalBad: Bool = false
    @AccessibilityFocusState private var isDialogHeadingFocused: Bool
    @AccessibilityFocusState private var isDialogBadHeadingFocused: Bool
    @AccessibilityFocusState private var isTriggerFocused: Bool

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Map views.")
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
                Map(coordinateRegion: $region, interactionModes: [])
                       .frame(height:  200) // Adjust size as needed
                   Text("Store Name")
                       .font(.title)
                   Text("123 Store Street")
                   Text("City, State ZIP")
                DisclosureGroup("Details") {
                    Text("The good .")
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
                DisclosureGroup("Details") {
                    Text("The bad .")
                }.padding()
            }
            .background(showModal || showModalBad == true ? colorScheme == .dark ? Color(.gray).opacity(0.5) : Color.black.opacity(0.5) : colorScheme == .dark ? Color(.black) : Color(.white))
            .navigationTitle("Maps")
            .padding()
        }
 
    }
}
 
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
