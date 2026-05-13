import SwiftUI

// Good: Heading with .isHeader trait
struct GoodHeading: View {
    var body: some View {
        Text("Store Hours")
            .font(.title)
            .accessibilityAddTraits(.isHeader)
    }
}

// Bad: Title font without heading trait
struct BadHeadingNoTrait: View {
    var body: some View {
        Text("Store Hours")
            .font(.title)
    }
}

// Bad: Faking heading in accessibility label
struct BadFakeHeading: View {
    var body: some View {
        Text("Store Hours")
            .accessibilityLabel("Store Hours heading")
    }
}
