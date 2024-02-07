import SwiftUI

enum ColorOption: String, CaseIterable {
    case black = "Black"
    case gray = "Gray"
    case white = "White"
    case red = "Red"
    
    var color: Color {
        switch self {
        case .black: return .black
        case .gray: return .gray
        case .white: return .white
        case .red: return .red
        }
    }
}

struct RadioButtonsView: View {
    @State private var selectedColor: ColorOption = .black
    @State private var selectedColorBad: ColorOption = .black

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack {
                Text("There is no native radio button control for SwiftUI in iOS. Use another native control like a `Picker` which allows only one selection or mimic radio group behavior on the web with VoiceOver.")
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
                    VStack {
                        Text("Choose Color")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ForEach(ColorOption.allCases, id: \.self) { colorOption in
                            RadioButton(title: colorOption.rawValue, isSelected: $selectedColor)
                        }
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("Choose Color")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Rectangle()
                        .fill(selectedColor.color)
                        .frame(width:  150, height:  150, alignment: .leading)
                        .overlay(Rectangle().stroke(Color.primary, lineWidth:  1))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                DisclosureGroup("Details") {
                    Text("The good radio button example uses custom `Button` elements styled to look like radio buttons. `.accessibilityRemoveTraits(.isButton)` removes the button trait. `.accessibilityAddTraits(isSelected.rawValue == title ? .isSelected : [])` adds the selected trait when checked. `.accessibilityRemoveTraits(isSelected.rawValue != title ? .isSelected : [])` removes the selected trait when unchecked. `.accessibilityValue(isSelected.rawValue == title ? Text(\"Radio button, checked\") : Text(\"Radio button, unchecked\"))` adds a fake radio button trait and a checked and unchecked state. Additionally `.accessibilityElement(children: .contain)` and `.accessibilityLabel(\"Choose Color\")` are used to give the radio group a label for VoiceOver.")
                }.padding()
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
                HStack {
                    VStack {
                        Text("Choose Color")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ForEach(ColorOption.allCases, id: \.self) { colorOption in
                            RadioButtonBad(title: colorOption.rawValue, isSelected: $selectedColorBad)
                    }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Rectangle()
                        .fill(selectedColorBad.color)
                        .frame(width:  150, height:  150, alignment: .leading)
                        .overlay(Rectangle().stroke(Color.primary, lineWidth:  1))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                DisclosureGroup("Details") {
                    Text("The bad radio button example uses custom `Button` elements styled to look like radio buttons. There is no additional code to add a radio button trait or a selected and checked/unchecked states. VoiceOver users don't know these are radio buttons or which button is checked or unchecked. There is also no radio group label for VoiceOver.")
                }.padding()
            }
            .navigationTitle("Radio Buttons")
            .padding()
        }
    }
}


struct RadioButton: View {
    let title: String
    @Binding var isSelected: ColorOption
    
    var body: some View {
        Button(action: {
            self.isSelected = ColorOption(rawValue: title)!
        }) {
            HStack {
                Circle()
                    .fill(.white)
                    .opacity(isSelected.rawValue == title ?  0.2 :  1)
                    .frame(width:  15, height:  15)
                    .overlay(Circle().stroke(isSelected.rawValue == title ? Color.blue : Color.primary, lineWidth:  isSelected.rawValue == title ?  6 :  2))
                Text(title)
                    .foregroundColor(.primary)
            }
        }
        .accessibilityRemoveTraits(.isButton)
        .accessibilityAddTraits(isSelected.rawValue == title ? .isSelected : [])
        .accessibilityRemoveTraits(isSelected.rawValue != title ? .isSelected : [])
        .accessibilityValue(isSelected.rawValue == title ? Text("Radio button, checked") : Text("Radio button, unchecked"))
    }
}
struct RadioButtonBad: View {
    let title: String
    @Binding var isSelected: ColorOption
    
    var body: some View {
        Button(action: {
            self.isSelected = ColorOption(rawValue: title)!
        }) {
            HStack {
                Circle()
                    .fill(.white)
                    .opacity(isSelected.rawValue == title ?  0.2 :  1)
                    .frame(width:  15, height:  15)
                    .overlay(Circle().stroke(isSelected.rawValue == title ? Color.blue : Color.primary, lineWidth:  isSelected.rawValue == title ?  6 :  2))
                Text(title)
                    .foregroundColor(.primary)
            }
        }

    }
}

struct RadioButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        RadioButtonsView()
    }
}
