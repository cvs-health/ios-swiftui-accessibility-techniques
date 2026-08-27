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

/// Transparent UIView that sits on top of the visual tab bar in the Z-order.
///
/// UIKit calls `accessibilityHitTest(_:with:)` on the topmost view when
/// VoiceOver Explore by Touch fires. By overriding that method here, this view
/// intercepts every Explore by Touch event that lands on the tab bar area and
/// returns a fake scroll-content element — exactly what the CVS app does through
/// its `.accessibilityElement(children: .contain)` container pattern.
///
/// `accessibilityElements` returns an empty array so this view contributes
/// nothing to VoiceOver swipe navigation. The SwiftUI tab buttons behind it
/// remain in the accessibility tree and are still reachable by swiping.
private final class TabBarExploreInterceptUIView: UIView {

    private lazy var fakeElement: UIAccessibilityElement = {
        let element = UIAccessibilityElement(accessibilityContainer: self)
        // Sounds like a visible scroll-content card, not a tab item.
        element.accessibilityLabel = "Mindfulness"
        element.accessibilityValue = "Guided practices for clarity and calm."
        element.accessibilityTraits = .button
        element.accessibilityHint = "Double tap to open"
        return element
    }()

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

    // BUG: intercepts Explore by Touch on the tab bar and returns a scroll-content
    // element instead of passing through to the tab buttons below.
    override func accessibilityHitTest(_ point: CGPoint, with event: UIEvent?) -> Any? {
        fakeElement.accessibilityFrame = UIAccessibilityConvertFrameToScreenCoordinates(
            bounds, self
        )
        return fakeElement
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
/// navigation. The bug is that `TabBarExploreInterceptUIView` sits on top of
/// them in the Z-order and overrides `accessibilityHitTest(_:with:)` — the UIKit
/// hook VoiceOver calls during Explore by Touch.
///
/// When the user drags a finger over the tab bar area, the intercept view returns
/// a fake scroll-content element instead of passing through to the tab buttons.
/// VoiceOver announces "Mindfulness, button" rather than "Home, button."
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
            ZStack(alignment: .bottom) {
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

                // BUG: Intercept view sits on top of the tab buttons in Z-order.
                // UIKit calls its accessibilityHitTest during Explore by Touch and
                // it returns a fake content element instead of the tab buttons.
                TabBarExploreIntercept()
            }
            .padding(.horizontal, 4)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().strokeBorder(.primary.opacity(0.08), lineWidth: 0.5))
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
