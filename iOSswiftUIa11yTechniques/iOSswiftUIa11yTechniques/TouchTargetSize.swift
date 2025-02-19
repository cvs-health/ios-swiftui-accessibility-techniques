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
 
struct TouchTargetSize: View {
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isMuted = false
    
    var body: some View {
        ScrollView {
            VStack {
                Text("WCAG 2.2 requires a minimum touch target size (or spacing) of at least 24 by 24. Inline targets (within a line of text) are exempt from the minimum target size requirements. Use `.frame(minWidth: 24, minHeight: 24)` on icon button `Image` elements to ensure the 24 by 24 target minimum is met.")
                    .padding(.bottom)
                Text("Good Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                HStack {
                    Button(action: {
                        self.isMuted.toggle()
                    }) {
                        Image(systemName: self.isMuted ? "speaker.slash.fill" : "speaker.2.fill").frame(minWidth: 24, minHeight: 24)
                    }
                    .accessibilityLabel("Mute")
                    .accessibilityAddTraits(.isToggle)
                    .accessibility(addTraits: isMuted ? [.isSelected] : [])
                    .accessibility(removeTraits: isMuted ? [] : [.isSelected])
                    Button(action: {
                    }) {
                        Image(systemName: "play.fill").frame(minWidth: 24, minHeight: 24)
                    }
                    .accessibilityLabel("Play")
                    .accessibilityAddTraits(.startsMediaSession)
                   Button(action: {
                       print("First button tapped")
                   }) {
                       Image(systemName: "pencil").frame(minWidth: 24, minHeight: 24)
                   }.accessibilityLabel("Edit")
                   Button(action: {
                       print("Second button tapped")
                   }) {
                       Image(systemName: "trash").frame(minWidth: 24, minHeight: 24)
                   }.accessibilityLabel("Delete")
                   Button(action: {
                       print("Third button tapped")
                   }) {
                       Image(systemName: "plus").frame(minWidth: 24, minHeight: 24)
                   }.accessibilityLabel("Add")
                   Button(action: {
                       print("Fourth button tapped")
                   }) {
                       Image(systemName: "minus").frame(minWidth: 24, minHeight: 24)
                   }.accessibilityLabel("Remove")
                    Spacer()
                    Button(action: {
                        print("Fourth button tapped")
                    }) {
                        Image(systemName: "divide").frame(width:18, height:18)
                    }.accessibilityLabel("Divide")
                    Spacer()
                    Button(action: {
                        print("Fourth button tapped")
                    }) {
                        Image(systemName: "multiply").frame(width:18, height:18)
                    }.accessibilityLabel("Multiply")
                }.frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The good touch target size example uses `.frame(minWidth: 24, minHeight: 24)` on each icon button `Image`. The last 2 icon buttons in the example have target size below 24 by 24 but have additional spacing that adds up to greater than 24 by 24. Xcode Accessibility Inspector will fail those last 2 buttons as false positives.")
                }.padding(.bottom).accessibilityHint("Good Example")
                Text("Bad Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                HStack {
                   Button(action: {
                       print("First button tapped")
                   }) {
                       Image(systemName: "pencil").frame(width:18, height:18)
                   }
                   Button(action: {
                       print("Second button tapped")
                   }) {
                       Image(systemName: "trash").frame(width:18, height:18)
                   }
                   Button(action: {
                       print("Third button tapped")
                   }) {
                       Image(systemName: "plus").frame(width:18, height:18)
                   }
                   Button(action: {
                       print("Fourth button tapped")
                   }) {
                       Image(systemName: "minus").frame(width:18, height:18)
                   }
                }.frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The bad touch target size example uses `.frame(width:18, height:18)` on each icon button `Image`.")
                }.padding(.bottom).accessibilityHint("Bad Example")
            }
            .navigationTitle("Touch Target Size")
            .padding()
        }
 
    }
}
 
struct TouchTargetSize_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TouchTargetSize()
        }
    }
}
