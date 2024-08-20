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

    func generateRandomPrice() -> Double {
        let minPrice = 19.99
        let maxPrice = 49.99
        return Double.random(in: minPrice...maxPrice)
    }

    
    var body: some View {
        ScrollView {
            VStack {
                Text("Summer Deals")
                    .font(.title).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Discover summer deals available right now. If you are looking to save money, shop on our app.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Summer Clearance")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Shop this week’s best buys and steepest savings")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                VStack(alignment:.leading) {
                    Button(action: {}) {
                        HStack {
                            Text("Outdoor living")
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Text("Toys")
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Text("Sports")
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Text("Clear out deals")
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
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
                    Button(action: {}) {
                            HStack {
                                Text("Hawaiian Tropic sunscreen cream")
                                Spacer()
                                Text("$\(generateRandomPrice(), specifier: "%.2f")")
                            }
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        Button(action: {}) {
                            HStack {
                                Text("Sport Clear Sunscreen Spray")
                                Spacer()
                                Text("$\(generateRandomPrice(), specifier: "%.2f")")
                            }
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        Button(action: {}) {
                            HStack {
                                Text("Soothing Aloe After Sun Gel")
                                Spacer()
                                Text("$\(generateRandomPrice(), specifier: "%.2f")")
                            }
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        Button(action: {}) {
                            HStack {
                                Text("Insect repellent spray for kids")
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
                Text("Deals on Essential electronics")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack(alignment:.leading) {
                    Button(action: {}) {
                            HStack {
                                Text("QuickSnap Waterproof Camera")
                                Spacer()
                                Text("$\(generateRandomPrice(), specifier: "%.2f")")
                            }
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        Button(action: {}) {
                            HStack {
                                Text("Reserve Power Bank, 10000mAh")
                                Spacer()
                                Text("$\(generateRandomPrice(), specifier: "%.2f")")
                            }
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        Button(action: {}) {
                            HStack {
                                Text("Batteries")
                                Spacer()
                                Text("$\(generateRandomPrice(), specifier: "%.2f")")
                            }
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        Button(action: {}) {
                            HStack {
                                Text("Portable Speaker")
                                Spacer()
                                Text("$\(generateRandomPrice(), specifier: "%.2f")")
                            }
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        Button(action: {}) {
                            HStack {
                                Text("Bluetooth Speaker")
                                Spacer()
                                Text("$\(generateRandomPrice(), specifier: "%.2f")")
                            }
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }                }
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
