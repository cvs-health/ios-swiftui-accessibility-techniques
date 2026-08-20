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

import SwiftUI
import CoreMotion

private class MotionManager: ObservableObject {
    let manager = CMMotionManager()
    @Published var lastAction = "No action yet"

    func startShakeDetection(action: @escaping () -> Void) {
        guard manager.isDeviceMotionAvailable else { return }
        manager.deviceMotionUpdateInterval = 0.1
        manager.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let data = data else { return }
            let accel = data.userAcceleration
            if abs(accel.x) > 2.0 || abs(accel.y) > 2.0 || abs(accel.z) > 2.0 {
                action()
            }
        }
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
    }
}

struct MotionActuationView: View {
    @StateObject private var goodMotion = MotionManager()
    @StateObject private var badMotion = MotionManager()
    @State private var goodItems = ["Apples", "Bananas", "Cherries", "Dates"]
    @State private var badItems  = ["Apples", "Bananas", "Cherries", "Dates"]
    @State private var goodLastUndo = "Nothing undone yet"
    @State private var badLastUndo  = "Nothing undone yet"

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Device motion (shake, tilt, accelerometer) must also be operable through a standard UI control so users with mounted devices (e.g. wheelchair mounts) or motor disabilities can access the same functionality. Use `CMMotionManager` alongside a visible Button that triggers the same action. The a11y-check `motion-actuation-missing-alternative` rule (WCAG 2.5.4) fires on any file that uses `CMMotionManager` or CoreMotion update methods, prompting a manual review to confirm a UI alternative exists.")
                    .padding(.bottom)

                Text("Good Example")
                    .font(.subheadline).fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2).background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                Text("Good Example Shake to Undo")
                    .font(.subheadline).fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Last undo: \(goodLastUndo)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                ForEach(goodItems, id: \.self) { item in
                    Text(item)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .padding(.vertical, 2)
                }
                Button("Undo Last Edit") {
                    performGoodUndo()
                }
                .buttonStyle(.bordered)
                .padding(.top, 8)
                .accessibilityLabel("Undo Last Edit")
                DisclosureGroup("Details") {
                    Text("The good example detects shaking via `CMMotionManager.startDeviceMotionUpdates` and also provides a visible \"Undo Last Edit\" Button that calls the same `performGoodUndo()` function. Users with mounted devices who cannot shake their phone can use the Button instead. The a11y-check `motion-actuation-missing-alternative` rule will still flag this file as a warning — review manually to confirm the Button is reachable.")
                }
                .padding(.bottom).accessibilityHint("Good Example Shake to Undo")

                Text("Bad Example")
                    .font(.subheadline).fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2).background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                Text("Bad Example Shake to Undo - No Button Alternative")
                    .font(.subheadline).fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Last undo: \(badLastUndo)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                ForEach(badItems, id: \.self) { item in
                    Text(item)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .padding(.vertical, 2)
                }
                DisclosureGroup("Details") {
                    Text("The bad example only uses `CMMotionManager` to detect shaking — there is no Button alternative. Users with mounted devices or motor disabilities who cannot physically shake their phone have no way to trigger the undo action. The a11y-check `motion-actuation-missing-alternative` rule flags `CMMotionManager` usage to prompt a manual review for a UI control alternative.")
                }
                .padding(.bottom).accessibilityHint("Bad Example Shake to Undo - No Button Alternative")
            }
            .padding()
        }
        .navigationTitle("Motion Actuation")
        .onAppear {
            goodMotion.startShakeDetection { performGoodUndo() }
            badMotion.startShakeDetection { performBadUndo() }
        }
        .onDisappear {
            goodMotion.stop()
            badMotion.stop()
        }
    }

    private func performGoodUndo() {
        if !goodItems.isEmpty {
            let removed = goodItems.removeLast()
            goodLastUndo = "Removed \"\(removed)\""
        } else {
            goodLastUndo = "Nothing to undo"
        }
    }

    private func performBadUndo() {
        if !badItems.isEmpty {
            let removed = badItems.removeLast()
            badLastUndo = "Removed \"\(removed)\""
        } else {
            badLastUndo = "Nothing to undo"
        }
    }
}

#Preview {
    NavigationStack {
        MotionActuationView()
    }
}
