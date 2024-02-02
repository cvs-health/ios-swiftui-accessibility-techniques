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
 
struct ReduceMotionView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var scale = 1.0
    @State private var isRotating = 0.0
    @State private var scaleBad = 1.0
    @State private var isRotatingBad = 0.0

    
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Motion and Animations must have a method to be paused, stopped, or hidden so that users are not distracted by the moving content. Provide a pause button when animations or moving content are used or support the user's Reduce Motion accessibility preferences and stop moving content when enabled. Use the `@Environment(\\.accessibilityReduceMotion)` variable to stop moving content when Reduce Motion is enabled.")
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
                Circle()
                    .fill(Color.red)
                    .frame(width: 50, height: 50)
                    .scaleEffect(scale)
                    .animation(reduceMotion ? nil : Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true))
                    .onAppear {
                        self.scale = 1.5
                    }
                    .accessibilityLabel("Pulsing red circle that stops moving when reduce motion is enabled.")
                Image(systemName: "gear")
                            .font(.system(size: 64))
                            .rotationEffect(.degrees(isRotating))
                            .onAppear {
                                withAnimation(reduceMotion ? nil : .linear(duration: 1).speed(0.1).repeatForever(autoreverses: false)) {
                                    isRotating = 360.0
                                }
                            }
                            .accessibilityLabel("Rotating gear icon that stops moving when reduce motion is enabled.")
                DisclosureGroup("Details") {
                    Text("The good reduce motion example uses the `@Environment(\\.accessibilityReduceMotion)` variable to stop the pulsing red circle animation and the gear image from spinning when the user's Reduce Motion accessibility setting is enabled.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
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
                Circle()
                    .fill(Color.red)
                    .frame(width: 50, height: 50)
                    .scaleEffect(scaleBad)
                    .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true))
                    .onAppear {
                        self.scaleBad = 1.5
                    }
                    .accessibilityLabel("Pulsing red circle that does not stop moving even when reduce motion is enabled.")
                Image(systemName: "gear")
                            .font(.system(size: 64))
                            .rotationEffect(.degrees(isRotatingBad))
                            .onAppear {
                                withAnimation(.linear(duration: 1).speed(0.1).repeatForever(autoreverses: false)) {
                                    isRotatingBad = 360.0
                                }
                            }
                            .accessibilityLabel("Rotating gear icon that does not stop moving even when reduce motion is enabled.")
                DisclosureGroup("Details") {
                    Text("The good reduce motion example does not use the `@Environment(\\.accessibilityReduceMotion)` variable to stop the pulsing red circle animation and the gear image from spinning when the user's Reduce Motion accessibility setting is enabled.")
                }.padding().tint(Color(colorScheme == .dark ? .systemBlue : .blue))
            }
            .navigationTitle("Reduce Motion")
            .padding()
        }
 
    }
}
 
struct ReduceMotionView_Previews: PreviewProvider {
    static var previews: some View {
        ReduceMotionView()
    }
}
