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

struct VoiceOverAnnouncementDelayView: View {
    @State private var milkRemoved = false
    @State private var eggsRemoved = false
    @State private var breadRemoved = false
    @State private var items = 3
    @State private var milkPrice: Int = 5
    @State private var breadPrice: Int = 4
    @State private var eggsPrice: Int = 6
    @State private var milkRemovedBad = false
    @State private var eggsRemovedBad = false
    @State private var breadRemovedBad = false
    @State private var itemsBad = 3
    @State private var milkPriceBad: Int = 5
    @State private var breadPriceBad: Int = 4
    @State private var eggsPriceBad: Int = 6
    @State private var cartMessageGoodVisible = false
    @State private var cartMessageBadVisible = false
    @AccessibilityFocusState private var isMessageFocused: Bool
    @AccessibilityFocusState private var isMessageBadFocused: Bool


    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("VoiceOver announcements may need to be spoken with a delay if focus also moves at the same time. Use e.g., `DispatchQueue.main.asyncAfter(deadline: .now() + 3) { AccessibilityNotification.Announcement(\"Announcement text\").post() }` to speak an announcement after a 3 second delay.")
                    .padding([.bottom])
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
                VStack {
                    Text("^[\(items) item](inflect: true) in cart")
                        .accessibilityFocused($isMessageFocused)
                    if (!milkRemoved) {
                        HStack {
                            Text("Milk")
                            Text("$\(milkPrice)")
                            Spacer()
                            Button(action: {
                                cartMessageGoodVisible = true
                                isMessageFocused = true
                                items -= 1
                                milkPrice = 0
                                milkRemoved = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    AccessibilityNotification.Announcement("Cart Total: $\(eggsPrice + breadPrice + milkPrice)").post()
                                }
                            }) {
                                Text("Remove")
                            }.accessibilityLabel("Remove Milk")
                        }.padding(5).frame(maxWidth: .infinity, alignment: .leading)
                    }
                    if (!eggsRemoved) {
                        HStack {
                            Text("Eggs")
                            Text("$\(eggsPrice)")
                            Spacer()
                            Button(action: {
                                cartMessageGoodVisible = true
                                isMessageFocused = true
                                items -= 1
                                eggsPrice = 0
                                eggsRemoved = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    AccessibilityNotification.Announcement("Cart Total: $\(eggsPrice + breadPrice + milkPrice)").post()
                                }
                            }) {
                                Text("Remove")
                            }.accessibilityLabel("Remove Eggs")
                        }.padding(5).frame(maxWidth: .infinity, alignment: .leading)
                    }
                    if (!breadRemoved) {
                        HStack {
                            Text("Bread")
                            Text("$\(breadPrice)")
                            Spacer()
                            Button(action: {
                                cartMessageGoodVisible = true
                                isMessageFocused = true
                                items -= 1
                                breadPrice = 0
                                breadRemoved = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    AccessibilityNotification.Announcement("Cart Total: $\(eggsPrice + breadPrice + milkPrice)").post()
                                }
                            }) {
                                Text("Remove")
                            }.accessibilityLabel("Remove Bread")
                        }.padding(5).frame(maxWidth: .infinity, alignment: .leading)
                    }
                    if cartMessageGoodVisible {
                        Text("Cart Total: $\(eggsPrice + breadPrice + milkPrice)")
                    }
                }
                DisclosureGroup("Details") {
                    Text("The good example uses `DispatchQueue.main.asyncAfter(deadline: .now() + 3) { AccessibilityNotification.Announcement().post() }` to speak an announcement after a 3 second delay so that focus management does not interrupt the announcement.")
                }.padding([.bottom]).accessibilityHint("Good Example")
                Text("Bad Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                VStack {
                    Text("\(itemsBad) items in cart")
                        .accessibilityFocused($isMessageBadFocused)
                    if (!milkRemovedBad) {
                        HStack {
                            Text("Milk")
                            Text("$\(milkPriceBad)")
                            Spacer()
                            Button(action: {
                                cartMessageBadVisible = true
                                isMessageBadFocused = true
                                itemsBad -= 1
                                milkPriceBad = 0
                                milkRemovedBad = true
                                AccessibilityNotification.Announcement("Cart Total: $\(eggsPriceBad + breadPriceBad + milkPriceBad)").post()
                            }) {
                                Text("Remove")
                            }
                        }.padding(5).frame(maxWidth: .infinity, alignment: .leading)
                    }
                    if (!eggsRemovedBad) {
                        HStack {
                            Text("Eggs")
                            Text("$\(eggsPriceBad)")
                            Spacer()
                            Button(action: {
                                cartMessageBadVisible = true
                                isMessageBadFocused = true
                                itemsBad -= 1
                                eggsPriceBad = 0
                                eggsRemovedBad = true
                                AccessibilityNotification.Announcement("Cart Total: $\(eggsPriceBad + breadPriceBad + milkPriceBad)").post()
                            }) {
                                Text("Remove")
                            }
                        }.padding(5).frame(maxWidth: .infinity, alignment: .leading)
                    }
                    if (!breadRemovedBad) {
                        HStack {
                            Text("Bread")
                            Text("$\(breadPriceBad)")
                            Spacer()
                            Button(action: {
                                cartMessageBadVisible = true
                                isMessageBadFocused = true
                                itemsBad -= 1
                                breadPriceBad = 0
                                breadRemovedBad = true
                                AccessibilityNotification.Announcement("Cart Total: $\(eggsPriceBad + breadPriceBad + milkPriceBad)").post()
                            }) {
                                Text("Remove")
                            }
                        }.padding(5).frame(maxWidth: .infinity, alignment: .leading)
                    }
                    if cartMessageBadVisible {
                        Text("Cart Total: $\(eggsPriceBad + breadPriceBad + milkPriceBad)")
                    }
                }
                DisclosureGroup("Details") {
                    Text("The bad example uses `AccessibilityNotification.Announcement().post()` to speak an announcement without a delay which causes focus management to interrupt the announcement.")
                }.accessibilityHint("Bad Example")
            }
            .padding()
            .navigationTitle("VoiceOver Announcement Delay")

        }
 
    }
}
 
#Preview {
    NavigationStack {
        VoiceOverAnnouncementDelayView()
    }
}
