/*
   Copyright 2025 CVS Health and/or one of its affiliates

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

struct ContainersView: View {

    var body: some View {
        VStack {
            VStack(spacing: 0) {
                
                // Banner / Header Landmark with Buttons
                VStack(spacing: 8) {
                    HStack {
                        // Leading button
                        Button {
                            print("Menu tapped")
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .font(.title2)
                        }
                        .accessibilityLabel("Open menu")
                        
                        Spacer()
                        
                        // App title
                        Text("MyApp")
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer()
                        
                        // Trailing buttons
                        HStack(spacing: 16) {
                            Button {
                                print("Search tapped")
                            } label: {
                                Image(systemName: "magnifyingglass")
                                    .font(.title2)
                            }
                            .accessibilityLabel("Search")
                            
                            Button {
                                print("Profile tapped")
                            } label: {
                                Image(systemName: "person.crop.circle")
                                    .font(.title2)
                            }
                            .accessibilityLabel("Profile")
                        }
                    }
                    .padding(.horizontal)
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.blue) // solid blue for high contrast
                .foregroundColor(.white)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Header")
                .accessibilityAddTraits(.isHeader)
                
                Divider()
                
                // Main Landmark
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Welcome back, Alex!")
                            .font(.title2)
                            .bold()
                        
                        Text("Here’s what’s new today:")
                            .font(.headline)
                        
                        ForEach(1..<4) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Update \(item)")
                                    .font(.headline)
                                Text("This is a summary of update \(item), with more details available.")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemGray6))
                            )
                            .accessibilityElement(children: .combine)
                        }
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Main content")
                    .padding()
                }
                
                Divider()
                
                // ContentInfo / Footer Landmark
                HStack {
                    Text("© 2025 MyApp, Inc.")
                    Spacer()
                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                }
                .font(.footnote)
                .padding()
                .background(Color(.systemGray6))
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Footer")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        //.navigationBarHidden(true) // hides the automatic navigation title bar

    }
}

#Preview {
    NavigationStack {
        ContainersView()
    }
}
