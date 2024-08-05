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

struct Prototype4: View {
    
    var body: some View {
        List {
            NavigationLink(destination: PrototypeHeadings1()) {
                Text("Page 1")
            }
            NavigationLink(destination: PrototypeHeadings2()) {
                Text("Page 2")
            }
            NavigationLink(destination: PrototypeHeadings3()) {
                Text("Page 3")
            }
        }
        .navigationTitle("Prototype 4")
    }
}

 
struct Prototype4_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            Prototype4()
        }
    }
}
