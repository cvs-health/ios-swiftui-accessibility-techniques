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

struct PrototypeHeadings3: View {

    
    var body: some View {
        ScrollView {
            VStack {
                Text("Browse by department")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h2)
                Spacer()
                Text("Clothing, shoes, and accessories")
                    .font(.title3).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h3)
                Spacer()
                Text("Men's clothing and shoes")
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h4)
                Spacer()
                VStack(alignment:.leading) {
                    Text("Men’s outdoor performance pant")
                    Text("Short sleeve T-shirt")
                    Text("Men’s cool-zone crew-neck shirt")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Text("Women's clothing and shoes")
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h4)
                Spacer()
                Text("Dresses")
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h5)
                Spacer()
                VStack(alignment:.leading) {
                    Text("Puff sleeve eyelet dress")
                    Text("Tiered Maxi dress")
                    Text("Summer long dress for women")
                    Text("Vitamins")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Text("Tops")
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h5)
                Spacer()
                VStack(alignment:.leading) {
                    Text("Flannel shirt")
                    Text("Twist Front T-shirt")
                    Text("Stretch Poplin shirt")
                    Text("Women’s full-zip hoodies")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Text("Bottoms")
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h5)
                Spacer()
                VStack(alignment:.leading) {
                    Text("Cargo jogger")
                    Text("Midi Denim skirt")
                    Text("Linen short")
                    Text("Cropped legging")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Text("Kid's clothing and shoes")
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h4)
                Spacer()
                VStack(alignment:.leading) {
                    Text("Men’s outdoor performance pant")
                    Text("Short sleeve T-shirt")
                    Text("Men’s cool-zone crew-neck shirt")
                }
                .frame(maxWidth: .infinity, alignment: .leading)

            }
            .navigationTitle("Hottest Deals")
            .padding()

        }
 
    }
}
 
struct PrototypeHeadings3_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PrototypeHeadings3()
        }
    }
}
