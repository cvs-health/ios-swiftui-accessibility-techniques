/*
   Copyright 2024 CVS Health and/or one of its affiliates

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

struct PrototypesView: View {

    var body: some View {
        List {
            NavigationLink(destination: Prototype1()) {
                Text("Prototype 1")
            }
            NavigationLink(destination: Prototype2()) {
                Text("Prototype 2")
            }
            NavigationLink(destination: Prototype3()) {
                Text("Prototype 3")
            }
            NavigationLink(destination: Prototype4()) {
                Text("Prototype 4")
            }
        }
        .navigationTitle("Prototypes")
    }
}

struct PrototypesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PrototypesView()
        }
    }
}