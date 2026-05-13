import SwiftUI

// Good: Image with accessibility label
struct GoodInformativeImage: View {
    var body: some View {
        Image(systemName: "newspaper")
            .accessibilityLabel("News")
    }
}

// Good: Decorative image using Image(decorative:)
struct GoodDecorativeImage: View {
    var body: some View {
        Image(decorative: "background-pattern")
    }
}

// Good: Decorative image hidden from VoiceOver
struct GoodHiddenDecorativeImage: View {
    var body: some View {
        Image(systemName: "globe")
            .accessibilityHidden(true)
    }
}

// Bad: Image with no label and not decorative
struct BadImageNoLabel: View {
    var body: some View {
        Image(systemName: "newspaper")
    }
}

// Bad: Image with no label – file-based
struct BadFileImageNoLabel: View {
    var body: some View {
        Image("hero-photo")
    }
}

// Bad: Image label contains "icon"
struct BadImageLabelWithRole: View {
    var body: some View {
        Image(systemName: "star.fill")
            .accessibilityLabel("Star icon")
    }
}
