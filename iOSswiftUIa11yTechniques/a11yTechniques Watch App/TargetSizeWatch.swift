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

struct TargetSizeWatch: View {
    
    let darkBlue = Color(red: 26/255, green: 115/255, blue: 206/255)
    @State private var isMuted = false

    var body: some View {
        ScrollView {
            Text("WCAG 2.2 requires a minimum touch target size (or spacing) of at least 24 by 24. Inline targets (within a line of text) are exempt from the minimum target size requirements. Use `.frame(minWidth: 24, minHeight: 24)` on icon button `Image` elements to ensure the 24 by 24 target minimum is met.")
            Text("Good Example")
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
            HStack {
               Button(action: {
                   print("First button tapped")
               }) {
                   Image(systemName: "pencil")
                       .resizable()
                       .aspectRatio(contentMode: .fit)
                       .frame(width:24, height:24)
               }.buttonStyle(.plain)
               Button(action: {
                   print("Second button tapped")
               }) {
                   Image(systemName: "trash")
                       .resizable()
                       .aspectRatio(contentMode: .fit)
                       .frame(width:24, height:24)
               }.buttonStyle(.plain)
                Spacer()
               Button(action: {
                   print("Third button tapped")
               }) {
                   Image(systemName: "plus")
                       .resizable()
                       .aspectRatio(contentMode: .fit)
                       .frame(width:18, height:18)
               }.buttonStyle(.plain)
                Spacer()
               Button(action: {
                   print("Fourth button tapped")
               }) {
                   Image(systemName: "multiply")
                       .resizable()
                       .aspectRatio(contentMode: .fit)
                       .frame(width:18, height:18)
               }.buttonStyle(.plain)
            }.frame(maxWidth: .infinity, alignment: .leading)

            NavigationLink(destination: DetailTargetSizeGood()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("Good Example")
                .buttonStyle(.plain)
                .padding(.bottom)
            Text("Bad Example")
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
            HStack {
               Button(action: {
                   print("First button tapped")
               }) {
                   Image(systemName: "pencil")
                       .resizable()
                       .aspectRatio(contentMode: .fit)
                       .frame(width:18, height:18)
               }.buttonStyle(.plain)
               Button(action: {
                   print("Second button tapped")
               }) {
                   Image(systemName: "trash")
                       .resizable()
                       .aspectRatio(contentMode: .fit)
                       .frame(width:18, height:18)
               }.buttonStyle(.plain)
               Button(action: {
                   print("Third button tapped")
               }) {
                   Image(systemName: "plus")
                       .resizable()
                       .aspectRatio(contentMode: .fit)
                       .frame(width:18, height:18)
               }.buttonStyle(.plain)
               Button(action: {
                   print("Fourth button tapped")
               }) {
                   Image(systemName: "multiply")
                       .resizable()
                       .aspectRatio(contentMode: .fit)
                       .frame(width:18, height:18)
               }.buttonStyle(.plain)
            }.frame(maxWidth: .infinity, alignment: .leading)
            NavigationLink(destination: DetailTargetSizeBad()) {
                Text("Details")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(darkBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .accessibilityHint("Bad Example")
                .buttonStyle(.plain)
                .padding(.bottom)
        }
    }
}

struct DetailTargetSizeGood: View {
    var body: some View {
        ScrollView {
            Text("The good touch target size example uses `.frame(minWidth: 24, minHeight: 24)` on each icon button `Image`. The last 2 icon buttons in the example have target size below 24 by 24 but have additional spacing that adds up to greater than 24 by 24. Xcode Accessibility Inspector will fail those last 2 buttons as false positives.")
        }
            .navigationTitle("`Good Example`")
    }
}
struct DetailTargetSizeBad: View {
    var body: some View {
        ScrollView {
            Text("The bad touch target size example uses `.frame(width:18, height:18)` on each icon button `Image`.")
        }
            .navigationTitle("Bad Example")
    }
}


#Preview {
    NavigationStack {
        TargetSizeWatch()
    }
}
