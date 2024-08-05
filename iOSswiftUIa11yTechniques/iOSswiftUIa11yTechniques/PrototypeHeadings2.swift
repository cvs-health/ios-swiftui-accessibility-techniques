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

struct PrototypeHeadings2: View {

    
    var body: some View {
        ScrollView {
            VStack {
                Text("Summer Clearance")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Shop this week’s best buys and steepest savings")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                VStack(alignment:.leading) {
                    Text("Outdoor living")
                    Text("Toys")
                    Text("Sports")
                    Text("Clear out deals")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Text("Big Deals")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Don’t miss these Extra Big Deals! Deals so extra, they can’t be missed. But hurry, they’re not here for long!")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                VStack(alignment:.leading) {
                    Text("Hawaiian Tropic sunscreen cream")
                    Text("Sport Clear Sunscreen Spray")
                    Text("Soothing Aloe After Sun Gel")
                    Text("Insect repellent spray for kids")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Text("Deals on Essential electronics")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack(alignment:.leading) {
                    Text("QuickSnap Waterproof Camera")
                    Text("Reserve Power Bank, 10000mAh")
                    Text("Batteries")
                    Text("Portable Speaker")
                    Text("Bluetooth Speaker")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("Summer Deals")
            .padding()

        }
 
    }
}
 
struct PrototypeHeadings2_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PrototypeHeadings2()
        }
    }
}
