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

struct Page2Prototype: View {

    
    var body: some View {
        ScrollView {
            VStack {
                Text("Essential Ingredients That Every Baker Needs")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h2)
                Text("Build your baking pantry from ten essential ingredients that you use for everyday baking recipes. The following list can be further broken down by category, such as flour – basic flour, whole wheat flour, oatmeal flour. But if you are new to baking you will find our essential building blocks easy to add to your baking pantry. As you gain more baking experience, you'll start to figure out what the next level ingredients are for you.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment:.leading) {
                    Text("• Flour")
                    Text("• Leaveners")
                    Text("• Sugar")
                    Text("• Salt")
                    Text("• Dairy")
                    Text("• Fats")
                    Text("• Eggs")
                    Text("• Flavorings")
                    Text("• Spices")
                    Text("• Add-ins fruits, nuts and/or colorants")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                Text("Essential Ingredients That Every Baker Needs")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h2)
                Text("Build your baking pantry from ten essential ingredients that you use for everyday baking recipes. The following list can be further broken down by category, such as flour – basic flour, whole wheat flour, oatmeal flour. But if you are new to baking you will find our essential building blocks easy to add to your baking pantry. As you gain more baking experience, you'll start to figure out what the next level ingredients are for you.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment:.leading) {
                    Text("""
                    • Flour
                    • Leaveners
                    • Sugar
                    • Salt
                    • Dairy
                    • Fats
                    • Eggs
                    • Flavorings
                    • Spices
                    • Add-ins fruits, nuts and/or colorants
                    """)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                HStack(alignment:.top) {
                    Text("Source:")
                    Link(destination: URL(string: "https://www.allrecipes.com/article/essential-baking-ingredients/")!, label: {
                        Text("https://www.allrecipes.com/article/essential-baking-ingredients/")
                    }).accessibilityRemoveTraits(.isButton)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("Page 2")
            .padding()

        }
 
    }
}
 
struct Page2Prototype_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            Page2Prototype()
        }
    }
}
