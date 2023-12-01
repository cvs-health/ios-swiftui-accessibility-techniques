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
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
            NavigationLink(destination: DetailView()) {
                Text("Magic Tap")
            }
            NavigationLink(destination: DetailView()) {
                Text("Escape")
            }
            NavigationLink(destination: DetailView()) {
                Text("Custom Actions")
            }
            NavigationLink(destination: DetailView()) {
                Text("User Input Labels")
            }
            NavigationLink(destination: DetailView()) {
                Text("Large Content Viewer") // link https://nilcoalescing.com/blog/LargeContentViewerInSwiftUI/
            }
            NavigationLink(destination: DetailView()) {
                Text("Attributed Strings and VoiceOver Proununciation")
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
