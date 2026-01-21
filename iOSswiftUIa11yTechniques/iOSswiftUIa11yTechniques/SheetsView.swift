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

enum DynamicTriggerFocus: Hashable {
    case none
    case button(Int) // Use 0...7
}

struct SheetsView: View {
    @State private var isShowingSheet = false
    @State private var isShowingSheet2 = false
    @State private var isShowingBadSheet = false
    @AccessibilityFocusState private var isTriggerFocused: Bool
    @AccessibilityFocusState private var isTriggerFocused2: Bool

    @State private var isShowingDynamicSheets = Array(repeating: false, count: 8)
    @AccessibilityFocusState private var dynamicTriggerFocus: DynamicTriggerFocus?
    
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("VoiceOver focus must move to the sheet when displayed and back to the trigger button when the sheet is closed. Sheet title text must be coded as a Heading for VoiceOver users. Use `.sheet()` to code a native SwiftUI sheet that receives VoiceOver focus when opened. Use `AccessibilityFocusState` to send focus back to the trigger button that opened the sheet when the sheet is closed. Place the sheet's content inside a `ScrollView` or else the text will truncate when enlarged.")
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
                Button(action: {
                    isShowingSheet.toggle()
                }) {
                    Text("Show License Agreement")
                }
                    .accessibilityFocused($isTriggerFocused)
                    .frame(maxWidth: .infinity, alignment: .leading)
                .sheet(isPresented: $isShowingSheet,
                       onDismiss: didDismiss) {
                    ScrollView {
                        VStack {
                            Text("License Agreement")
                                .font(.title)
                                .accessibilityAddTraits(.isHeader)
                            Text("""
                                Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
                                """)
                                .padding(20)
                            Button("Dismiss",
                                   action: {
                                        isShowingSheet.toggle()
                                    })
                        }
                        .padding()
                    }
                    //.presentationDetents([.medium, .large]) // Supports medium and large sizes
                    //.presentationDragIndicator(.hidden) // Optionally hides the drag indicator

                }
                ForEach(0..<8) { index in
                    Button(action: {
                        isShowingDynamicSheets[index].toggle()
                    }) {
                        Text("Show License Agreement #\(index + 1)")
                    }
                    .accessibilityFocused($dynamicTriggerFocus, equals: .button(index))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .sheet(isPresented: $isShowingDynamicSheets[index], onDismiss: {
                        dynamicTriggerFocus = .button(index)
                    }) {
                        ScrollView {
                            VStack {
                                Text("License Agreement #\(index + 1)")
                                    .font(.title)
                                    .accessibilityAddTraits(.isHeader)
                                Text("""
                                    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
                                    """)
                                    .padding(20)
                                Button("Dismiss") {
                                    isShowingDynamicSheets[index].toggle()
                                }
                            }
                            .padding()
                        }
                    }
                }
                
                DisclosureGroup("Details") {
                    Text("The good sheet example uses `.sheet()` to create a native SwiftUI sheet that receives VoiceOver focus when displayed. Additionally, `AccessibilityFocusState` is used to send focus back to the trigger button that opened the sheet when the sheet is closed. The sheet title is correctly coded as a heading.")
                }.padding(.bottom).accessibilityHint("Good Example")
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
                Text("Bad Example Custom View")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button(action: {
                    isShowingBadSheet.toggle()
                }) {
                    Text("Show License Agreement")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if (isShowingBadSheet){
                    VStack {
                        Text("License Agreement")
                            .font(.title)
                        Text("""
                            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
                            """)
                            .padding(20)
                        Button("Dismiss",
                               action: { isShowingBadSheet.toggle() })
                    }
                }
                DisclosureGroup("Details") {
                    Text("The bad sheet example uses a custom view which does not receive VoiceOver focus when displayed and does not return focus when closed. The sheet title is not coded as a heading.")
                }.accessibilityHint("Bad Example Custom View")
                Text("Bad Example `.sheet` no `ScrollView`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button(action: {
                    isShowingSheet2.toggle()
                }) {
                    Text("Show License Agreement")
                }
                    .accessibilityFocused($isTriggerFocused2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                .sheet(isPresented: $isShowingSheet2,
                       onDismiss: didDismiss2) {
                    VStack {
                        Text("License Agreement")
                            .font(.largeTitle)
                            .accessibilityAddTraits(.isHeader)
                            .lineLimit(1)
                        Text("""
                            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
                            """)
                            .padding(20)
                            .font(.title3)
                        Button("Dismiss",
                               action: {
                                    isShowingSheet2.toggle()
                                })
                    }
                    .padding()
                }
                DisclosureGroup("Details") {
                    Text("The bad `.sheet` example that has no `ScrollView` shows how the text truncates when it is larger than the visible area.")
                }.accessibilityHint("Bad Example .sheet no ScrollView")
            }
            .navigationTitle("Sheets")
            .padding()
        }

    }
    func didDismiss() {
        // Handle the dismissing action.
        isTriggerFocused = true
    }
    func didDismiss2() {
        // Handle the dismissing action.
        isTriggerFocused2 = true
    }

}

struct SheetsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SheetsView()
        }
    }
}
