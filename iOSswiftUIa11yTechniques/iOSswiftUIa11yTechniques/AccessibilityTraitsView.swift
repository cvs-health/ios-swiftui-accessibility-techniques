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

import SwiftUI

struct AccessibilityTraitsView: View {
    let traits: [(name: String, trait: AccessibilityTraits, iOSAvailable: Double)] = [
        ("Button", .isButton, 0),
        ("Header", .isHeader, 0),
        ("Selected", .isSelected, 0),
        ("Link", .isLink, 0),
        ("Search Field", .isSearchField, 0),
        ("Image", .isImage, 0),
        ("Plays Sound", .playsSound, 0),
        ("Keyboard Key", .isKeyboardKey, 0),
        ("Static Text", .isStaticText, 0),
        ("Summary Element", .isSummaryElement, 0),
        ("Updates Frequently", .updatesFrequently, 0),
        ("Starts Media Session", .startsMediaSession, 0),
        ("Allows Direct Interaction", .allowsDirectInteraction, 0),
        ("Causes Page Turn", .causesPageTurn, 0),
        //("Modal", .isModal, 0), //will trap the focus
        ("Toggle", {
            if #available(iOS 17, *) { return .isToggle }
            else { return .isButton } // fallback
        }(), 17),
        ("Tab Bar", {
            if #available(iOS 17, *) { return .isTabBar }
            else { return .isButton } // fallback
        }(), 17)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
               
                ForEach(traits, id: \.name) { item in
                    Text(item.name)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(itemAvailable(item) ? Color.blue.opacity(0.3) : Color.gray.opacity(0.3))
                        .cornerRadius(8)
                        .accessibilityAddTraits(item.trait)
                }
            }
            .padding()
        }
    }
    
    private func itemAvailable(_ item: (name: String, trait: AccessibilityTraits, iOSAvailable: Double)) -> Bool {
        if #available(iOS 17, *) { return true }
        return item.iOSAvailable <= 16.9
    }
}

#Preview {
    NavigationStack {
        AccessibilityTraitsView()
    }
}
