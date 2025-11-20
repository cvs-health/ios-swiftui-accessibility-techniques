/*
   Copyright 2025 CVS Health and/or one of its affiliates

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

enum Fruit: String, CaseIterable, Identifiable {
    case apple = "Apple"
    case banana = "Banana"
    case cherry = "Cherry"
    case grape = "Grape"

    var id: Self { self }
}

struct PickersWatch: View {
    
    let darkBlue = Color(red: 26/255, green: 115/255, blue: 206/255)
    @State private var selectedFruit: Fruit = .apple
    @State private var selectedFruitDefault: Fruit = .banana
    @State private var selectedFruitGood: Fruit = .apple
    @State private var selectedFruitBad: Fruit = .apple
    @State private var selectedFruitDefaultBad: Fruit = .banana
    @AccessibilityFocusState private var isTriggerFocused: Bool
    @AccessibilityFocusState private var isFruitFocused: Bool

    var body: some View {
        ScrollView {
            Text("Pickers with the default or `.pickerStyle(.navigationLink)` need `Picker(\"Label\")` text which is spoken to VoiceOver as the accessibility label. Use `AccessibilityFocusState` to send VoiceOver focus back to `.navigationLink` style pickers when the value has been changed.")
            Text("Good Examples")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h2)
                .foregroundColor(.green)
            Divider()
                .frame(height: 2.0, alignment: .leading)
                .background(.green)
                .padding(.bottom)
            Text("`Picker(\"Label\")`")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
            Picker("Fruit", selection: $selectedFruitDefault) {
                ForEach(Fruit.allCases) { fruit in
                    Text(fruit.rawValue).tag(fruit)
                }
            }.frame(maxWidth: .infinity, minHeight:66, alignment: .leading)
            NavigationLink(destination: DetailPickersGood()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("`Picker(\"Label\")`")
                .buttonStyle(.plain)
                .padding(.bottom)
            Text("Good `.pickerStyle(.navigationLink)`")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
            Picker("Fruit", selection: $selectedFruitGood) {
                ForEach(Fruit.allCases) { fruit in
                    Text(fruit.rawValue).tag(fruit)
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
                .pickerStyle(.navigationLink)
                .onChange(of: selectedFruitGood) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isTriggerFocused = true
                    }
                }
                .accessibilityFocused($isTriggerFocused)
            NavigationLink(destination: DetailPickersGood2()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("Good `.pickerStyle(.navigationLink)`")
                .buttonStyle(.plain)
                .padding(.bottom)
            Text("Bad Examples")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h2)
                .foregroundColor(.red)
            Divider()
                .frame(height: 2.0, alignment: .leading)
                .background(.red)
                .padding(.bottom)
            Text("No `\"Label\"`")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
            Picker("", selection: $selectedFruitDefaultBad) {
                ForEach(Fruit.allCases) { fruit in
                    Text(fruit.rawValue).tag(fruit)
                }
            }.frame(maxWidth: .infinity, minHeight:66, alignment: .leading)
            NavigationLink(destination: DetailPickersBad()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("No `\"Label\"`")
                .buttonStyle(.plain)
                .padding(.bottom)
            Text("Bad `.pickerStyle(.navigationLink)`")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
            Picker("", selection: $selectedFruitBad) {
                ForEach(Fruit.allCases) { fruit in
                    Text(fruit.rawValue).tag(fruit)
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
                .pickerStyle(.navigationLink)
            NavigationLink(destination: DetailPickersBad2()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("Bad `.pickerStyle(.navigationLink)`")
                .buttonStyle(.plain)

        }
    }
}

struct DetailPickersGood: View {
    var body: some View {
        ScrollView {
            Text("The default style good example uses `Picker(\"Fruit\")` label text which is spoken as the accessibility label to VoiceOver.")
        }
            .navigationTitle("`Picker(\"Label\")`")
    }
}
struct DetailPickersGood2: View {
    var body: some View {
        ScrollView {
            Text("The `.pickerStyle(.navigationLink)` good example uses `Picker(\"Fruit\")` label text which is spoken as the accessibility label to VoiceOver. `AccessibilityFocusState` is used to send VoiceOver focus back to the picker when the value has been changed. This is a platform defect where VoiceOver does not always support `AccessibilityFocusState` to return focus back to the trigger button on watchOS, i.e., not after the subsequent times the menu is closed. `DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)` has been used to add a half-second delay before sending focus back to the trigger button to workaround the bug.")

        }
            .navigationTitle("Good `.pickerStyle(.navigationLink)`")
    }
}
struct DetailPickersBad: View {
    var body: some View {
        ScrollView {
            Text("The default style bad example uses empty `Picker(\"\")` label text so there is no accessibility label spoken to VoiceOver and no visible label text.")
        }
            .navigationTitle("No `\"Label\"`")
    }
}
struct DetailPickersBad2: View {
    var body: some View {
        ScrollView {
            Text("The `.pickerStyle(.navigationLink)` bad example has no visible picker label and `AccessibilityFocusState` is not used to send VoiceOver focus back to the picker when the value has been changed.")
        }
            .navigationTitle("Bad `.pickerStyle(.navigationLink)`")
    }
}


#Preview {
    NavigationStack {
        PickersWatch()
    }
}
