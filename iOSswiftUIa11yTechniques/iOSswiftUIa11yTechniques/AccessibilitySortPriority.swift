/*
   Copyright 2025-2026 CVS Health and/or one of its affiliates

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

struct AccessibilitySortPriority: View {
    @State private var selectedDate = Date()
    @State private var isDatePickerPresented = false
    @AccessibilityFocusState private var isTriggerFocused: Bool


    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("`.accessibilitySortPriority(#)` can be used to control VoiceOver reading order if the default order is not meaningful. Higher numbers are sorted first, e.g. 99 is read before 1. The default sort priority is 0.")
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
                HStack {
                    Text("Birth Date")
                    Button(action: {
                         isDatePickerPresented = true
                     }) {
                         HStack {
                             Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                                 .padding(10)
                                 .background(Color.gray.opacity(0.2))
                                 .foregroundColor(colorScheme == .dark ? .white : .black)
                                 .cornerRadius(10)
                         }
                     }
                     .accessibilityLabel("Birth Date")
                     .accessibilityValue(selectedDate.formatted(date: .abbreviated, time: .omitted))
                     .accessibilityFocused($isTriggerFocused)
                     .sheet(isPresented: $isDatePickerPresented) {
                         HStack {
                             Spacer()
                             Button("Done") {
                                 isDatePickerPresented = false
                                 isTriggerFocused = true
                             }
                         }.padding()
                         DatePicker("Birth Date", selection: $selectedDate, displayedComponents: [.date])
                             .datePickerStyle(.wheel)
                             .labelsHidden()
                             .accessibilitySortPriority(1) // make VoiceOver focus go here first when sheet opens
                         .presentationDetents([.height(300)])
                         .presentationDragIndicator(.hidden)
                     }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The good example uses `DatePicker` with `.accessibilitySortPriority(1)` to make VoiceOver focus go to the wheel style date picker first when the sheet opens. Without a sort priority, focus would go to the Done button first.")
                }.padding(.bottom).accessibilityHint("Good Example")
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
                NavigationLink(destination: AccessibilitySortPriorityBad()) {
                    Text("Opens a page with incorrect `.accessibilitySortPriority` values that break VoiceOver reading order.")
                        .padding()
                }
                DisclosureGroup("Details") {
                    Text("The bad example uses `.accessibilitySortPriority()` with incorrect values in a `ZStack` layout. The tab bar at the bottom has the highest priority (3), so VoiceOver reads it first. The header has priority 2 and the body content has priority 1, so swiping right from the header jumps to the tab bar instead of the body. The correct reading order should be header → body → tab bar, matching the visual top-to-bottom layout.")
                }.padding(.bottom).accessibilityHint("Bad Example")
            }
            .navigationTitle("Accessibility Sort Priority")
            .padding()
        }
    }
}

struct AccessibilitySortPriorityBad: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text("Welcome Back")
                        .font(.title)
                        .accessibilityAddTraits(.isHeader)
                    Text("Good morning, Jane")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGroupedBackground))
                .accessibilitySortPriority(2)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Today's Tasks")
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)
                        Text("Review accessibility audit results for the home screen.")
                        Text("Update VoiceOver labels on the checkout flow.")
                        Text("Test Dynamic Type at all size categories.")
                        Text("Fix focus order after dismissing the settings sheet.")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .accessibilitySortPriority(1)

                HStack {
                    VStack {
                        Image(systemName: "house.fill")
                        Text("Home").font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityElement(children: .combine)
                    Spacer()
                    VStack {
                        Image(systemName: "magnifyingglass")
                        Text("Search").font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityElement(children: .combine)
                    Spacer()
                    VStack {
                        Image(systemName: "gearshape")
                        Text("Settings").font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityElement(children: .combine)
                }
                .padding(.vertical, 8)
                .background(Color(.systemGroupedBackground))
                .accessibilitySortPriority(3)
            }
        }
        .navigationTitle("Bad Sort Priority")
    }
}

#Preview {
    NavigationStack {
        AccessibilitySortPriority()
    }
}
