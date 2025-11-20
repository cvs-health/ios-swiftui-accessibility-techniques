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

struct DecorativeImagesWatch: View {

    let darkBlue = Color(red: 26/255, green: 115/255, blue: 206/255)

    var body: some View {
        ScrollView {
            Text("Decorative images are used purely for decoration and convey no meaning to sighted users. Decorative images must be hidden from VoiceOver users. Use `Image(decorative:)` or `.accessibilityHidden(true)` to hide decorative images from VoiceOver.")
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
            Text("`Image(decorative:)`")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
            Image(decorative: "newspaper")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .accessibilityIdentifier("goodImage")
            Text("Discover new offers every week and earn extra savings.")
            NavigationLink(destination: DetailDecorativeGood()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("Image(decorative:)")
                .buttonStyle(.plain)
                .padding(.bottom)
            Text("`.accessibilityHidden(true)`")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
                .accessibilityHidden(true)
                .accessibilityIdentifier("goodIcon")
            Text("Hello, world!")
            NavigationLink(destination: DetailDecorativeGood2()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint(".accessibilityHidden(true)")
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
            Text("`No Image(decorative:)`")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
            Image("newspaper")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .accessibilityIdentifier("badImage")
            Text("Discover new offers every week and earn extra savings.")
            NavigationLink(destination: DetailDecorativeBad()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("No Image(decorative:)")
                .buttonStyle(.plain)
                .padding(.bottom)
            Text("No `.accessibilityHidden(true)`")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
                .accessibilityIdentifier("badIcon")
            Text("Hello, world!")
            NavigationLink(destination: DetailDecorativeBad2()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("No .accessibilityHidden(true)")
                .buttonStyle(.plain)
        }
    }
}

struct DetailDecorativeGood: View {
    var body: some View {
        ScrollView {
            Text("The good decorative image example uses `Image(decorative: \"newspaper\")` which prevents VoiceOver from focusing on the image.")
        }
            .navigationTitle("`Image(decorative:)`")
    }
}
struct DetailDecorativeGood2: View {
    var body: some View {
        ScrollView {
            Text("The good decorative icon image example uses `.accessibilityHidden(true)` which prevents VoiceOver from focusing on the icon.")
        }
            .navigationTitle("`.accessibilityHidden(true)`")
    }
}
struct DetailDecorativeBad: View {
    var body: some View {
        ScrollView {
            Text("The bad decorative image example does not use the `decorative:` parameter which allows VoiceOver to focus on the image and read \"newspaper\" as its accessibility label.")
        }
        .navigationTitle("No `Image(decorative:)`")
    }
}
struct DetailDecorativeBad2: View {
    var body: some View {
        ScrollView {
            Text("The bad decorative icon image example does not use `.accessibilityHidden(true)` which allows VoiceOver to focus on the image and read \"globe\" as its accessibility label.")
        }
        .navigationTitle("No `.accessibilityHidden(true)`")
    }
}

#Preview {
    NavigationStack {
        DecorativeImagesWatch()
    }
}
