import SwiftUI

// Good: Button with descriptive label
struct GoodButton: View {
    var body: some View {
        Button("Edit Username") { }
    }
}

// Good: Icon-only button with accessibility label
struct GoodIconButton: View {
    var body: some View {
        Button {
            // action
        } label: {
            Image(systemName: "pencil")
        }
        .accessibilityLabel("Edit Username")
    }
}

// Good: Disabled button with .disabled(true)
struct GoodDisabledButton: View {
    var body: some View {
        Button("Submit") { }
            .disabled(true)
            .tint(.gray)
    }
}

// Bad: Button label contains "button"
struct BadButtonWithRole: View {
    var body: some View {
        Button("Edit button") { }
    }
}

// Bad: Icon-only button without accessibility label
struct BadIconButtonNoLabel: View {
    var body: some View {
        Button {
            // action
        } label: {
            Image(systemName: "pencil")
        }
    }
}

// Bad: Visually disabled but not semantically
struct BadVisuallyDisabled: View {
    var body: some View {
        Button("Submit") { }
            .tint(.gray)
    }
}

// Good: onTapGesture with button trait
struct GoodTapGesture: View {
    var body: some View {
        Image(systemName: "barcode.viewfinder")
            .onTapGesture { }
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel("Scan Barcode")
    }
}

// Bad: onTapGesture without button trait
struct BadTapGesture: View {
    var body: some View {
        Image(systemName: "barcode.viewfinder")
            .onTapGesture { }
            .accessibilityLabel("Scan Barcode")
    }
}
