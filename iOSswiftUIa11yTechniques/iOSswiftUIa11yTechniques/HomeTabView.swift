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

struct HomeTabView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // Header
                Text("Welcome to Horizon")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Your personal hub for staying connected, organized, and inspired. Whether you’re planning your week, sharing moments with friends, or discovering something new, Horizon keeps everything just a tap away.")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Divider()
                
                // Quick Actions
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Actions")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Label("Create a Note – Capture thoughts before they slip away.", systemImage: "square.and.pencil")
                    Label("Start a Call – Reach your contacts instantly.", systemImage: "phone")
                    Label("Explore Nearby – Find events, shops, and experiences close to you.", systemImage: "mappin.and.ellipse")
                }
                
                Divider()
                
                // Today’s Highlights
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today’s Highlights")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Your calendar is clear this morning. Perfect time to tackle those personal goals you’ve been putting off. Later, don’t forget your dinner reservation at The Oakroom—we’ll send you a reminder an hour before.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Tips & Tricks
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tips & Tricks")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("• Swipe left on cards to reveal quick actions.\n• Use voice commands to add events or send messages hands-free.\n• Pin your most-used tools to the top of your dashboard.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
    }
}

struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView()
    }
}
