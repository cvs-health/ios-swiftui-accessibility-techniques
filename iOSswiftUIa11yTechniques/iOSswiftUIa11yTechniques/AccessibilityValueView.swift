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

struct AccessibilityValueView: View {
    @State private var rating = 3
    @State private var ratingBad = 3
    @State private var currentStep = 2
    @State private var currentStepBad = 2
    @State private var isActive = true
    @State private var isActiveBad = true
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Use `.accessibilityValue` to convey the current value or state of a control to VoiceOver users. The value should describe the current state, not the label or action. Use `.accessibilityValue` for custom controls that have a changeable state or value that is not automatically communicated by SwiftUI.")
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
                Text("Good Example Star Rating")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { star in
                        Button(action: {
                            rating = star
                        }) {
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .foregroundColor(star <= rating ? .yellow : .gray)
                                .font(.title2)
                        }
                        .accessibilityHidden(true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Rating")
                .accessibilityValue("\(rating) out of 5")
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment:
                        rating = min(rating + 1, 5)
                    case .decrement:
                        rating = max(rating - 1, 1)
                    @unknown default:
                        break
                    }
                }
                DisclosureGroup("Details") {
                    Text("The good star rating example uses `.accessibilityValue(\"\\(rating) out of 5\")` so VoiceOver reads the current rating value. The stars are grouped with `.accessibilityElement(children: .ignore)` and given a single `.accessibilityLabel(\"Rating\")`. The `.accessibilityAdjustableAction` allows VoiceOver users to swipe up and down to change the rating.")
                }.padding(.bottom).accessibilityHint("Good Example Star Rating")
                Text("Good Example Step Indicator")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack(spacing: 8) {
                    ForEach(1...4, id: \.self) { step in
                        Circle()
                            .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 24, height: 24)
                            .overlay(
                                Text("\(step)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(step <= currentStep ? .white : .gray)
                            )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Progress")
                .accessibilityValue("Step \(currentStep) of 4")
                DisclosureGroup("Details") {
                    Text("The good step indicator example uses `.accessibilityValue(\"Step \\(currentStep) of 4\")` so VoiceOver reads the current step. The individual step circles are grouped with `.accessibilityElement(children: .ignore)` and given a single `.accessibilityLabel(\"Progress\")`.")
                }.padding(.bottom).accessibilityHint("Good Example Step Indicator")
                Text("Good Example Custom Toggle")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button(action: {
                    isActive.toggle()
                }) {
                    HStack {
                        Image(systemName: isActive ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isActive ? .green : .gray)
                            .font(.title2)
                        Text("Notifications")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel("Notifications")
                .accessibilityValue(isActive ? "enabled" : "disabled")
                DisclosureGroup("Details") {
                    Text("The good custom toggle example uses `.accessibilityValue(isActive ? \"enabled\" : \"disabled\")` so VoiceOver reads the current state. Without `.accessibilityValue`, VoiceOver would not convey whether the toggle is on or off.")
                }.padding(.bottom).accessibilityHint("Good Example Custom Toggle")
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
                Text("Bad Example Star Rating without Value")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { star in
                        Button(action: {
                            ratingBad = star
                        }) {
                            Image(systemName: star <= ratingBad ? "star.fill" : "star")
                                .foregroundColor(star <= ratingBad ? .yellow : .gray)
                                .font(.title2)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The bad star rating example has no `.accessibilityValue` and no `.accessibilityElement(children: .ignore)` grouping. VoiceOver reads each star as a separate button with SF Symbol names instead of reading a single rating value like \"3 out of 5\". Users cannot determine the current rating.")
                }.padding(.bottom).accessibilityHint("Bad Example Star Rating without Value")
                Text("Bad Example Step Indicator without Value")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack(spacing: 8) {
                    ForEach(1...4, id: \.self) { step in
                        Circle()
                            .fill(step <= currentStepBad ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 24, height: 24)
                            .overlay(
                                Text("\(step)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(step <= currentStepBad ? .white : .gray)
                            )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The bad step indicator example has no `.accessibilityValue` and no `.accessibilityElement(children: .ignore)` grouping. VoiceOver reads each step number individually without conveying which step is current or how many total steps exist.")
                }.padding(.bottom).accessibilityHint("Bad Example Step Indicator without Value")
                Text("Bad Example Custom Toggle without Value")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button(action: {
                    isActiveBad.toggle()
                }) {
                    HStack {
                        Image(systemName: isActiveBad ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isActiveBad ? .green : .gray)
                            .font(.title2)
                        Text("Notifications")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The bad custom toggle example has no `.accessibilityValue` to convey the current state. VoiceOver reads \"Notifications, button\" but users cannot tell if notifications are currently enabled or disabled.")
                }.padding(.bottom).accessibilityHint("Bad Example Custom Toggle without Value")
            }
            .padding()
            .navigationTitle("Accessibility Value")
        }
    }
}

#Preview {
    NavigationStack {
        AccessibilityValueView()
    }
}
