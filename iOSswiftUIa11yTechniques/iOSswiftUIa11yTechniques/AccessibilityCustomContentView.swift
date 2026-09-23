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
        Prescription(name: "Metformin 500 mg", refills: 1, pharmacy: "Oak Avenue", prescriber: "Dr. Patel")
    ]

    // Reusable keys give every row the same custom content label and a stable `id`.
    private let pharmacyKey = AccessibilityCustomContentKey("Pharmacy", id: "pharmacy")
    private let prescriberKey = AccessibilityCustomContentKey("Prescriber", id: "prescriber")

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Use `.accessibilityCustomContent` to expose supplementary details that are not shown as text on screen, without adding them to the accessible name. VoiceOver speaks `.default` importance content only when the user asks for it using the More Content rotor, and speaks `.high` importance content immediately. With VoiceOver on rotate 2 fingers on the screen to select the More Content rotor option and then swipe up or down with 1 finger to hear each detail.")
                    .padding(.bottom)
                Text("Custom content never replaces the accessible name. Every piece of text visible on screen must still be in the name, so keep `.accessibilityElement(children: .combine)` or a label that contains the visible text, otherwise VoiceOver stops speaking what is on screen and Voice Control users cannot say what they see.")
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
                Text("Good Example Supplementary Details")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button(action: {}) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Atorvastatin 20 mg").font(.headline)
                        Text("Ready for pickup")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary, lineWidth: 1)
                )
                .accessibilityCustomContent("Refills remaining", "2")
                .accessibilityCustomContent("Prescriber", "Dr. Chen")
                DisclosureGroup("Details") {
                    Text("The good supplementary details example lets the Button build its own accessible name from its visible text, so VoiceOver speaks \"Atorvastatin 20 mg, Ready for pickup\" on focus and Voice Control users can say either phrase to activate the card. The refill count and prescriber are not printed on the compact card, they live on the detail screen, so `.accessibilityCustomContent(\"Refills remaining\", \"2\")` gives VoiceOver users a shortcut to them without taking anything out of the name.")
                }.padding(.bottom).accessibilityHint("Good Example Supplementary Details")
                Text("Good Example High Importance")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                        Circle()
                            .trim(from: 0, to: 0.72)
                            .stroke(colorScheme == .dark ? Color(.systemGreen) : darkGreen, lineWidth: 10)
                            .rotationEffect(.degrees(-90))
                        Text("72%").bold()
                    }
                    .frame(width: 100, height: 100)
                    Text("Daily steps")
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .combine)
                .accessibilityCustomContent("Compared to yesterday", "1,400 steps ahead", importance: .high)
                DisclosureGroup("Details") {
                    Text("The good high importance example uses `.accessibilityElement(children: .combine)` so the visible \"72%\" and \"Daily steps\" text stays in the accessible name, then adds `.accessibilityCustomContent(\"Compared to yesterday\", \"1,400 steps ahead\", importance: .high)` for a comparison that is not drawn anywhere on screen. VoiceOver speaks high importance content immediately, so reserve it for the rare supplementary detail worth interrupting for. Marking everything `.high` recreates the long announcement custom content is meant to avoid.")
                }.padding(.bottom).accessibilityHint("Good Example High Importance")
                Text("Good Example Reusable Content Key")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack(spacing: 8) {
                    ForEach(prescriptions) { prescription in
                        Button(action: {}) {
                            HStack {
                                Text(prescription.name)
                                Spacer()
                                Text("\(prescription.refills) refills")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary, lineWidth: 1)
                        )
                        .accessibilityCustomContent(pharmacyKey, prescription.pharmacy)
                        .accessibilityCustomContent(prescriberKey, prescription.prescriber)
                    }
                }
                DisclosureGroup("Details") {
                    Text("The good reusable content key example declares `AccessibilityCustomContentKey(\"Pharmacy\", id: \"pharmacy\")` once and passes it to `.accessibilityCustomContent(pharmacyKey, prescription.pharmacy)` for every row. The `id` lets VoiceOver recognize that each row's Pharmacy detail is the same piece of content, so it keeps a consistent position in the More Content rotor as users move down the list. A key is also the only way to attach a label that is not a string literal, because the overload taking a `String` variable for both the label and the value is unavailable in SwiftUI. Each row's visible name and refill count are still spoken on focus because the Button builds the name from its own visible text.")
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
                Text("Bad Example Visible Text Moved Into Custom Content")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button(action: {}) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Atorvastatin 20 mg").font(.headline)
                        Text("Ready for pickup")
                        Text("Refills remaining: 2")
                        Text("Pharmacy: Main Street")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary, lineWidth: 1)
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Atorvastatin 20 mg")
                .accessibilityCustomContent("Status", "Ready for pickup")
                .accessibilityCustomContent("Refills remaining", "2")
                .accessibilityCustomContent("Pharmacy", "Main Street")
                DisclosureGroup("Details") {
                    Text("The bad visible text example uses `.accessibilityElement(children: .ignore)` to throw away all four visible `Text` views and keeps only the first line in `.accessibilityLabel(\"Atorvastatin 20 mg\")`. VoiceOver speaks just the drug name on focus, so three lines that are printed on the card are never heard unless the user thinks to open the More Content rotor. The accessible name no longer contains the visible text, which fails WCAG 2.5.3 Label in Name, and a Voice Control user who says \"tap Ready for pickup\" gets no match. Custom content is for details that are not on screen, it must never be used to shorten a name by removing text that is.")
                }.padding(.bottom).accessibilityHint("Bad Example Visible Text Moved Into Custom Content")
                Text("Bad Example Essential Status In Custom Content")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button(action: {}) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Metformin 500 mg").font(.headline)
                        Text("Prescription expired")
                            .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary, lineWidth: 1)
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Metformin 500 mg")
                .accessibilityCustomContent("Status", "Prescription expired")
                DisclosureGroup("Details") {
                    Text("The bad essential status example pulls the visible \"Prescription expired\" text out of the name and into default importance custom content, so VoiceOver announces only \"Metformin 500 mg, button\" and users can miss that the prescription cannot be refilled. Raising it to `importance: .high` would get it spoken, but the name would still be missing visible text, so `.high` is not a fix for this. Essential state belongs in the accessible name, either by letting the Button use its visible text or by putting it in `.accessibilityValue`.")
                }.padding(.bottom).accessibilityHint("Bad Example Essential Status In Custom Content")
                Text("Bad Example Content Only in the Rotor")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button(action: {}) {
                    HStack {
                        // The dot is a decorative status indicator inside the Button's label,
                        // not a touch target of its own — the Button provides the tappable area.
                        Circle()
                            .fill(colorScheme == .dark ? Color(.systemRed) : darkRed)
                            // a11y-check:disable-next-line small-touch-target
                            .frame(width: 12, height: 12)
                        Text("Lisinopril 10 mg")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary, lineWidth: 1)
                )
                .accessibilityCustomContent("Status", "Action required")
                DisclosureGroup("Details") {
                    Text("The bad rotor only example conveys \"Action required\" with a red dot on screen and with `.accessibilityCustomContent(\"Status\", \"Action required\")` in the More Content rotor, and nowhere else. Sighted users have to know what the color means, which fails WCAG 1.4.1 Use of Color, and custom content is only surfaced by VoiceOver, so Voice Control and Full Keyboard Access users never receive it at all. Add visible text for the status so that every user gets it, then the name carries it too.")
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
