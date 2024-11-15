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
import SafariServices

 
struct InformativeView: View {
    
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    @State var isPresentVC = false
    @AccessibilityFocusState private var isTriggerFocused: Bool


    var body: some View {
        ScrollView {
            VStack {
                Text("Informative images provide information or convey meaning to sighted users that must be accessible to VoiceOver users. Give informative images an accessibility label either through `Label(\"text\")` or `.accessibilityLabel(\"text\")`. Use `.accessibilityElement(children: .combine)` to combine an image and text into a single focusable element with VoiceOver.").textSelection(.enabled)
//                    .monospaced()
//                    .padding()
//                    .background(colorScheme == .dark ? Color.secondary.opacity(0.3) : Color.secondary.opacity(0.1))
//                    .cornerRadius(8)
//                    .lineLimit(nil)
                ZStack {
                    Button("Informative Images Documentation") {
                        isPresentVC = true
                    }
                    .accessibilityFocused($isTriggerFocused)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }.sheet(isPresented: $isPresentVC, content: {
                    HStack {
                        Spacer()
                        Button("Done") {
                            isPresentVC = false
                            //isTriggerFocused = true
                        }
                    }
                    .padding()
                    WebViewRepresentable(url: "https://github.com/cvs-health/ios-swiftui-accessibility-techniques/blob/main/iOSswiftUIa11yTechniques/Documentation/InformativeImages.md#informative-images")
                        .edgesIgnoringSafeArea(.all)
                })
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
                Text("Good Example `Image().accessibilityLabel`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Image("get10off")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .accessibilityLabel("Get 10% off")
                    .accessibilityIdentifier("goodImage")
                Text("Sign up for our newsletter.")
                DisclosureGroup("Details") {
                    VStack {
                        Text("The good informative image example uses `.accessibilityLabel(\"Get 10% off\")` to give it an accessibility label that matches the visible text shown in the image.").textSelection(.enabled)
                    }
                }.padding(.bottom).accessibilityHint("Good Example `Image().accessibilityLabel`")
                Text("Good Example `Label(\"Text\", systemImage:).accessibilityRemoveTraits(.isImage)` `HStack {}.accessibilityElement(children: .combine)`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Text("Hello,")
                    Label("World", systemImage: "globe").labelStyle(IconOnlyLabelStyle()).accessibilityRemoveTraits(.isImage)
                        .accessibilityIdentifier("goodIcon")
                    Text("!")
                }.accessibilityElement(children: .combine)
                DisclosureGroup("Details") {
                    VStack {
                        Text("The good informative icon image example uses `Label(\"World\", systemImage: \"globe\").labelStyle(IconOnlyLabelStyle())` to give the informative icon an accessibility label that is not displayed visually. Additionally `.accessibilityRemoveTraits(.isImage)` must be used on the icon image so that the accessibility label is spoken to VoiceOver when the `HStack` is combined into a single focusable element using `.accessibilityElement(children: .combine)`.")
                    }
                }.padding(.bottom).accessibilityHint("Good Example `Label(\"Text\", systemImage:).accessibilityRemoveTraits(.isImage)` `HStack {}.accessibilityElement(children: .combine)`")
                Text("Good Example `Image` combined with `Text`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Image(systemName: "exclamationmark.circle")
                        .accessibilityLabel("Error:")
                    Text("We're sorry. We can't show the offer details right now.").bold().font(.callout)
                }
                .accessibilityElement(children: .combine)
                .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                DisclosureGroup("Details") {
                    VStack {
                        Text("The good `Image` combined with `Text` example uses `Image(systemName: \"exclamationmark.circle\").accessibilityLabel(\"Error:\")` to give the error icon alt text. `.accessibilityElement(children: .combine)` is used on the `HStack` to combine the image and text into a single focusable element with VoiceOver.")
                    }
                }.padding(.bottom).accessibilityHint("Good Example `Image` combined with `Text`")
                Text("Good Example `Label` combined with `Text`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Label("Error:", systemImage: "exclamationmark.circle").labelStyle(IconOnlyLabelStyle()).accessibilityRemoveTraits(.isImage)
                    Text("We're sorry. We can't show the offer details right now.").bold().font(.callout)
                }
                .accessibilityElement(children: .combine)
                .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                DisclosureGroup("Details") {
                    VStack {
                        Text("The good `Label` combined with `Text` example uses `Label(\"Error:\", systemImage: \"exclamationmark.circle\").labelStyle(IconOnlyLabelStyle())` to give the icon an accessibility `Label` that is not displayed visually. Additionally `.accessibilityRemoveTraits(.isImage)` must be used on the `Label` icon image so that the accessibility label is spoken to VoiceOver when the `HStack` is combined into a single focusable element using `.accessibilityElement(children: .combine)`.")
                    }
                }.padding(.bottom).accessibilityHint("Good Example `Label` combined with `Text`")
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
                Text("Bad Example `Image` no `.accessibilityLabel`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Image("get10off")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .accessibilityIdentifier("badImage")
                Text("Sign up for our newsletter.")
                DisclosureGroup("Details") {
                    VStack {
                        Text("The bad informative image example uses no `.accessibilityLabel` for the image causing VoiceOver to read the image filename* which is not meaningful. *Disable VoiceOver Text Recognition")
                    }
                }.padding(.bottom).accessibilityHint("Bad Example `Image` no `.accessibilityLabel`")
                Text("Bad Example `systemImage:` no `Label` text `HStack` not combined")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Text("Hello,")
                    Label("", systemImage: "globe").labelStyle(IconOnlyLabelStyle())
                        .accessibilityIdentifier("badIcon")
                    Text("!")
                }
                DisclosureGroup("Details") {
                    VStack {
                        Text("The bad informative icon image example uses no `Label` text to give the informative icon an accessibility label causing VoiceOver to read the image as \"Image\". VoiceOver focuses on each individual part of the line of text because the `HStack` is not combined into one focusable element.")
                    }
                }.padding(.bottom).accessibilityHint("Bad Example `systemImage:` no `Label` text `HStack` not combined")
                Text("Bad Example `Image` combined with `Text`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Image(systemName: "exclamationmark.circle")
                    Text("We're sorry. We can't show the offer details right now.").bold().font(.callout)
                }
                .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                DisclosureGroup("Details") {
                    VStack {
                        Text("The bad `Image` combined with `Text` example uses `Image(systemName: \"exclamationmark.circle\")` with no accessibility label to give the error icon alt text. `.accessibilityElement(children: .combine)` is not used on the `HStack` to combine the image and text into a single focusable element with VoiceOver.")
                    }
                }.padding(.bottom)
                Text("Bad Example `Label` combined with `Text`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                HStack {
                    Label("", systemImage: "exclamationmark.circle").labelStyle(IconOnlyLabelStyle())
                    Text("We're sorry. We can't show the offer details right now.").bold().font(.callout)
                }
                .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                DisclosureGroup("Details") {
                    VStack {
                        Text("The bad `Label` combined with `Text` example uses `Label(\"\", systemImage: \"exclamationmark.circle\").labelStyle(IconOnlyLabelStyle())` which does not give the icon an accessibility `Label` that is not displayed visually. The `HStack` is not combined into a single focusable element using `.accessibilityElement(children: .combine)` and `.accessibilityRemoveTraits(.isImage)` is not used on the `Label` icon image so that the accessibility label is spoken to VoiceOver when combined with the text.")
                    }
                }.padding(.bottom)
            }
            .padding()
            .navigationTitle("Informative Images")
        }
     }
}
 
struct InformativeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            InformativeView()
        }
    }
}


