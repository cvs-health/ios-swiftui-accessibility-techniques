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

struct ImagesView: View {

    var body: some View {
        List {
            Text("Images can be either informative, decorative, or functional. Informative and functional images need accessibility labels. Decorative images need to be hidden from VoiceOver.")
            NavigationLink(destination: InformativeView()) {
                Text("Informative Images")
            }
            NavigationLink(destination: DecorativeView()) {
                Text("Decorative Images")
            }
            NavigationLink(destination: FunctionalView()) {
                Text("Functional Images")
            }
        }
        .navigationBarTitle("Images")
    }
}

struct ImagesView_Previews: PreviewProvider {
    static var previews: some View {
        ImagesView()
    }
}
