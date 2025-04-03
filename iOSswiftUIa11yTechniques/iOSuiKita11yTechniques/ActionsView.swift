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
 
struct ActionsView: View {
    @State private var showingAlert = false
    @State private var actionTitle = ""
    @State private var msg1label = "Your order has shipped!"
    @State private var msg2label = "Your order was received!"
    @State private var msg1bold = true
    @State private var msg1hidden = false
    @State private var editing = false
    @State private var msg2bold = true
    @State private var msg2hidden = false
    @State private var msg1offset: CGFloat = 0
    @State private var msg2offset: CGFloat = 0
    @State private var msg1boldBad = true
    @State private var msg1hiddenBad = false
    @State private var msg2boldBad = true
    @State private var msg2hiddenBad = false
    @State private var msg1offsetBad: CGFloat = 0
    @State private var msg2offsetBad: CGFloat = 0


    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Use `accessibilityAction()` to provide actions that can be activated by iOS accessibility features like VoiceOver. Full Keyboard Access users can press `Tab + z` to open Actions menu. Voice Control users can say \"Show actions for\" and the name or number of the element to open its Actions menu. With \"Show numbers\" Voice Control users will see a right arrow next to elements with actions. Additionally make sure there are single tap alternatives to gesture functions.")
                    .padding(.bottom)
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
                HStack {
                    Text("Secure Messages").frame(maxWidth: .infinity, alignment: .leading).padding(.bottom).bold().accessibilityAddTraits(/*@START_MENU_TOKEN@*/.isHeader/*@END_MENU_TOKEN@*/)
                    Button(action: {
                        editing = true
                    }) {
                        Text("Edit")
                    }.accessibilityLabel("Edit Secure Messages")
                }
                if !msg1hidden {
                    HStack {
                        Button(msg1label) {
                            
                        }.padding(.init(top: 10, leading: 40, bottom: 10, trailing: 40)).tint(Color(colorScheme == .dark ? .black : .white)).bold(msg1bold)
                            .simultaneousGesture(
                                 LongPressGesture()
                                   .onEnded { _ in
                                       msg1bold = false
                                   }
                              )
                            .accessibilityAction(named: "Delete") {
                                showingAlert = true
                                actionTitle = "Delete"
                                msg1hidden = true
                            }
                            .accessibilityAction(named: "Mark as Read") {
                                showingAlert = true
                                actionTitle = "Mark as Read"
                                msg1bold = false
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color(colorScheme == .dark ? .white : .black))
                            .cornerRadius(10)
                            .offset(x: msg1offset)
                            .gesture(
                               DragGesture().onChanged { value in
                                  self.msg1offset = value.translation.width
                               }
                               .onEnded { value in
                                  if abs(value.translation.width) > 100 {
                                    self.msg1offset = -300
                                      msg1hidden = true
                                  } else {
                                    self.msg1offset = 0
                                  }
                               }
                            )
                        if editing {
                            VStack {
                                Button(action: {
                                    msg1hidden = true
                                }) {
                                    Image(systemName: "trash")
                                        .renderingMode(.original)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 44, height: 44)
                                        .accessibilityLabel("Delete \(msg1label)")
                                }
                                Button(action: {
                                    msg1bold = false
                                }) {
                                    Image(systemName: "envelope")
                                        .renderingMode(.original)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 44, height: 44)
                                        .accessibilityLabel("Mark \(msg1label) as Read")
                                }
                            }
                        }
                    }
                }
                if !msg2hidden {
                    HStack {
                        Button(msg2label) {

                        }.padding(.init(top: 10, leading: 40, bottom: 10, trailing: 40)).tint(Color(colorScheme == .dark ? .black : .white)).bold(msg2bold)
                            .simultaneousGesture(
                                 LongPressGesture()
                                   .onEnded { _ in
                                       msg2bold = false
                                   }
                              )
                            .lineLimit(.none)
                            .accessibilityAction(named: "Delete") {
                                showingAlert = true
                                actionTitle = "Delete"
                                msg2hidden = true
                            }
                            .accessibilityAction(named: "Mark as Read") {
                                showingAlert = true
                                actionTitle = "Mark as Read"
                                msg2bold = false
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color(colorScheme == .dark ? .white : .black))
                            .cornerRadius(10)
                            .offset(x: msg2offset)
                            .gesture(
                               DragGesture().onChanged { value in
                                  self.msg2offset = value.translation.width
                               }
                               .onEnded { value in
                                  if abs(value.translation.width) > 100 {
                                    self.msg2offset = -300
                                      msg2hidden = true
                                  } else {
                                    self.msg2offset = 0
                                  }
                               }
                            )
                        if editing {
                            VStack {
                                Button(action: {
                                    msg2hidden = true
                                }) {
                                    Image(systemName: "trash")
                                        .renderingMode(.original)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 44, height: 44)
                                        .accessibilityLabel("Delete \(msg2label)")
                                }
                                Button(action: {
                                    msg2bold = false
                                }) {
                                    Image(systemName: "envelope")
                                        .renderingMode(.original)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 44, height: 44)
                                        .accessibilityLabel("Mark \(msg2label) as Read")
                                }
                            }
                        }
                    }
                }
                DisclosureGroup("Details") {
                    Text("The good actions example uses `.accessibilityAction(named: \"Delete\")` and `.accessibilityAction(named: \"Mark as Read\")` to provide assistive technology users accessibility actions as alternatives to the swipe to delete and long press to mark as read gestures. There is an Edit mode which provides single tap button alternatives to the swipe to delete and long press gestures.")
                }.padding(.bottom).accessibilityHint("Good Example")
                Text("Bad Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                Text("Secure Messages").frame(maxWidth: .infinity, alignment: .leading).padding(.bottom).bold()
                if !msg1hiddenBad {
                    Button("Your order has shipped!") {
                        
                    }.padding(.init(top: 10, leading: 40, bottom: 10, trailing: 40)).tint(Color(colorScheme == .dark ? .black : .white)).bold(msg1boldBad)
                        .simultaneousGesture(
                             LongPressGesture()
                               .onEnded { _ in
                                   msg1boldBad = false
                               }
                          )
                        .frame(maxWidth: .infinity)
                        .background(Color(colorScheme == .dark ? .white : .black))
                        .cornerRadius(10)
                        .offset(x: msg1offsetBad)
                        .gesture(
                           DragGesture().onChanged { value in
                              self.msg1offsetBad = value.translation.width
                           }
                           .onEnded { value in
                              if abs(value.translation.width) > 100 {
                                self.msg1offsetBad = -300
                                  msg1hiddenBad = true
                              } else {
                                self.msg1offsetBad = 0
                              }
                           }
                        )
                }
                if !msg2hiddenBad {
                    Button("Your order was received!") {

                    }.padding(.init(top: 10, leading: 40, bottom: 10, trailing: 40)).tint(Color(colorScheme == .dark ? .black : .white)).bold(msg2boldBad)
                        .simultaneousGesture(
                             LongPressGesture()
                               .onEnded { _ in
                                   msg2boldBad = false
                               }
                          )
                        .lineLimit(.none)
                        .frame(maxWidth: .infinity)
                        .background(Color(colorScheme == .dark ? .white : .black))
                        .cornerRadius(10)
                        .offset(x: msg2offsetBad)
                        .gesture(
                           DragGesture().onChanged { value in
                              self.msg2offsetBad = value.translation.width
                           }
                           .onEnded { value in
                              if abs(value.translation.width) > 100 {
                                self.msg2offsetBad = -300
                                  msg2hiddenBad = true
                              } else {
                                self.msg2offsetBad = 0
                              }
                           }
                        )
                }

                DisclosureGroup("Details") {
                    Text("The bad actions example does not use `.accessibilityAction(named: \"Delete\")` and `.accessibilityAction(named: \"Mark as Read\")` to provide assistive technology users accessibility actions as alternatives to the swipe to delete and long press to mark as read gestures. VoiceOver does not speak that there is a swipe to delete or long press gesture on the buttons. There is no Edit mode to provide single tap button alternatives to the swipe to delete and long press gestures.")
                }.accessibilityHint("Bad Example")

            }
            .navigationTitle("Accessibility Actions")
            .padding()
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("\(actionTitle) Action Activated"), message: Text("You activated the accessibility action named \(actionTitle)!"), dismissButton: .default(Text("OK")))
            }

        }
 
    }
}
 
struct ActionsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ActionsView()
        }
    }
}
