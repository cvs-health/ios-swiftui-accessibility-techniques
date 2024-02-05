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

struct ProgressIndicatorsView: View {

    @State private var progressIndicatorBadVisible = false
    @State private var progressIndicatorGoodVisible = false
    
    @State private var progress = 0.8

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Progress indicators are used to show page loading status or the progress of a task. Create progress indicators with visible `ProgressView(\"Label\")` label text. Post an `AccessibilityNotification.Announcement` speaking the loading indicator text to VoiceOver when displaying page loading indicators.")
                    .padding([.bottom])
                Text("Good Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                Text("Good Example 1")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack {
                    if progressIndicatorGoodVisible {
                        ProgressView("Updating your information")
                            .accessibilityIdentifier("progressView1good")
                    }
                    Button(action: {
                        progressIndicatorGoodVisible = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            AccessibilityNotification.Announcement("Updating your information").post()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            progressIndicatorGoodVisible = false
                        }
                    }) {
                        Text("Save")
                    }.padding().frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityIdentifier("saveGood")
                }
                DisclosureGroup("Details") {
                    Text("The first good progress indicator example posts an `AccessibilityNotification.Announcement` that speaks the indicator text \"Updating your information\" to VoiceOver when the progress view displays. The announcement is posted with a 0.1 second delay to make it speak correctly to VoiceOver.")
                }.padding()
                Text("Good Example 2")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                ProgressView("Downloading Purchase Receipt", value: 20, total: 100).padding()
                    .accessibilityIdentifier("progressView2good")
                DisclosureGroup("Details") {
                    Text("The second good progress indicator example uses visible label text `ProgressView(\"Downloading Purchase Receipt\")`.")
                }.padding()
                Text("Bad Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                Text("Bad Example 1")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                VStack {
                    if progressIndicatorBadVisible {
                        ProgressView()
                            .accessibilityIdentifier("progressView1bad")
                    }
                    Button(action: {
                        progressIndicatorBadVisible = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            progressIndicatorBadVisible = false
                        }
                    }) {
                        Text("Save")
                    }.padding().frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityIdentifier("saveBad")
                }
                DisclosureGroup("Details") {
                    Text("The first bad progress indicator example does not speak an accessibility announcement notification to VoiceOver when the progress view displays. There is no label text for the progress view and no accessibility label for VoiceOver.")
                }.padding()
                Text("Bad Example 2")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                ProgressView(value: 20, total: 100).padding()
                    .accessibilityIdentifier("progressView2bad")
                DisclosureGroup("Details") {
                    Text("The second bad progress indicator example has no visible label text and no accessibility label for VoiceOver.")
                }.padding()
            }
            .padding()
            .navigationTitle("Progress Indicators")

        }
 
    }
}
 
struct ProgressIndicatorsView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressIndicatorsView()
    }
}
