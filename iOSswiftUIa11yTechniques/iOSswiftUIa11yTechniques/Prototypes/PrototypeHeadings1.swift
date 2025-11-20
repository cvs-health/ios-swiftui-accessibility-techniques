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
    
    func generateRandomPrice() -> Double {
        let minPrice = 19.99
        let maxPrice = 49.99
        return Double.random(in: minPrice...maxPrice)
    }


    var body: some View {
        ScrollView {
            VStack {
                Text("Find the perfect destination to shop for your summer essentials. From back-to-school items to summer essentials, we have got you covered.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Text("Save on back-to-school essentials")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h2)
                Spacer()
                Text("Don't miss out on savings! Grab all your back-to-school today with same-day delivery or FREE Pickup.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                VStack(alignment: .leading) {
                    Button(action: {}) {
                        HStack {
                            Text("Kid's backpacks")
                            Spacer()
                            Text("$\(generateRandomPrice(), specifier: "%.2f")")
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    Button(action: {}) {
                        HStack {
                            Text("Kid's clothing")
                            Spacer()
                            Text("$\(generateRandomPrice(), specifier: "%.2f")")
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    Button(action: {}) {
                        HStack {
                            Text("Books")
                            Spacer()
                            Text("$\(generateRandomPrice(), specifier: "%.2f")")
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    Button(action: {}) {
                        HStack {
                            Text("Lunch bags")
                            Spacer()
                            Text("$\(generateRandomPrice(), specifier: "%.2f")")
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    Button(action: {}) {
                        HStack {
                            Text("Water bottles")
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
                Text("Shop summer essentials")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h2)
                VStack(alignment: .leading) {
                    Button(action: {}) {
                        HStack {
                            Text("Sunscreen")
                            Spacer()
                            Text("$\(generateRandomPrice(), specifier: "%.2f")")
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    Button(action: {}) {
                        HStack {
                            Text("Personal care")
                            Spacer()
                            Text("$\(generateRandomPrice(), specifier: "%.2f")")
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    Button(action: {}) {
                        HStack {
                            Text("Skin care")
                            Spacer()
                            Text("$\(generateRandomPrice(), specifier: "%.2f")")
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    Button(action: {}) {
                        HStack {
                            Text("Vitamins")
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
                Text("Deals of the Week")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityHeading(.h2)
                VStack(alignment: .leading) {
                    Button(action: {}) {
                        HStack {
                            Text("Outsunny Outdoor lounge chair")
                            Spacer()
                            Text("$\(generateRandomPrice(), specifier: "%.2f")")
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    Button(action: {}) {
                        HStack {
                            Text("Costway 3 PCS Patio Rattan furniture")
                            Spacer()
                            Text("$\(generateRandomPrice(), specifier: "%.2f")")
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    Button(action: {}) {
                        HStack {
                            Text("Kids outdoor inflatable pool")
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
