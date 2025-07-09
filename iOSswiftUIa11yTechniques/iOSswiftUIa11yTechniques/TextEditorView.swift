//
//  ToolbarView.swift
//  iOSswiftUIa11yTechniques
//
//  Created by Paul Adam on 7/2/25.
//

import SwiftUI

struct TextEditorView: View {
    
    @State private var text = ""
        @State private var bold = false
        @State private var italic = false
        @State private var fontSize = 12.0


        var displayFont: Font {
            let font = Font.system(size: CGFloat(fontSize),
                                   weight: bold == true ? .bold : .regular)
            return italic == true ? font.italic() : font
        }
    
    var body: some View {
        TextEditor(text: $text)
            .font(displayFont)
            .toolbar {
                ToolbarItemGroup {
                    Slider(
                        value: $fontSize,
                        in: 8...120,
                        minimumValueLabel:
                            Text("A").font(.system(size: 8)),
                        maximumValueLabel:
                            Text("A").font(.system(size: 16))
                    ) {
                        Text("Font Size (\(Int(fontSize)))")
                    }
                    .frame(width: 150)
                    Toggle(isOn: $bold) {
                        Image(systemName: "bold")
                    }
                    Toggle(isOn: $italic) {
                        Image(systemName: "italic")
                    }
                }
            }
            .navigationTitle("TextEditor")
    }
}

#Preview {
    TextEditorView()
}
