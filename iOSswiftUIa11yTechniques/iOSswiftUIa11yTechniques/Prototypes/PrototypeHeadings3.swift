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
    

    func generateRandomPrice() -> Double {
        let minPrice = 19.99
        let maxPrice = 49.99
        return Double.random(in: minPrice...maxPrice)
    }

    
    var body: some View {
        ScrollView {
            VStack {
                Text("Hottest Deals")
                    .font(.title).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h1)
                Text("Get the best deals on all our products. Up to 70% off on some selected items.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Browse by department")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h2)
                Spacer()
                Text("Household")
                    .font(.title3).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h3)
                Spacer()
                Text("Furnitures")
                    .font(.title3).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h3)
                Spacer()
                Text("Clothing, shoes, and accessories")
                    .font(.title3).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h3)
                Spacer()
                Text("Low prices every day on clothes, accessories & shoes. Find the latest men's, women's, kids', and baby fashion, and don't forget our huge selection of accessories.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Text("Men's clothing and shoes")
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h4)
                Spacer()
                Button(action: {}) {
                    HStack {
                        Text("Men’s outdoor performance pant")
                        Spacer()
                        Text("$\(generateRandomPrice(), specifier: "%.2f")")
                    }
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Button(action: {}) {
                    HStack {
                        Text("Short sleeve T-shirt")
                        Spacer()
                        Text("$\(generateRandomPrice(), specifier: "%.2f")")
                    }
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Button(action: {}) {
                    HStack {
                        Text("Men’s cool-zone crew-neck shirt")
                        Spacer()
                        Text("$\(generateRandomPrice(), specifier: "%.2f")")
                    }
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
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
                VStack(alignment: .leading) {
                    Button(action: {}) {
                       HStack {
                           Text("Puff sleeve eyelet dress")
                           Spacer()
                           Text("$\(generateRandomPrice(), specifier: "%.2f")")
                       }
                       .padding()
                       .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                       .clipShape(RoundedRectangle(cornerRadius: 10))
                   }
                   
                   Button(action: {}) {
                       HStack {
                           Text("Tiered Maxi dress")
                           Spacer()
                           Text("$\(generateRandomPrice(), specifier: "%.2f")")
                       }
                       .padding()
                       .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                       .clipShape(RoundedRectangle(cornerRadius: 10))
                   }
                   
                   Button(action: {}) {
                       HStack {
                           Text("Summer long dress for women")
                           Spacer()
                           Text("$\(generateRandomPrice(), specifier: "%.2f")")
                       }
                       .padding()
                       .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                       .clipShape(RoundedRectangle(cornerRadius: 10))
                   }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Text("Tops")
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h5)
                Spacer()
                VStack(alignment: .leading) {
                    Button(action: {}) {
                        HStack {
                            Text("Flannel shirt")
                            Spacer()
                            Text("$\(generateRandomPrice(), specifier: "%.2f")")
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Text("Twist Front T-shirt")
                            Spacer()
                            Text("$\(generateRandomPrice(), specifier: "%.2f")")
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Text("Stretch Poplin shirt")
                            Spacer()
                            Text("$\(generateRandomPrice(), specifier: "%.2f")")
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Text("Women’s full-zip hoodies")
                            Spacer()
                            Text("$\(generateRandomPrice(), specifier: "%.2f")")
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Text("Bottoms")
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h5)
                Spacer()
                VStack(alignment: .leading) {
                    Button(action: {}) {
                        HStack {
                            Text("Cargo jogger")
                            Spacer()
                            Text("$\(generateRandomPrice(), specifier: "%.2f")")
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Text("Midi Denim skirt")
                            Spacer()
                            Text("$\(generateRandomPrice(), specifier: "%.2f")")
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Text("Linen short")
                            Spacer()
                            Text("$\(generateRandomPrice(), specifier: "%.2f")")
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Text("Cropped legging")
                            Spacer()
                            Text("$\(generateRandomPrice(), specifier: "%.2f")")
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Text("Kid's clothing and shoes")
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h4)
                Spacer()
                VStack(alignment: .leading) {
                    Button(action: {}) {
                        HStack {
                            Text("Boys’ pajama 2-piece set")
                            Spacer()
                            Text("$\(generateRandomPrice(), specifier: "%.2f")")
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Text("Boys’ graphic T-shirt, X-XL")
                            Spacer()
                            Text("$\(generateRandomPrice(), specifier: "%.2f")")
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Text("Girls’ swimming wear")
                            Spacer()
                            Text("$\(generateRandomPrice(), specifier: "%.2f")")
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Text("Girls’ skater dress")
                            Spacer()
                            Text("$\(generateRandomPrice(), specifier: "%.2f")")
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Text("Toddler sleeper, size 0-24 months")
                            Spacer()
                            Text("$\(generateRandomPrice(), specifier: "%.2f")")
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
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
