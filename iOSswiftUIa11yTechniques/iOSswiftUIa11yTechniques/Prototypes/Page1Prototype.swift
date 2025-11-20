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

struct Page1Prototype: View {

    
    var body: some View {
        ScrollView {
            VStack {
                Text("Best Countries to Live in 2024")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h2)
                Text("Best can be subjective. To find inspiration, we looked at the latest World Happiness Report which ranks countries based on what residents themselves feel about living there. Analyzing the top 10, there are several nations that stood out thanks to the excellent living conditions, economic stability, and safe and welcoming environment. Below are the rankings from the World Happiness Report 2024, ranked according to the self-assessed life evaluations of individuals living there between 2021 and 2023.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading) {
                    Text("1. Finland")
                    Text("2. Denmark")
                    Text("3. Iceland")
                    Text("4. Sweden")
                    Text("5. Israel")
                    Text("6. Netherlands")
                    Text("7. Norway")
                    Text("8. Luxembourg")
                    Text("9. Switzerland")
                    Text("10. Australia")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                Text("Best Countries to Live in 2024")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h2)
                Text("Best can be subjective. To find inspiration, we looked at the latest World Happiness Report which ranks countries based on what residents themselves feel about living there. Analyzing the top 10, there are several nations that stood out thanks to the excellent living conditions, economic stability, and safe and welcoming environment. Below are the rankings from the World Happiness Report 2024, ranked according to the self-assessed life evaluations of individuals living there between 2021 and 2023.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading) {
                    Text("""
                        1. Finland
                        2. Denmark
                        3. Iceland
                        4. Sweden
                        5. Israel
                        6. Netherlands
                        7. Norway
                        8. Luxembourg
                        9. Switzerland
                        10. Australia
                    """)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                HStack(alignment:.top) {
                    Text("Source:")
                    Link(destination: URL(string: "https://www.expatriatehealthcare.com/the-best-countries-to-live-in-2024/")!, label: {
                        Text("https://www.expatriatehealthcare.com/the-best-countries-to-live-in-2024/")
                    }).accessibilityRemoveTraits(.isButton)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("Page 1")
            .padding()

        }
 
    }
}
 
struct Page1Prototype_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            Page1Prototype()
        }
    }
}
