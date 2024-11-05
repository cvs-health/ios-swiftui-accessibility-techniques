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

struct DragDropView: View {
    @State private var selection: String?

    var names = [
        "Cyril",
        "Lana",
        "Mallory",
        "Sterling"
    ]

   
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            List(names, id: \.self, selection: $selection) { name in
                Text(name)
            }
            .navigationTitle("Countries")
            if (selection != nil) {
                HStack {
                    Button("Up", action: {
                        
                    })
                    Button("Down", action: {
                        
                    })
                }
            }
        }
    }
    
}

 
struct DragDropView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DragDropView()
        }
    }
}
