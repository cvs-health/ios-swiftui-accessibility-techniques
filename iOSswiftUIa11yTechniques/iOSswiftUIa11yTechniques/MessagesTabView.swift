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

struct MessagesTabView: View {
    @State private var messages: [Message] = [
        Message(id: 1, sender: "Alex Morgan", preview: "Hey, did you see the update on the project?", time: "2:15 PM"),
        Message(id: 2, sender: "Jamie Rivera", preview: "Dinner tonight? I found a new place.", time: "1:03 PM"),
        Message(id: 3, sender: "Taylor Chen", preview: "The photos from the weekend are ready!", time: "Yesterday"),
        Message(id: 4, sender: "Sam Patel", preview: "Reminder: Meeting at 9:30 tomorrow.", time: "Yesterday"),
        Message(id: 5, sender: "Jordan Lee", preview: "Flight’s booked! ✈️", time: "Monday"),
        Message(id: 6, sender: "Riley Adams", preview: "Can you send me that link again?", time: "Monday"),
        Message(id: 7, sender: "Morgan Diaz", preview: "Almost done with the report—should I email it or upload?", time: "Sunday"),
        Message(id: 8, sender: "Casey Brooks", preview: "Got your postcard! It made my day.", time: "Sunday"),
        Message(id: 9, sender: "Drew Kim", preview: "Traffic is a nightmare right now.", time: "Saturday"),
        Message(id: 10, sender: "Chris Nolan", preview: "Movie night this week? I’ve got a new projector.", time: "Saturday")
    ]
    
    var body: some View {
        List(messages) { message in
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.sender)
                        .font(.headline)
                    Text(message.preview)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

struct Message: Identifiable {
    let id: Int
    let sender: String
    let preview: String
    let time: String
}

#Preview {
    MessagesTabView()
}
