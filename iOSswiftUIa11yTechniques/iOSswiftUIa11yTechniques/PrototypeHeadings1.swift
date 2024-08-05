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

struct PrototypeHeadings1: View {

    
    var body: some View {
        ScrollView {
            VStack {
                Text("Save on back-to-school essentials")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h2)
                Text("Don't miss out on savings! Grab all your back-to-school today with same-day delivery or FREE Pickup.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                VStack(alignment:.leading) {
                    Text("Kid's backpacks")
                    Text("Kid's clothing")
                    Text("Books")
                    Text("Lunch bags")
                    Text("Water bottles")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Text("Shop summer essentials")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h2)
                VStack(alignment:.leading) {
                    Text("Sunscreen")
                    Text("Personal care")
                    Text("Skin care")
                    Text("Vitamins")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Text("Deals of the Week")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h2)
                VStack(alignment:.leading) {
                    Text("Outsunny Outdoor lounge chair")
                    Text("Costway 3 PCS Patio Rattan furniture")
                    Text("Kids outdoor inflatable pool")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("Summer essentials")
            .padding()

        }
 
    }
}
 
struct PrototypeHeadings1_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PrototypeHeadings1()
        }
    }
}
