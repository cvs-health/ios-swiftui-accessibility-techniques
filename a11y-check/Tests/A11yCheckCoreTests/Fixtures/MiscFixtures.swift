import SwiftUI

// Good: Toggle with label
struct GoodToggle: View {
    @State private var isOn = false
    var body: some View {
        Toggle("Use Face ID", isOn: $isOn)
    }
}

// Bad: Toggle with empty label
struct BadToggleNoLabel: View {
    @State private var isOn = false
    var body: some View {
        Toggle("", isOn: $isOn)
    }
}

// Good: Link with descriptive text
struct GoodLink: View {
    var body: some View {
        Link("CVS Health website", destination: URL(string: "https://cvshealth.com")!)
    }
}

// Bad: Link with generic text
struct BadLinkGeneric: View {
    var body: some View {
        Link("Click here", destination: URL(string: "https://cvshealth.com")!)
    }
}

// Good: Dynamic Type font
struct GoodDynamicType: View {
    var body: some View {
        Text("Hello World")
            .font(.body)
    }
}

// Bad: Fixed font size
struct BadFixedFont: View {
    var body: some View {
        Text("Hello World")
            .font(.system(size: 30))
    }
}

// Bad: lineLimit(1)
struct BadLineLimit: View {
    var body: some View {
        Text("Hello World")
            .lineLimit(1)
    }
}

// Good: TextField with label
struct GoodTextField: View {
    @State private var text = ""
    var body: some View {
        TextField("First Name", text: $text)
    }
}

// Bad: TextField with empty label
struct BadTextFieldNoLabel: View {
    @State private var text = ""
    var body: some View {
        TextField("", text: $text)
    }
}

// Bad: Small touch target
struct BadSmallTarget: View {
    var body: some View {
        Button {
            // action
        } label: {
            Image(systemName: "xmark")
                .frame(width: 16, height: 16)
        }
    }
}
