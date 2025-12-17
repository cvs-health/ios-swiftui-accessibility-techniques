/*
   Copyright 2024-2025 CVS Health and/or one of its affiliates

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
 
struct DimFlashingLightsView: View {
    
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Do not use flashing content as it can cause migraines, dizziness, nausea, and seizures. If flashing content is used then support the Dim Flashing Lights accessibility setting and stop the flashing. Use the `@Environment(\\.accessibilityDimFlashingLights)` variable to stop flashing content when Dim Flashing Lights is enabled.")
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
                NavigationLink(destination: FlashingRectangleGood()) {
                    Text("PHOTOSENSITIVITY WARNING! Opens a Flashing Page that stops flashing only if Dim Flashing Lights is enabled.")
                        .padding()
                }
                DisclosureGroup("Details") {
                    Text("The good example listens for `.accessibilityDimFlashingLights` and will stop flashing when it is enabled.")
                }.padding().accessibilityHint("Good Example")
                Text("Bad Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                NavigationLink(destination: FlashingRectangleBad()) {
                    Text("PHOTOSENSITIVITY WARNING! Opens a Flashing Page that never stops flashing.")
                        .padding()
                }
                DisclosureGroup("Details") {
                    Text("The bad example does not listen for `.accessibilityDimFlashingLights` and will keep flashing indefinitely.")
                }.padding().accessibilityHint("Bad Example")
            }
            .navigationTitle("Dim Flashing Lights")
            .padding()
        }
 
    }
    
}

#Preview {
    NavigationStack {
        DimFlashingLightsView()
    }
}

// MARK: - Detail Page with Conditional Flashing Logic

struct FlashingRectangleGood: View {
    @State private var isFlashing = false
    // 4 Hz flash rate (unsafe according to WCAG)
    private let flashInterval: TimeInterval = 1.0 / 4.0
    @State private var timer: Timer? = nil
    
    @Environment(\.accessibilityDimFlashingLights) private var dimFlashingLightsEnabled

    
    var body: some View {
        VStack {
            Text(dimFlashingLightsEnabled ? "Flashing is SAFELY Disabled" : "Flashing is Active (Unsafe)")
                .font(.headline)
                .padding()

            Rectangle()
                .fill(currentRectangleColor())
                .frame(width: 200, height: 200)
        }
        .navigationTitle("Dim Flashing Lights Good Example")
        .onAppear {
            // Start the timer ONLY if the setting is OFF
            if !dimFlashingLightsEnabled {
                // We create a non-repeating timer wrapper to manage the cycle
                timer = Timer.scheduledTimer(withTimeInterval: flashInterval, repeats: true) { _ in
                    isFlashing.toggle()
                }
            }
        }
        .onDisappear {
            // Invalidate the timer when the user navigates back
            timer?.invalidate()
            timer = nil
        }
    }

    // Function to decide the color based on the setting status
    func currentRectangleColor() -> Color {
        if dimFlashingLightsEnabled {
            // If the setting is ON, the color is static blue (safe)
            return Color.black
        } else {
            // If the setting is OFF, the color alternates (unsafe)
            return isFlashing ? Color.black : Color.white
        }
    }
}

// MARK: - Bad Detail Page with No Conditional Flashing Logic

struct FlashingRectangleBad: View {
    @State private var isFlashing = false
    // 4 Hz flash rate (unsafe according to WCAG)
    private let flashInterval: TimeInterval = 1.0 / 4.0
    @State private var timer: Timer? = nil
    
    var body: some View {
        VStack {
            Text("Flashing is Active (Unsafe)")
                .font(.headline)
                .padding()

            Rectangle()
                .fill(currentRectangleColor())
                .frame(width: 200, height: 200)
        }
        .navigationTitle("Dim Flashing Lights Bad Example")
        .onAppear {
            // We create a non-repeating timer wrapper to manage the cycle
            timer = Timer.scheduledTimer(withTimeInterval: flashInterval, repeats: true) { _ in
                isFlashing.toggle()
            }
        }
        .onDisappear {
            // Invalidate the timer when the user navigates back
            timer?.invalidate()
            timer = nil
        }
    }

    // Function to decide the color based on the setting status
    func currentRectangleColor() -> Color {
        return isFlashing ? Color.black : Color.white
    }
}

