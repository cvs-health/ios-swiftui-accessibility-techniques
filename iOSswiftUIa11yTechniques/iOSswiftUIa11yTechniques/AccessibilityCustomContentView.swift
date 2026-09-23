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

/// Example data model for the Accessibility Custom Content seat map example.
private struct Seat: Identifiable {
    let row: Int
    let column: String

    /// Window seat, middle seat, or aisle seat — conveyed only by where the
    /// seat sits in the map.
    var position: String {
        switch column {
        case "A", "F": return "Window seat"
        case "C", "D": return "Aisle seat"
        default: return "Middle seat"
        }
    }

    /// Front, middle, or rear of the cabin — conveyed only by vertical position.
    var cabinArea: String {
        switch row {
        case ..<13: return "Front"
        case 13...14: return "Middle"
        default: return "Rear"
        }
    }

    var id: String { "\(row)\(column)" }
}

/// Draws a seat as a bordered square that fills when selected, while leaving the
/// `Toggle` wrapper to supply the on and off accessibility semantics.
///
/// The built in `.toggleStyle(.button)` discards the seat border and renders the
/// selected state as a large tinted circle, which stops the grid reading as a
/// seat map.
private struct SeatToggleStyle: ToggleStyle {
    let selectedBackground: Color

    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            configuration.label
                // Flexible width so six seats plus the aisle always fit the
                // screen. A fixed width overflows narrow devices and clips
                // adjacent text. Height keeps the 44pt touch target.
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(configuration.isOn ? selectedBackground : Color.clear)
                .foregroundColor(configuration.isOn ? Color(.systemBackground) : Color.primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.primary, lineWidth: configuration.isOn ? 3 : 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct AccessibilityCustomContentView: View {
    @State private var selectedSeats: Set<String> = []

    private let rows = [12, 13, 14, 15]
    private let columns = ["A", "B", "C", "D", "E", "F"]

    // Reusable keys, so the same details keep a consistent place in the rotor
    // across every seat in the map.
    //
    // The position key has an empty label because its values are already self
    // describing — "Middle seat" needs no "Position" prefix in front of it.
    // Cabin area keeps a label because "Front" alone would not make sense.
    private let positionKey = AccessibilityCustomContentKey("", id: "position")
    private let cabinAreaKey = AccessibilityCustomContentKey("Cabin area", id: "cabinArea")

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Use `.accessibilityCustomContent` to expose information that the visual design conveys without text, such as an element's position within a layout. VoiceOver speaks `.default` importance content only when the user asks for it using the More Content rotor, and speaks `.high` importance content immediately. With VoiceOver on rotate 2 fingers on the screen to select the More Content rotor option and then swipe up or down with 1 finger to hear each detail.")
                    .padding(.bottom)
                Text("Custom content adds to an element, it never replaces its accessible name. Do not override `.accessibilityLabel` to make room for it — let the element keep the name it derives from its own visible text. Anything essential belongs in the name, `.accessibilityValue`, or a trait. Content at `.default` importance is always reachable through the More Content rotor, but VoiceOver's Verbosity > More Content setting controls whether users get any cue that an element has it, and that setting can be turned off entirely, so users may never think to look.")
                    .padding(.bottom)
                Text("Good Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                Text("Seat Map")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack(spacing: 4) {
                    ForEach(rows, id: \.self) { row in
                        HStack(spacing: 4) {
                            ForEach(Array(columns.enumerated()), id: \.element) { index, column in
                                seatButton(for: Seat(row: row, column: column))
                                if index == 2 {
                                    // The aisle. Sighted users see the gap, so the seats
                                    // beside it are visibly the aisle seats.
                                    Spacer().frame(width: 12)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom)
                Text(selectedSeats.isEmpty ? "No seats selected" : "Selected seats: \(selectedSeats.sorted().joined(separator: ", "))")
                    .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The good seat map example sets no `.accessibilityLabel` at all. Each seat is a `Toggle` whose label is `Text(\"14C\")`, so VoiceOver derives the name from the visible text exactly as it reads on screen. A `Toggle` is used rather than a Button so that both states are conveyed: a Button carrying only the `.isSelected` trait announces \"selected\" when on but says nothing at all when off, leaving users unable to tell an unselected seat from a plain button. The Toggle is exposed as a switch whose value changes between off and on, so VoiceOver speaks the state either way. Whether a seat is a window seat, middle seat, or aisle seat is conveyed only by where it sits in the grid, and which part of the cabin it is in is conveyed only by how far down the map it appears. Sighted users read both from the layout, but a VoiceOver user moving through the seats one at a time loses the two dimensional arrangement, so `.accessibilityCustomContent(positionKey, seat.position, importance: .high)` and `.accessibilityCustomContent(cabinAreaKey, seat.cabinArea)` carry that spatial information instead. The position key uses an empty label so VoiceOver speaks only the value, \"Window seat\", rather than prefixing it with a redundant \"Position\". Cabin area keeps its label, because the value \"Front\" would mean nothing on its own. Nothing here is information sighted users do not have, and nothing has been taken out of the name to make room for it. Position uses `importance: .high` because it is the attribute people choose a seat by, so VoiceOver speaks it immediately. Cabin area stays at the default importance in the More Content rotor. Both use an `AccessibilityCustomContentKey` with a stable `id` so the same two details keep a consistent position in the rotor as users move across the map. Selection is essential state, so it is carried by the Toggle itself rather than by custom content. A custom `SeatToggleStyle` draws the seat as a bordered square that fills when selected, because the built in `.toggleStyle(.button)` discards the border and renders the selected state as a large tinted circle that stops the grid reading as a seat map. The style wraps `configuration.label` in a Button, which keeps the switch semantics the Toggle provides. The seats use `.frame(maxWidth: .infinity, minHeight: 44)` so the row always fits the screen width instead of overflowing narrow devices and clipping the text beside it.")
                }.padding(.bottom).accessibilityHint("Seat Map")
            }
            .padding()
            .navigationTitle("Accessibility Custom Content")
        }
    }

    @ViewBuilder
    private func seatButton(for seat: Seat) -> some View {
        // A Toggle rather than a Button, so VoiceOver conveys both the selected
        // and the unselected state. A plain Button with only the .isSelected
        // trait announces "selected" when on and says nothing at all when off,
        // leaving users unable to tell an unselected seat from a plain button.
        Toggle(isOn: Binding(
            get: { selectedSeats.contains(seat.id) },
            set: { isOn in
                if isOn {
                    selectedSeats.insert(seat.id)
                } else {
                    selectedSeats.remove(seat.id)
                }
            }
        )) {
            Text(seat.id)
                .font(.caption)
        }
        .toggleStyle(SeatToggleStyle(selectedBackground: colorScheme == .dark ? Color(.systemGreen) : darkGreen))
        .accessibilityCustomContent(positionKey, seat.position, importance: .high)
        .accessibilityCustomContent(cabinAreaKey, seat.cabinArea)
    }
}

#Preview {
    NavigationStack {
        AccessibilityCustomContentView()
    }
}
