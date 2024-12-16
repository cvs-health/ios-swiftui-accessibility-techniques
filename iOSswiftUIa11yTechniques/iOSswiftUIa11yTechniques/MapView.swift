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
            _regionBad = State(initialValue: MKCoordinateRegion(
                center: storeCoordinates,
                span: MKCoordinateSpan(latitudeDelta:  0.01, longitudeDelta:  0.01)
            ))

        }
    
    @State private var regionBad: MKCoordinateRegion
    
    

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    let maxZoomLevel = 20.0
    let minZoomLevel = 0.001

    
    var body: some View {
        ScrollView {
            VStack {
                Text("Map require single tap alternatives to the pinch gestures used to zoom and the pan gestures used to move the map view.")
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
                ZStack(alignment: .topTrailing) {
                    Map(coordinateRegion: $region)
                    VStack {
                        Spacer()
                        
                        HStack(spacing: 10) {
                            Spacer()
                            VStack {
                                Button(action: moveUp) {
                                    Image(systemName: "arrowtriangle.up.square.fill")
                                        .font(.title)
                                }.accessibilityLabel("Move Up")
                                HStack {
                                    Button(action: moveLeft) {
                                        Image(systemName: "arrowtriangle.left.square.fill")
                                            .font(.title)
                                    }.accessibilityLabel("Move Left")
                                    Button(action: moveRight) {
                                        Image(systemName: "arrowtriangle.right.square.fill")
                                            .font(.title)
                                    }.accessibilityLabel("Move Right")

                                }
                                Button(action: moveDown) {
                                    Image(systemName: "arrowtriangle.down.square.fill")
                                        .font(.title)
                                }.accessibilityLabel("Move Down")

                            }.accessibilityElement(children: .contain)
                            VStack {
                                Button(action: zoomIn) {
                                    Image(systemName: "plus.square.fill")
                                        .font(.title)
                                }.accessibilityLabel("Zoom In")
                                Button(action: zoomOut) {
                                    Image(systemName: "minus.square.fill")
                                        .font(.title)
                                }.accessibilityLabel("Zoom Out")
                            }.accessibilityElement(children: .contain)
                        }
                    }
                }
                .frame(height: 300)
                DisclosureGroup("Details") {
                    Text("The good example uses Plus, Minus, Up, Down, Left, and Right buttons as single tap alternatives to move and zoom the map.")
                }.padding().accessibilityHint("Good Example")
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
                Map(coordinateRegion: $regionBad)
                    .frame(height: 300)
                DisclosureGroup("Details") {
                    Text("The bad example has no single tap alternatives to move or zoom the map.")
                }.padding().accessibilityHint("Bad Example")
            }
            .navigationTitle("Maps")
            .padding()
        }
 
    }
    
    func zoomIn() {
        let newSpan = MKCoordinateSpan(
            latitudeDelta: region.span.latitudeDelta / 1.5,
            longitudeDelta: region.span.longitudeDelta / 1.5
        )
        let newRegion = MKCoordinateRegion(
            center: region.center,
            span: newSpan
        )
        region = newRegion
    }
    
    func zoomOut() {
        let newSpan = MKCoordinateSpan(
            latitudeDelta: region.span.latitudeDelta * 1.5,
            longitudeDelta: region.span.longitudeDelta * 1.5
        )
        let newRegion = MKCoordinateRegion(
            center: region.center,
            span: newSpan
        )
        region = newRegion
    }
    
    func moveLeft() {
        let newCenter = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: region.center.latitude, longitude: region.center.longitude - 0.01),
            span: region.span
        )
        region = newCenter
    }
    
    func moveUp() {
        let newCenter = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: region.center.latitude + 0.01, longitude: region.center.longitude),
            span: region.span
        )
        region = newCenter
    }
    
    func moveDown() {
        let newCenter = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: region.center.latitude - 0.01, longitude: region.center.longitude),
            span: region.span
        )
        region = newCenter
    }
    
    func moveRight() {
        let newCenter = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: region.center.latitude, longitude: region.center.longitude + 0.01),
            span: region.span
        )
        region = newCenter
    }

}
 
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MapView()
        }
    }
}
