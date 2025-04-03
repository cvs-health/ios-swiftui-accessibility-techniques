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

/// Example data model for Rotor examples.
private struct Model {
    struct Value: Identifiable {
        var label: String
        var icon: String
        var isRotorVeggie: Bool = false
        var isRotorFruit: Bool = false

        var id: String {
            label
        }
    }

    var values: [Value] = [
        Value(label: "Apple", icon: "🍎", isRotorFruit: true),
        Value(label: "Orange", icon: "🍊", isRotorFruit: true),
        Value(label: "Broccoli", icon: "🥦", isRotorVeggie: true),
        Value(label: "Banana", icon: "🍌", isRotorFruit: true),
        Value(label: "Lettuce", icon: "🥬", isRotorVeggie: true),
        Value(label: "Pear", icon: "🍐", isRotorFruit: true),
        Value(label: "Green Beans", icon: "🫛", isRotorVeggie: true)
    ]
}

struct RotorView: View {
    private var model = Model()

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Accessibility Rotor is used to quickly navigate to specific elements or ranges of text on the page. With VoiceOver on rotate 2 fingers on the screen to select the rotor option and then swipe up or down with 1 finger to move between those elements. Use `.accessibilityRotor()` with the rotor name and element entries it will navigate to create a custom rotor for VoiceOver users.")
                    .padding([.bottom])
                Text("Good Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                LazyVStack(alignment:.leading) {
                    Text("Fruits & Veggies").font(.title).bold().accessibilityAddTraits(.isHeader).accessibilityHeading(.h1)
                    ForEach(model.values) { value in
                        HStack {
                            Text(value.label)
                            Text(value.icon)
                        }
                    }
                }
                .accessibilityRotor("Vegetables", entries: model.values.filter(\.isRotorVeggie), entryLabel: \.label)
                .accessibilityRotor("Fruits", entries: model.values.filter(\.isRotorFruit), entryLabel: \.label)
                DisclosureGroup("Details") {
                    Text("The good rotor example uses `.accessibilityRotor(\"Vegetables\", entries: model.values.filter(\\.isRotorVeggie), entryLabel: \\.label)` and `.accessibilityRotor(\"Fruits\", entries: model.values.filter(\\.isRotorFruit), entryLabel: \\.label)` to create two rotors that allow VoiceOver users to quickly navigate between Vegetables or Fruits.")
                }
            }
            .padding()
            .navigationTitle("Accessibility Rotor")

        }
 
    }
}
 
struct RotorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RotorView()
        }
    }
}
