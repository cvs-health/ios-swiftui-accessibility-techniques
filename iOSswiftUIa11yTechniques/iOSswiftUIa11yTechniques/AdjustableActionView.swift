/*
   Copyright 2023-2025 CVS Health and/or one of its affiliates

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

struct RatingView: View {
   @Binding var rating: Int
   var maximumRating: Int = 5
   var offImage = Image(systemName: "star")
   var onImage = Image(systemName: "star.fill")
   var offColor = Color.gray
   var onColor = Color.red

   var body: some View {
       HStack {
           ForEach(1..<maximumRating + 1, id: \.self) { number in
               Button {
                  rating = number
               } label: {
                  image(for: number)
                      .foregroundStyle(number > rating ? offColor : onColor)
               }
           }
       }
   }

   func image(for number: Int) -> Image {
       if number > rating {
           offImage 
       } else {
           onImage
       }
   }
}

struct RatingViewGood: View {
   @Binding var rating: Int
   var maximumRating: Int = 5
   var offImage = Image(systemName: "star")
   var onImage = Image(systemName: "star.fill")
   var offColor = Color.gray
   var onColor = Color.red

   var body: some View {
       HStack {
           ForEach(1..<maximumRating + 1, id: \.self) { number in
               Button {
                  rating = number
               } label: {
                  image(for: number)
                      .foregroundStyle(number > rating ? offColor : onColor)
               }
               .accessibilityLabel("\(number) star\(number > 1 ? "s" : "")")
               .accessibilityAddTraits(number == rating ? .isSelected : [])
           }
       }
   }

   func image(for number: Int) -> Image {
       if number > rating {
           offImage
       } else {
           onImage
       }
   }
}

 
struct AdjustableActionView: View {
    @State var rating: Int = 0
    @State var ratingBad: Int = 0

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Use `.accessibilityAdjustableAction` to enable VoiceOver users to adjust an incrementable control like a custom star rating widget. With `.accessibilityAdjustableAction` VoiceOver users can swipe up or down to increment and decrement the adjustable control's value.")
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
                Text("Rate your experience:").frame(maxWidth: .infinity, alignment: .leading)
                RatingViewGood(rating: $rating).frame(maxWidth: .infinity, alignment: .leading).padding()
                .accessibilityElement()
                .accessibilityLabel("Rate your experience")
                .accessibilityValue(String(rating)+" star\(rating > 1 ? "s" : "")")
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment:
                        guard rating < 5 else { break }
                        rating += 1
                    case .decrement:
                        guard rating > 1 else { break }
                        rating -= 1
                    @unknown default:
                        break
                    }
                }
                .accessibilityAction(named: "1 star") { rating = 1 }
                .accessibilityAction(named: "2 stars") { rating = 2 }
                .accessibilityAction(named: "3 stars") { rating = 3 }
                .accessibilityAction(named: "4 stars") { rating = 4 }
                .accessibilityAction(named: "5 stars") { rating = 5 }
                DisclosureGroup("Details") {
                    Text("The good adjustable example uses `.accessibilityAdjustableAction` to increment and decrement the star rating when VoiceOver users swipe up and down. `.accessibilityElement()`, `.accessibilityLabel`, and `.accessibilityValue` are also added to make the custom control accessible. A named `.accessibilityAction` is also added to allow Voice Control users to say show actions for Rate and then choose a star rating.")
                }.padding(.bottom).accessibilityHint("Good Example")
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
                Text("Rate your experience:").frame(maxWidth: .infinity, alignment: .leading)
                RatingView(rating: $ratingBad).frame(maxWidth: .infinity, alignment: .leading).padding()
                DisclosureGroup("Details") {
                    Text("The bad adjustable example does not use `.accessibilityAdjustableAction` to increment and decrement the star rating when VoiceOver users swipe up and down. Instead VoiceOver users must focus on each individual star to choose a rating. `.accessibilityElement()`, `.accessibilityLabel`, and `.accessibilityValue` are missing.")
                }.accessibilityHint("Bad Example")
            }
            .navigationTitle("Adjustable Action")
            .padding()
        }
 
    }
}
 
struct AdjustableActionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AdjustableActionView()
        }
    }
}
