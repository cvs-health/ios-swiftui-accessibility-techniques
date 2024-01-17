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

struct A11yEnhancementsView: View {

    var body: some View {
        List {
            Text("Accessibility User Experience enhancements can provide a more usable experience for VoiceOver, Voice Control, and Large Text users.")
            NavigationLink(destination: ATdetectionView()) {
                Text("Assistive Technology Detection")
            }
            NavigationLink(destination: MagicTapView()) {
                Text("Magic Tap")
            }
            NavigationLink(destination: DetailView()) {
                Text("Escape")
            }.disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
            NavigationLink(destination: AdjustableActionView()) {
                Text("Adjustable Action")
            }
            NavigationLink(destination: InputLabelsView()) {
                Text("Input Labels")
            }
            NavigationLink(destination: DetailView()) {
                Text("Large Content Viewer") // link https://nilcoalescing.com/blog/LargeContentViewerInSwiftUI/
            }.disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
            NavigationLink(destination: DetailView()) {
                Text("Attributed Strings")
            }.disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
            NavigationLink(destination: VoiceOverPronunciationView()) {
                Text("VoiceOver Proununciation")
            }
        }
        .navigationBarTitle("Accessibility UX Enhancements")
    }
}

struct A11yEnhancementsView_Previews: PreviewProvider {
    static var previews: some View {
        A11yEnhancementsView()
    }
}
