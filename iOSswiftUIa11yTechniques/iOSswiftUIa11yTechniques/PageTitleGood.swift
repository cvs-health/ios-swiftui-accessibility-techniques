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
 
struct PageTitleGood: View {

    var body: some View {
        ScrollView {
            VStack {
                Text("Our company was founded in 1992. We sell widgets and gadgets. We give back 10% of all profits to the fight to eliminate plastics from the ocean. All products we sell have a lifetime warranty. Money-back guarantee if you're not satisfied we'll give you a full refund. This page has a title at the top and is clearly fake.")
            }
            .padding()
            .navigationTitle("About the Company")
        }
 
    }
}
 
struct PageTitleGood_Previews: PreviewProvider {
    static var previews: some View {
        PageTitleGood()
    }
}
