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

struct ContactFormView: View {

    var body: some View {
        List {
            Text("Tap on the office below to send a question or comment.")
            NavigationLink(destination: ContactAustin()) {
                Text("Austin")
            }
            NavigationLink(destination: ContactSeattle()) {
                Text("Seattle")
            }
            NavigationLink(destination: ContactAtlanta()) {
                Text("Atlanta")
            }
            NavigationLink(destination: ContactReno()) {
                Text("Reno")
            }
            NavigationLink(destination: ContactBoston()) {
                Text("Boston")
            }
            NavigationLink(destination: ContactOrlando()) {
                Text("Orlando")
            }
        }
        .navigationTitle("Contact Our Offices")
    }
}

struct ContactFormView_Previews: PreviewProvider {
    static var previews: some View {
        ContactFormView()
    }
}
