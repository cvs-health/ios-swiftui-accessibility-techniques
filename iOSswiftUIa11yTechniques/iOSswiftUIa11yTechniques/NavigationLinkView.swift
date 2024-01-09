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
 
struct NavigationLinkView: View {
    @State private var isFullScreen = false
    @State private var isFullScreenBad = false

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Use a `NavigationLink` to navigate users between different pages in the app. When using `NavigationLink` VoiceOver focus does not need to be managed when opening the page. VoiceOver focus will not go to the first element at the top of the new page, it may go to the first element below the page title. Apple chooses how to handle focus managment when using a `NavigationLink` and you should not worry about setting VoiceOver focus to the back button or page title.")
                    .padding([.bottom])
                Text("Good Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                NavigationLink(destination: PageTitleGood()) {
                    Text("Navigation Good Example")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue)).frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The good navigation example uses `NavigationLink` to create a button that opens a new page inside the app.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                Text("Bad Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                Text("Bad Example 1")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                ZStack {
                   Button(action: {
                       self.isFullScreenBad.toggle()
                   }, label: {
                       Text("Navigation Bad Example 1")
                   })
                   .padding().frame(maxWidth: .infinity, alignment: .leading)
                   if isFullScreenBad {
                       Color(colorScheme == .dark ? .black : .white)
                          .edgesIgnoringSafeArea(.all)
                       VStack {
                           Text("Back")
                               .onTapGesture {
                                   self.isFullScreenBad = false
                               }
                               .frame(maxWidth: .infinity, alignment: .leading)
                           Text("About the Company")
                               .font(.largeTitle)
                               .fontWeight(.bold)
                               .frame(maxWidth: .infinity, alignment: .leading)
                               .accessibilityAddTraits(.isHeader)
                           Text("Our company was founded in 1992. We sell widgets and gadgets. We give back 10% of all profits to the fight to eliminate plastics from the ocean. All products we sell have a lifetime warranty. Money-back guarantee if you're not satisfied we'll give you a full refund. This page has a title at the top and is clearly fake.")
                       }.padding()
                          .onTapGesture {
                              self.isFullScreenBad = false
                          }
                   }
               }
                DisclosureGroup("Details") {
                    Text("The first bad navigation example uses `Text` with an `.onTapGesture` to open a custom view.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                Text("Bad Example 2")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                ZStack{
                    Text("Navigation Bad Example 2")
                        .padding().frame(maxWidth: .infinity, alignment: .leading)
                        .fullScreenCover(isPresented: $isFullScreen) {
                            FullScreen(isFullScreen: $isFullScreen)
                        }
                        .onTapGesture {
                            isFullScreen.toggle()
                        }
                }
                    DisclosureGroup("Details") {
                        Text("The second bad navigation example uses `Text` with an `.onTapGesture` to open a fullscreen view.")
                    }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
                }
                .padding()
                .navigationTitle("Navigation")
            }
            
        }
    }
    
    struct NavigationLinkView_Previews: PreviewProvider {
        static var previews: some View {
            NavigationLinkView()
        }
    }
    
    
    struct FullScreen: View {
        @Binding var isFullScreen: Bool
        
        var body: some View {
            VStack {
                Text("Back")
                    .onTapGesture {
                        self.isFullScreen.toggle()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("About the Company")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Text("Our company was founded in 1992. We sell widgets and gadgets. We give back 10% of all profits to the fight to eliminate plastics from the ocean. All products we sell have a lifetime warranty. Money-back guarantee if you're not satisfied we'll give you a full refund. This page has a title at the top and is clearly fake.")
            }.padding()
        }
    }

