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
import Charts

struct TemperatureData: Identifiable {
    let id = UUID()
    var city: String
    var temperature: Int
}


struct ChartsView: View {

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    let data = [
        TemperatureData(city: "New York", temperature: 34),
        TemperatureData(city: "Chicago", temperature: 24),
        TemperatureData(city: "Miami", temperature: 58),
        TemperatureData(city: "Seattle", temperature: 42),
        TemperatureData(city: "Austin", temperature: 45)
    ]
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Don't convey information using colors alone in charts. Include shapes, patterns, text, or other non-color indicators to convey meaning so the chart is understandable when the colors cannot be perceived. Use `.accessibilityLabel` and `.accessibilityValue` to provide meaningful labels and values to VoiceOver users for the data points.")
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
                Text("Winter Temperatures ℉")
                    .font(.caption2)
                    .accessibilityAddTraits(.isHeader)
                    .bold()
                Chart(data) { dataPoint in
                    PointMark(
                        x: .value("City", dataPoint.city),
                        y: .value("Temperature", dataPoint.temperature)
                    )
                    .symbol(by: .value("City", dataPoint.city)) //give cities unique symbols
                    .foregroundStyle(by: .value("City", dataPoint.city))
                    .symbolSize(90)
                    .annotation(position: .trailing) {
                        Text(String(dataPoint.temperature)+"°")
                            .foregroundColor(.gray)
                    }
                    .accessibilityLabel(dataPoint.city)
                    .accessibilityValue(String(dataPoint.temperature) + "°")
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisValueLabel()
                    }
                }
                .chartXAxis {
                    AxisMarks(position: .bottom) { _ in
//                        AxisValueLabel() //hides bottom labels
                    }
                }
                .chartYScale(domain: 20...70)
                .aspectRatio(1, contentMode: .fit)
                DisclosureGroup("Details") {
                    Text("The good chart example uses `.symbol(by: .value(\"City\", dataPoint.city))` to provide a different symbol for each city rather than using color as the only visual indicator. `.accessibilityLabel` and `.accessibilityValue` are used to provide meaningful labels and values to VoiceOver users for the data points. The default accessibility labels and values are overridden to stop VoiceOver repeating the label text and to make sure the ° symbol is spoken in the value. ")
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
                Text("Winter Temperatures ℉")
                    .font(.caption2)
                    .accessibilityAddTraits(.isHeader)
                    .bold()
                Chart(data) { dataPoint in
                    PointMark(
                        x: .value("City", dataPoint.city),
                        y: .value("Temperature", dataPoint.temperature)
                    )
                    .foregroundStyle(by: .value("City", dataPoint.city))
                    .symbolSize(90)
                    .annotation(position: .trailing) {
                        Text(String(dataPoint.temperature)+"°")
                            .foregroundColor(.gray)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisValueLabel()
                    }
                }
                .chartXAxis {
                    AxisMarks(position: .bottom) { _ in
//                        AxisValueLabel() //hides bottom labels
                    }
                }
                .chartYScale(domain: 20...70)
                .aspectRatio(1, contentMode: .fit)
                DisclosureGroup("Details") {
                    Text("The bad chart example does not use the `.symbol()` modifier to provide a different symbol for each city. Instead, it uses the `.foregroundStyle()` modifier to differentiate the points using colors alone. `.accessibilityLabel` and `.accessibilityValue` are not used to provide meaningful labels and values to VoiceOver users for the data points. The default accessibility labels and values are spoken to VoiceOver repeating the label text and ignoring the ° symbol in the value.")
                }.padding(.bottom).accessibilityHint("Bad Example")
            }
            .navigationTitle("Charts")
            .padding()
        }
 
    }

}
 
#Preview {
    NavigationStack {
        ChartsView()
    }
}
