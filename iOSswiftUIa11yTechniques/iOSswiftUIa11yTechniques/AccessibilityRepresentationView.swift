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

struct CustomSlider: View {
    @Binding var value: Double
    private var maxValue: Double

    init(value: Binding<Double>, maxValue: Double) {
        self._value = value
        self.maxValue = maxValue
    }

    var body: some View {
        GeometryReader { proxy in
            let trackWidth = proxy.size.width
            let thumbPosition = trackWidth * (value / maxValue)

            ZStack(alignment: .leading) {
                Capsule()
                    .foregroundColor(.secondary)

                Capsule()
                    .fill(LinearGradient(gradient: .init(colors: [.white, .black]), startPoint: .leading, endPoint: .trailing))
                    .contentShape(.capsule)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(.primary, in: Capsule().stroke(style: .init()))

                Circle()
                    .fill(Color.white)
                    .stroke(.black, style: .init(lineWidth: 3))
                    .frame(width: 30, height: 30)
                    .offset(x: thumbPosition - 10)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let locationX = value.location.x
                                let percentage = locationX / trackWidth
                                self.value = percentage * maxValue
                            }
                    )
            }
        }
    }
}
struct CustomSliderBad: View {
    @Binding var value: Double
    private var maxValue: Double

    init(value: Binding<Double>, maxValue: Double) {
        self._value = value
        self.maxValue = maxValue
    }

    var body: some View {
        GeometryReader { proxy in
            let trackWidth = proxy.size.width
            let thumbPosition = trackWidth * (value / maxValue)

            ZStack(alignment: .leading) {
                Capsule()
                    .foregroundColor(.secondary)

                Capsule()
                    .fill(LinearGradient(gradient: .init(colors: [.white, .black]), startPoint: .leading, endPoint: .trailing))
                    .contentShape(.capsule)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(.primary, in: Capsule().stroke(style: .init()))

                Circle()
                    .fill(Color.white)
                    .stroke(.black, style: .init(lineWidth: 3))
                    .frame(width: 30, height: 30)
                    .offset(x: thumbPosition - 10)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let locationX = value.location.x
                                let percentage = locationX / trackWidth
                                self.value = percentage * maxValue
                            }
                    )
            }
        }
    }
}



struct AccessibilityRepresentationView: View {
    @State private var currentValue = 0.0
    @State private var currentValueBad = 0.0


    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Accessibility Representation is used to provide accessibility support to custom controls. Use `.accessibilityRepresentation` to provide a hidden native control representation for the otherwise inaccessible custom control.")
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
                VStack(spacing:10) {
                    HStack {
                        Text("Opacity")
                            .fontWeight(.bold)
                        Text("\(currentValue, specifier: "%.0F")")
                    }.frame(maxWidth: .infinity, alignment: .leading)
                    CustomSlider(value: $currentValue, maxValue: 100)
                        .frame(minHeight: 24)
                        .padding(.leading, 15)
                        .accessibilityRepresentation {
                                Slider(value: $currentValue, in: 0...100) {
                                    Text("Opacity")
                                }
                            }
                        .accessibilityAddTraits(.allowsDirectInteraction)
                }
                DisclosureGroup("Details") {
                    Text("The good accessibility representation example uses `.accessibilityRepresentation { Slider(value: $currentValue, in: 0...100) { Text(\"Opacity\") } }` on a `CustomSlider` view to make it behave like a native `Slider` with a label and value that is focusable and adjustable with VoiceOver. `.accessibilityAddTraits(.allowsDirectInteraction)` is added to allow VoiceOver users to directly touch and move the slider in addition to swiping up or down to adjust the value.")
                }.padding([.top,.bottom]).accessibilityHint("Good Example")
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
                VStack(spacing:10) {
                    HStack {
                        Text("Opacity")
                            .fontWeight(.bold)
                        Text("\(currentValueBad, specifier: "%.0F")")
                    }.frame(maxWidth: .infinity, alignment: .leading)
                    CustomSliderBad(value: $currentValueBad, maxValue: 100)
                        .frame(minHeight: 24)
                        .padding(.leading, 15)
                }
                DisclosureGroup("Details") {
                    Text("The bad accessibility representation example does not use `.accessibilityRepresentation` on the `CustomSliderBad` view to make it behave like a native `Slider` with a label and value that is focusable and adjustable with VoiceOver. VoiceOver users cannot directly touch and move the slider or swipe up or down to adjust the value.")
                }.padding(.top).accessibilityHint("Bad Example")
            }
            .navigationTitle("Accessibility Representation")
            .padding()

        }
 
    }

}
 
struct AccessibilityRepresentationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AccessibilityRepresentationView()
        }
    }
}
