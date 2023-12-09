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

struct AnnouncementsView: View {

    var body: some View {
        List {
            Text("Messages can be spoken to VoiceOver users either by setting their focus to an element or using `AccessibilityNotification.Announcement` to speak a messsage without moving focus. The Error Validation example uses `AccessibilityFocusState` to move VoiceOver focus.")
            NavigationLink(destination: AccessibilityNotificationsView()) {
                Text("Accessibility Notifications")
            }
            NavigationLink(destination: ErrorValidationView()) {
                Text("Error Validation")
            }
        }
        .navigationBarTitle("Announcements")
    }
}

struct AnnouncementsView_Previews: PreviewProvider {
    static var previews: some View {
        AnnouncementsView()
    }
}
