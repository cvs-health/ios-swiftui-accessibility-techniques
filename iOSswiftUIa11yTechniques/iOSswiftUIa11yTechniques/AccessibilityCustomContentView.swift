/*
   Copyright 2026 CVS Health and/or one of its affiliates

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

import Accessibility
import SwiftUI

/// Example data model for the Accessibility Custom Content list examples.
private struct Prescription: Identifiable {
    let name: String
    let refills: Int
    let pharmacy: String
    let prescriber: String

    var id: String { name }
}

struct AccessibilityCustomContentView: View {
    private let prescriptions: [Prescription] = [
        Prescription(name: "Atorvastatin 20 mg", refills: 2, pharmacy: "Main Street", prescriber: "Dr. Chen"),
        Prescription(name: "Metformin 500 mg", refills: 0, pharmacy: "Oak Avenue", prescriber: "Dr. Patel")
    ]

    // A reusable key gives every row the same custom content label and a stable `id`.
    private let refillsKey = AccessibilityCustomContentKey("Refills remaining", id: "refills")
    private let pharmacyKey = AccessibilityCustomContentKey("Pharmacy", id: "pharmacy")

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Use `.accessibilityCustomContent` to attach supplementary details to an element without making its accessible name longer. VoiceOver speaks `.default` importance content only when the user asks for it using the More Content rotor, and speaks `.high` importance content immediately with the element. With VoiceOver on rotate 2 fingers on the screen to select the More Content rotor option and then swipe up or down with 1 finger to hear each detail.")
                    .padding(.bottom)
                Text("Good Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                Text("Good Example Data Dense Card")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Atorvastatin 20 mg").font(.headline)
                    Text("Ready for pickup")
                    Text("Refills remaining: 2")
                    Text("Pharmacy: Main Street")
                    Text("Prescriber: Dr. Chen")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary, lineWidth: 1)
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Atorvastatin 20 mg")
                .accessibilityValue("Ready for pickup")
                .accessibilityCustomContent("Refills remaining", "2")
                .accessibilityCustomContent("Pharmacy", "Main Street")
                .accessibilityCustomContent("Prescriber", "Dr. Chen")
                DisclosureGroup("Details") {
                    Text("The good data dense card example keeps the accessible name short with `.accessibilityLabel(\"Atorvastatin 20 mg\")` and `.accessibilityValue(\"Ready for pickup\")`, then attaches the supporting details with three `.accessibilityCustomContent(\"Refills remaining\", \"2\")` style modifiers. VoiceOver announces only the drug name and status when swiping through the list, and users who want the refill count, pharmacy, or prescriber get them on demand from the More Content rotor. Every detail is also visible on screen, so users who are not running VoiceOver are not missing anything.")
                }.padding(.bottom).accessibilityHint("Good Example Data Dense Card")
                Text("Good Example High Importance")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Flight 1042 to Boston").font(.headline)
                    Text("Delayed 45 minutes").foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    Text("Gate B12")
                    Text("Seat 14C")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary, lineWidth: 1)
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Flight 1042 to Boston")
                .accessibilityCustomContent("Status", "Delayed 45 minutes", importance: .high)
                .accessibilityCustomContent("Gate", "B12")
                .accessibilityCustomContent("Seat", "14C")
                DisclosureGroup("Details") {
                    Text("The good high importance example uses `.accessibilityCustomContent(\"Status\", \"Delayed 45 minutes\", importance: .high)` for the one detail users must not miss, so VoiceOver speaks it automatically as part of the element. The gate and seat use the default importance and stay in the More Content rotor. Reserve `.high` for the small number of details that change the meaning of the element, otherwise announcements become as long as the run-on label you were trying to avoid.")
                }.padding(.bottom).accessibilityHint("Good Example High Importance")
                Text("Good Example Reusable Content Key")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack(spacing: 8) {
                    ForEach(prescriptions) { prescription in
                        HStack {
                            Text(prescription.name)
                            Spacer()
                            Text("\(prescription.refills) refills")
                                .foregroundColor(.secondary)
                        }
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary, lineWidth: 1)
                        )
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(prescription.name)
                        .accessibilityCustomContent(refillsKey, "\(prescription.refills)")
                        .accessibilityCustomContent(pharmacyKey, prescription.pharmacy)
                    }
                }
                DisclosureGroup("Details") {
                    Text("The good reusable content key example declares `AccessibilityCustomContentKey(\"Refills remaining\", id: \"refills\")` once and passes it to `.accessibilityCustomContent(refillsKey, \"\\(prescription.refills)\")` for every row. The `id` lets VoiceOver recognize that each row's \"Refills remaining\" detail is the same piece of content, so it stays in a consistent position in the More Content rotor as users move down the list. A key is also the only way to attach a non-literal label, because passing a `String` variable for both the label and the value is unavailable in SwiftUI.")
                }.padding(.bottom).accessibilityHint("Good Example Reusable Content Key")
                Text("Bad Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                Text("Bad Example Run On Label")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Atorvastatin 20 mg").font(.headline)
                    Text("Ready for pickup")
                    Text("Refills remaining: 2")
                    Text("Pharmacy: Main Street")
                    Text("Prescriber: Dr. Chen")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary, lineWidth: 1)
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Atorvastatin 20 mg, Ready for pickup, Refills remaining: 2, Pharmacy: Main Street, Prescriber: Dr. Chen")
                DisclosureGroup("Details") {
                    Text("The bad run on label example crams every detail into one `.accessibilityLabel`. VoiceOver reads the whole string every time focus lands on the card and there is no way to skip ahead or repeat just the refill count. In a list of cards users have to sit through the full announcement for each one. Move the supporting details to `.accessibilityCustomContent` and leave only the name and status in the label and value.")
                }.padding(.bottom).accessibilityHint("Bad Example Run On Label")
                Text("Bad Example Critical Detail at Default Importance")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Metformin 500 mg").font(.headline)
                    Text("Prescription expired").foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    Text("Pharmacy: Oak Avenue")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary, lineWidth: 1)
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Metformin 500 mg")
                .accessibilityCustomContent("Status", "Prescription expired")
                .accessibilityCustomContent("Pharmacy", "Oak Avenue")
                DisclosureGroup("Details") {
                    Text("The bad critical detail example leaves the expired status at the default importance, so VoiceOver announces only \"Metformin 500 mg\" and users hear the expiration only if they think to open the More Content rotor. Status that changes what the element means belongs in `.accessibilityValue`, or in `.accessibilityCustomContent` with `importance: .high` so it is spoken immediately.")
                }.padding(.bottom).accessibilityHint("Bad Example Critical Detail at Default Importance")
                Text("Bad Example Content Only in the Rotor")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Circle()
                        .fill(colorScheme == .dark ? Color(.systemRed) : darkRed)
                        .frame(width: 12, height: 12)
                    Text("Lisinopril 10 mg")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary, lineWidth: 1)
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Lisinopril 10 mg")
                .accessibilityCustomContent("Status", "Action required")
                DisclosureGroup("Details") {
                    Text("The bad rotor only example conveys \"Action required\" with a red dot on screen and with `.accessibilityCustomContent(\"Status\", \"Action required\")` in the More Content rotor, and nowhere else. Sighted users have to know what the color means, which fails WCAG 1.4.1 Use of Color, and custom content is only surfaced by VoiceOver, so Voice Control and Full Keyboard Access users never receive it at all. Custom content supplements information that is already available on screen, it is not a substitute for a visible text label.")
                }.padding(.bottom).accessibilityHint("Bad Example Content Only in the Rotor")
            }
            .padding()
            .navigationTitle("Accessibility Custom Content")
        }
    }
}

#Preview {
    NavigationStack {
        AccessibilityCustomContentView()
    }
}
