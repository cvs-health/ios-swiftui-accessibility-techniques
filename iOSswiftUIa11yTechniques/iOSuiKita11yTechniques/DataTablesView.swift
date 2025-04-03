/*
   Copyright 2023 CVS Health and/or one of its affiliates

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
 
struct DataTablesView: View {
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    private var darkOrange = Color(red: 203 / 255, green: 77 / 255, blue: 0 / 255)
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var body: some View {
        ScrollView {
            VStack {
                Text("Data table cells need to have their row and column header text spoken to VoiceOver users. Set the `.accessibilityHint`, `.accessibilityValue`, or `.accessibilityLabel` for each cell to include its row and column header text. The data table should also have a heading set as the `.accessibilityLabel` for the group. Use `.accessibilityElement(children: .contain)` and `.accessibilityLabel(\"Table Name\")` to give the table a group label that is spoken to VoiceOver users when they first focus on a cell in the table. Native `Table()` elements are designed to work only on iPad or macOS and have a platform defect where their row headers are not spoken to VoiceOver when moving between rows.")
                    .padding(.bottom)
                Text("Good Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                Text("Good Example using `.accessibilityHint`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Generic Price List").font(.headline).accessibilityAddTraits(.isHeader)
                VStack {
                    if (dynamicTypeSize <= DynamicTypeSize.xxxLarge) {
                        GeometryReader { geometry in
                            HStack {
                                Text("Name")
                                    .frame(width: geometry.size.width / 2)
                                Text("30 Day")
                                    .frame(width: geometry.size.width / 4)
                                Text("90 Day")
                                    .frame(width: geometry.size.width / 4)
                            }.fontWeight(.bold).font(.footnote)
                        }
                    }
                    ForEach(items) { item in
                        VStack(alignment: .leading) {
                            if (dynamicTypeSize <= DynamicTypeSize.xxxLarge) {
                                GeometryReader { geometry in
                                    HStack {
                                        Text(item.name)
                                            .frame(width: geometry.size.width / 2)
                                        Text("$\(item.oneMonth)")
                                            .frame(width: geometry.size.width / 4)
                                            .accessibilityHint("30 Day, \(item.name)")
                                        Text("$\(item.threeMonth)")
                                            .frame(width: geometry.size.width / 4)
                                            .accessibilityHint("90 Day, \(item.name)")
                                    }.font(.footnote)
                                }
                            } else {
                                Text(item.name).font(.headline).accessibilityAddTraits(.isHeader)
                                Text("30 Day: $\(item.oneMonth)")
                                Text("90 Day: $\(item.threeMonth)")
                            }
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Generic Price List")
                DisclosureGroup("Details") {
                    Text("The first good data table example uses an `.accessibilityHint` for each price cell that includes its row and column header text. VoiceOver speaks the price and then speaks the column and row header text as the hint. Additionally `.accessibilityElement(children: .contain)` and `.accessibilityLabel(\"Generic Price List\")` are used to give the table a group label that is spoken to VoiceOver users when they first focus on a cell in the table. The good table examples present the data as text with headings instead of as a data table if AX dynamic type accessibility text sizes are enabled.")
                }.padding(.bottom).accessibilityHint("Good Example using .accessibilityHint")
                Text("Good Example using `.accessibilityLabel`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Generic Price List").font(.headline).accessibilityAddTraits(.isHeader)
                VStack {
                    if (dynamicTypeSize <= DynamicTypeSize.xxxLarge) {
                        GeometryReader { geometry in
                            HStack {
                                Text("Name")
                                    .frame(width: geometry.size.width / 2)
                                Text("30 Day")
                                    .frame(width: geometry.size.width / 4)
                                Text("90 Day")
                                    .frame(width: geometry.size.width / 4)
                            }.fontWeight(.bold).font(.footnote)
                        }
                    }
                    ForEach(items) { item in
                        VStack(alignment: .leading) {
                            if (dynamicTypeSize <= DynamicTypeSize.xxxLarge) {
                                GeometryReader { geometry in
                                    HStack {
                                        Text(item.name)
                                            .frame(width: geometry.size.width / 2)
                                        Text("$\(item.oneMonth)")
                                            .frame(width: geometry.size.width / 4)
                                            .accessibilityLabel("30 Day, \(item.name), $\(item.oneMonth)")
                                        Text("$\(item.threeMonth)")
                                            .frame(width: geometry.size.width / 4)
                                            .accessibilityLabel("90 Day, \(item.name), $\(item.threeMonth)")
                                    }.font(.footnote)
                                }
                            } else {
                                Text(item.name).font(.headline).accessibilityAddTraits(.isHeader)
                                Text("30 Day: $\(item.oneMonth)")
                                Text("90 Day: $\(item.threeMonth)")
                            }
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Generic Price List")
                DisclosureGroup("Details") {
                    Text("The second good data table example uses an `.accessibilityLabel` for each price cell that includes its row and column header text. VoiceOver speaks the column and row header text then speaks the price. Additionally `.accessibilityElement(children: .contain)` and `.accessibilityLabel(\"Generic Price List\")` are used to give the table a group label that is spoken to VoiceOver users when they first focus on a cell in the table. The good table examples present the data as text with headings instead of as a data table if AX dynamic type accessibility text sizes are enabled.")
                }.padding(.bottom).accessibilityHint("Good Example using .accessibilityLabel")
                Text("Good Example using `.accessibilityValue`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Generic Price List").font(.headline).accessibilityAddTraits(.isHeader)
                VStack {
                    if (dynamicTypeSize <= DynamicTypeSize.xxxLarge) {
                        GeometryReader { geometry in
                            HStack {
                                Text("Name")
                                    .frame(width: geometry.size.width / 2)
                                Text("30 Day")
                                    .frame(width: geometry.size.width / 4)
                                Text("90 Day")
                                    .frame(width: geometry.size.width / 4)
                            }.fontWeight(.bold).font(.footnote)
                        }
                    }
                    ForEach(items) { item in
                        VStack(alignment: .leading) {
                            if (dynamicTypeSize <= DynamicTypeSize.xxxLarge) {
                                GeometryReader { geometry in
                                    HStack {
                                        Text(item.name)
                                            .frame(width: geometry.size.width / 2)
                                        Text("$\(item.oneMonth)")
                                            .frame(width: geometry.size.width / 4)
                                            .accessibilityValue("30 Day, \(item.name)")
                                        Text("$\(item.threeMonth)")
                                            .frame(width: geometry.size.width / 4)
                                            .accessibilityValue("90 Day, \(item.name)")
                                    }.font(.footnote)
                                }
                            } else {
                                Text(item.name).font(.headline).accessibilityAddTraits(.isHeader)
                                Text("30 Day: $\(item.oneMonth)")
                                Text("90 Day: $\(item.threeMonth)")
                            }
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Generic Price List")
                DisclosureGroup("Details") {
                    Text("The third good data table example uses an `.accessibilityValue` for each price cell that includes its row and column header text. VoiceOver speaks the price and then speaks the column and row header text as the value. Additionally `.accessibilityElement(children: .contain)` and `.accessibilityLabel(\"Generic Price List\")` are used to give the table a group label that is spoken to VoiceOver users when they first focus on a cell in the table. The good table examples present the data as text with headings instead of as a data table if AX dynamic type accessibility text sizes are enabled.")
                }.padding(.bottom).accessibilityHint("Good Example using .accessibilityValue")
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
                VStack {
                    GeometryReader { geometry in
                        HStack {
                            Text("Name")
                                .frame(width: geometry.size.width / 2)
                            Text("30 Day")
                                .frame(width: geometry.size.width / 4)
                            Text("90 Day")
                                .frame(width: geometry.size.width / 4)
                        }.fontWeight(.bold).font(.footnote)
                    }
                    ForEach(items) { item in
                        VStack(alignment: .leading) {
                            GeometryReader { geometry in
                                HStack {
                                    Text(item.name)
                                        .frame(width: geometry.size.width / 2)
                                    Text("$\(item.oneMonth)")
                                        .frame(width: geometry.size.width / 4)
                                    Text("$\(item.threeMonth)")
                                        .frame(width: geometry.size.width / 4)
                                }.font(.footnote)
                            }
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                DisclosureGroup("Details") {
                    Text("The bad data table example has no `.accessibilityHint`, `.accessibilityValue`, or `.accessibilityLabel` for each price cell that includes its row and column header text. VoiceOver users only hear the price cell text and don't hear the row or column header text. There is no heading for the table and no group label spoken to VoiceOver users when they first focus on a cell in the table. The bad data table example is unreadable when AX dynamic type accessibility text sizes are enabled because the text grows larger than the cells of the data table.")
                }.accessibilityHint("Bad Example")
                Text("Platform Defect Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.orange) : darkOrange)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.orange) : darkOrange)
                    .padding(.bottom)
                Text("Platform Defect Example `Table()` Speaks Column Headers but Not Row Headers")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                NavigationLink(destination: TableView()) {
                    Text("Table View Example - iPad Only")
                }.padding()
                DisclosureGroup("Details") {
                    VStack {
                        Text("The platform defect example uses a native `Table()` element which does speak its column header text to VoiceOver when moving between columns but does not speak its row header text when moving between rows. `Table()` elements support iPad or macOS only. On iPhone only the first column of data cells in a `Table()` will display.")
                    }
                }.padding(.bottom).accessibilityHint("Platform Defect Example `Table()` Speaks Column Headers but Not Row Headers")

            }
            .navigationTitle("Data Tables")
            .padding()
        }
 
    }
}
 
struct DataTablesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DataTablesView()
        }
    }
}


struct Item: Identifiable {
   let id = UUID()
   let name: String
   let oneMonth: Int
   let threeMonth: Int
}

let items = [
    Item(name: "AMLODIPINE 2.5mg", oneMonth: 20, threeMonth: 40),
    Item(name: "ANASTROZOLE 1mg", oneMonth: 47, threeMonth: 90),
    Item(name: "BENAZEPRIL 5mg", oneMonth: 37, threeMonth: 70),
    Item(name: "CLONIDINE 0.1mg", oneMonth: 15, threeMonth: 30),
    Item(name: "EZETIMIBE 10mg", oneMonth: 37, threeMonth: 70),
    Item(name: "FOLIC ACID 1mg", oneMonth: 20, threeMonth: 37),
    Item(name: "LOVASTATIN 10mg", oneMonth: 37, threeMonth: 70),
   // Add more items here...
]
