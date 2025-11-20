/*
   Copyright 2025 CVS Health and/or one of its affiliates

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

struct InformativeImagesWatch: View {
    
    let darkBlue = Color(red: 26/255, green: 115/255, blue: 206/255)
    
    var body: some View {
        ScrollView {
            Text("Give informative images accessibility labels using `Label(\"text\")` or `.accessibilityLabel(\"text\")`. Use `.accessibilityElement(children: .combine)` to combine an image and text into a single element.")
            Text("Good Examples")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h2)
                .foregroundColor(.green)
            Divider()
                .frame(height: 2.0, alignment: .leading)
                .background(.green)
                .padding(.bottom)
            Text("`.accessibilityLabel`")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
            Image("get10off")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .accessibilityLabel("Get 10% off")
                .accessibilityIdentifier("goodImage")
            NavigationLink(destination: DetailInformativeGood()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint(".accessibilityLabel")
                .buttonStyle(.plain)
                .padding(.bottom)
            Text("`Label(\"Text\")` `.accessibilityElement(children: .combine)`")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
            HStack {
                Text("Hello,")
                Label("World", systemImage: "globe").labelStyle(IconOnlyLabelStyle()).accessibilityRemoveTraits(.isImage)
                    .accessibilityIdentifier("goodIcon")
                Text("!")
            }.accessibilityElement(children: .combine)
                .padding()
            NavigationLink(destination: DetailInformativeGood2()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("Label(\"Text\")` `.accessibilityElement(children: .combine)")
                .buttonStyle(.plain)
                .padding(.bottom)
            Text("Bad Examples")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h2)
                .foregroundColor(.red)
            Divider()
                .frame(height: 2.0, alignment: .leading)
                .background(.red)
                .padding(.bottom)
            Text("No `.accessibilityLabel`")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
            Image("get10off")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .accessibilityIdentifier("badImage")
            NavigationLink(destination: DetailInformativeBad()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("No .accessibilityLabel")
                .buttonStyle(.plain)
                .padding(.bottom)
            Text("No `Label(\"Text\")` or `.accessibilityElement(children: .combine)`")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
            HStack {
                Text("Hello,")
                Label("", systemImage: "globe").labelStyle(IconOnlyLabelStyle())
                Text("!")
            }
                .padding()
            NavigationLink(destination: DetailInformativeBad2()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("No Label(\"Text\")` or `.accessibilityElement(children: .combine)")
                .buttonStyle(.plain)

        }
    }
}

struct DetailInformativeGood: View {
    var body: some View {
        ScrollView {
            Text("The good informative image example uses `.accessibilityLabel(\"Get 10% off\")` to give it an accessibility label that matches the visible text shown in the image.")
        }
            .navigationTitle("`.accessibilityLabel`")
    }
}
struct DetailInformativeGood2: View {
    var body: some View {
        ScrollView {
            Text("The good informative icon image example uses `Label(\"World\", systemImage: \"globe\").labelStyle(IconOnlyLabelStyle())` to give the informative icon an accessibility label that is not displayed visually. Additionally `.accessibilityRemoveTraits(.isImage)` must be used on the icon image so that the accessibility label is spoken to VoiceOver when the `HStack` is combined into a single focusable element using `.accessibilityElement(children: .combine)`.")

        }
            .navigationTitle("`Label(\"Text\")` `.accessibilityElement(children: .combine)`")
    }
}
struct DetailInformativeBad: View {
    var body: some View {
        ScrollView {
            Text("The bad informative image example uses no `.accessibilityLabel` for the image causing VoiceOver to read the image filename* which is not meaningful. *Disable VoiceOver Text Recognition")
        }
            .navigationTitle("No `.accessibilityLabel`")
    }
}
struct DetailInformativeBad2: View {
    var body: some View {
        ScrollView {
            Text("The bad informative icon image example uses no `Label` text to give the informative icon an accessibility label causing VoiceOver to read the image as \"Globe, Image\". VoiceOver focuses on each individual part of the line of text because the `HStack` is not combined into one focusable element.")
        }
            .navigationTitle("No `Label(\"Text\")` or `.accessibilityElement(children: .combine)`")
    }
}


#Preview {
    NavigationStack {
        InformativeImagesWatch()
    }
}
