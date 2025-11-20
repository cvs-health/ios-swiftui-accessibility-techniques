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

struct ContainersViewGood: View {

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



struct ContainersView: View {
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Containers can group sections of a page with meaningful accessible names. VoiceOver users can jump between each container using the Rotor. Containers can group related controls like radio buttons or mimic the behavior of ARIA Landmarks. The container name is spoken to VoiceOver when focus is first placed on an element inside the group. Use `.accessibilityElement(children: .contain)` on the group container element and `.accessibilityLabel` to give the group a meaningful label for VoiceOver users.")
                    .padding(.bottom)
                Text("Good Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                NavigationLink("Containers Good Example", destination: ContainersViewGood())
                DisclosureGroup("Details") {
                    Text("The good example uses `.accessibilityElement(children: .contain)` and `.accessibilityLabel` to mimic the behavior of ARIA Landmarks. There are containers labeled \"Main content\", \"Header\", and \"Footer\".")
                }.padding(.bottom).accessibilityHint("Good Example")
            }
            .navigationTitle("Containers")
            .padding()
        }
 
    }
}


#Preview {
    NavigationStack {
        ContainersView()
    }
}
