/*
   Copyright 2026 CVS Health and/or one of its affiliates

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
import UIKit

// MARK: - Tab bar data

private struct TabBarItem: Identifiable {
    let id: Int
    let label: String
    let icon: String
    let selectedIcon: String
}

private let tabBarItems: [TabBarItem] = [
    TabBarItem(id: 0, label: "Home",     icon: "house",         selectedIcon: "house.fill"),
    TabBarItem(id: 1, label: "Explore",  icon: "safari",        selectedIcon: "safari.fill"),
    TabBarItem(id: 2, label: "Messages", icon: "message",       selectedIcon: "message.fill"),
    TabBarItem(id: 3, label: "Profile",  icon: "person.circle", selectedIcon: "person.circle.fill"),
]

// MARK: - Explore-by-Touch intercept layer

/// Transparent UIView overlaid on the tab bar capsule.
///
/// `accessibilityElements` returns `[]` so this view contributes nothing to
/// VoiceOver swipe navigation. The SwiftUI tab buttons beneath it remain in the
/// accessibility tree and are still reachable by swiping.
///
/// `accessibilityHitTest(_:event:)` is the UIKit hook VoiceOver calls during
/// Explore by Touch. The override here temporarily hides this view and re-runs
/// the hit test from the window root, so UIKit finds whatever scroll-content
/// element is physically behind the tab bar at the touch point — exactly the
/// bug in the CVS Pharmacy app where Explore by Touch on the tab bar focuses
/// the content card behind it instead of the tab button.
private final class TabBarExploreInterceptUIView: UIView {

    override var isAccessibilityElement: Bool {
        get { false }
        set { }
    }

    // Empty: this view adds nothing to the swipe-navigation order.
    // The SwiftUI tab buttons beneath it remain accessible via swipe.
    override var accessibilityElements: [Any]? {
        get { [] }
        set { }
    }

    // BUG: hides the entire overlay branch (tab buttons + this intercept) so
    // UIKit's accessibility hit test falls through to the scroll content.
    // Hiding only `self` doesn't work because the tab buttons are siblings
    // in the same overlay UIView and are still found by the hit test.
    //
    // `findOverlayBranch()` walks up the UIView tree looking for the ancestor
    // that is a sibling of the UIScrollView backing the SwiftUI ScrollView.
    // Hiding that ancestor hides the whole tab bar capsule at once.
    //
    // `@available(iOS 18, *)` matches the SDK declaration. Both Swift names
    // (`event:` and `withEvent:`) share the same ObjC selector, so the ObjC
    // runtime dispatches here on iOS 17 at runtime too.
    @available(iOS 18, *)
    override func accessibilityHitTest(_ point: CGPoint, event: UIEvent?) -> Any? {
        guard let window = self.window else { return nil }
        let windowPoint = convert(point, to: window)
        let overlay = findOverlayBranch()
        overlay?.isHidden = true
        let element = window.accessibilityHitTest(windowPoint, event: event)
        overlay?.isHidden = false
        return element
    }

    // Walk up from self until we find the ancestor whose SIBLING subtree
    // contains the UIScrollView. That ancestor is the overlay branch to hide.
    private func findOverlayBranch() -> UIView? {
        var current: UIView = self
        while let parent = current.superview, !(parent is UIWindow) {
            let siblings = parent.subviews.filter { $0 !== current }
            if siblings.contains(where: { subtreeContainsScrollView($0) }) {
                return current
            }
            current = parent
        }
        return nil
    }

    private func subtreeContainsScrollView(_ view: UIView) -> Bool {
        if view is UIScrollView { return true }
        return view.subviews.contains { subtreeContainsScrollView($0) }
    }
}

private struct TabBarExploreIntercept: UIViewRepresentable {
    func makeUIView(context: Context) -> TabBarExploreInterceptUIView {
        let view = TabBarExploreInterceptUIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ uiView: TabBarExploreInterceptUIView, context: Context) { }
}

// MARK: - Card component

private struct ContentCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let accentColor: Color

    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(accentColor.opacity(0.15))
                .frame(width: 52, height: 52)
                .overlay(
                    Image(systemName: systemImage)
                        .font(.title3)
                        .foregroundStyle(accentColor)
                )
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Main view

/// Bad example: custom liquid-glass tab bar that breaks VoiceOver Explore by Touch.
///
/// The tab bar buttons are fully visible and accessible via VoiceOver swipe
/// navigation. The bug is that `TabBarExploreInterceptUIView` overlays the tab
/// capsule and overrides `accessibilityHitTest(_:event:)` — the UIKit hook
/// VoiceOver calls during Explore by Touch.
///
/// When the user drags a finger over the tab bar area, the intercept view hides
/// itself and re-runs the hit test from the window root. UIKit finds whatever
/// scroll-content element is physically behind the tab bar at that touch point,
/// so VoiceOver announces the card content rather than the tab button.
///
/// The intercept view returns `[]` from `accessibilityElements`, so it does not
/// pollute the swipe-navigation order. The tab buttons below it remain reachable
/// via swipe — exactly matching the CVS Pharmacy app behavior.
struct ExploreByTouchBrokenView: View {
    @State private var selectedTab = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {

                // Discover section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Discover")
                        .font(.title2).bold()
                        .accessibilityAddTraits(.isHeader)

                    ContentCard(
                        title: "National Parks Guide",
                        subtitle: "America's most breathtaking landscapes and trails.",
                        systemImage: "mountain.2",
                        accentColor: .green
                    )
                    ContentCard(
                        title: "Urban Architecture",
                        subtitle: "A tour through iconic buildings and design history.",
                        systemImage: "building.columns",
                        accentColor: .indigo
                    )
                    ContentCard(
                        title: "Ocean Exploration",
                        subtitle: "Dive into the mysteries of the underwater world.",
                        systemImage: "drop.fill",
                        accentColor: .blue
                    )
                }

                // For You section
                VStack(alignment: .leading, spacing: 12) {
                    Text("For You")
                        .font(.title2).bold()
                        .accessibilityAddTraits(.isHeader)

                    ContentCard(
                        title: "Morning Routines",
                        subtitle: "Science-backed habits to energize your day.",
                        systemImage: "sunrise",
                        accentColor: .orange
                    )
                    ContentCard(
                        title: "Creative Writing",
                        subtitle: "Tips and exercises to develop your storytelling voice.",
                        systemImage: "pencil",
                        accentColor: .purple
                    )
                    ContentCard(
                        title: "Healthy Recipes",
                        subtitle: "Quick, nutritious meals for busy schedules.",
                        systemImage: "fork.knife",
                        accentColor: .red
                    )
                    ContentCard(
                        title: "Mindfulness",
                        subtitle: "Guided practices for clarity and calm.",
                        systemImage: "brain",
                        accentColor: .teal
                    )
                }

                // Trending section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Trending")
                        .font(.title2).bold()
                        .accessibilityAddTraits(.isHeader)

                    ContentCard(
                        title: "Space Exploration",
                        subtitle: "The latest missions and discoveries beyond Earth.",
                        systemImage: "moon.stars",
                        accentColor: .cyan
                    )
                    ContentCard(
                        title: "Sustainable Living",
                        subtitle: "Practical steps toward a smaller carbon footprint.",
                        systemImage: "leaf",
                        accentColor: .green
                    )
                    ContentCard(
                        title: "Digital Nomad Life",
                        subtitle: "Work from anywhere — stories from around the globe.",
                        systemImage: "globe",
                        accentColor: .brown
                    )
                }
            }
            .padding()
        }
        .overlay(alignment: .bottom) {
            // Tab bar buttons — visible and accessible via VoiceOver swipe.
            // No .accessibilityHidden; users can swipe to each tab.
            HStack(spacing: 0) {
                ForEach(tabBarItems) { item in
                    Button {
                        selectedTab = item.id
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: selectedTab == item.id
                                  ? item.selectedIcon : item.icon)
                                .font(.system(size: 22))
                            Text(item.label)
                                .font(.caption2)
                                .fontWeight(selectedTab == item.id ? .semibold : .regular)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                    .foregroundStyle(selectedTab == item.id ? Color.primary : Color.secondary)
                }
            }
            .padding(.horizontal, 4)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().strokeBorder(.primary.opacity(0.08), lineWidth: 0.5))
            // BUG: Intercept view overlays the capsule exactly, so its bounds match
            // the tab bar frame. UIKit calls accessibilityHitTest on it first during
            // Explore by Touch and it returns a fake content element.
            .overlay(TabBarExploreIntercept())
            .shadow(color: .black.opacity(0.14), radius: 16, x: 0, y: 4)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .navigationTitle("Explore by Touch Broken")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemGroupedBackground))
    }
}

#Preview {
    NavigationStack {
        ExploreByTouchBrokenView()
    }
}
