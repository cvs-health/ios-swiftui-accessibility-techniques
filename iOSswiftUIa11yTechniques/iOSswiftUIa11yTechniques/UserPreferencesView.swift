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

struct UserPreferencesView: View {

    var body: some View {
        List {
            Text("Your app should respond to the user's accessibility preferences by adjusting the design to be usable and accessible when a different display mode or accessibility setting is enabled.")
            NavigationLink(destination: DarkModeView()) {
                Text("Dark Mode")
            }
            NavigationLink(destination: IncreaseContrastView()) {
                Text("Increase Contrast")
            }
            NavigationLink(destination: ReduceMotionView()) {
                Text("Reduce Motion")
            }
            NavigationLink(destination: ReduceTransparencyView()) {
                Text("Reduce Transparency")
            }
            NavigationLink(destination: SmartInvertView()) {
                Text("Smart Invert")
            }
        }
        .navigationTitle("User Accessibility Preferences")
    }
}

struct UserPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        UserPreferencesView()
    }
}
