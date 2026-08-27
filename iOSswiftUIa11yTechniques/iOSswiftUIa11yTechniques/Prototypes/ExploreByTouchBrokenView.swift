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

// MARK: - UIKit accessibility layer

/// UIView that owns UIAccessibilityElement objects for the tab bar items.
///
/// BUG: The elements' `accessibilityFrame` values are placed at the TOP of the
/// screen (status-bar area, y ≈ 5 pt) instead of at the visual tab bar position
/// at the bottom (y ≈ screen height − 80 pt).
///
/// Consequence:
/// - VoiceOver swipe navigation still reaches these elements (the UIKit
///   accessibility tree contains all elements regardless of frame position).
/// - Explore by Touch at the visual tab bar position (bottom of screen) finds
///   NO tab element there and falls through to the scroll-content cards behind it.
private final class TabBarMisplacedA11yView: UIView {
    private var tabElements: [UIAccessibilityElement] = []

    override var isAccessibilityElement: Bool {
        get { false }
        set { }
    }

    override var accessibilityElements: [Any]? {
        get { tabElements }
        set { }
    }

    func configure(items: [TabBarItem], selectedId: Int) {
        let screenWidth = UIScreen.main.bounds.width
        let tabWidth = screenWidth / CGFloat(max(items.count, 1))

        tabElements = items.enumerated().map { index, item in
            let element = UIAccessibilityElement(accessibilityContainer: self)
            element.accessibilityLabel = item.label
            element.accessibilityTraits = .button
            element.accessibilityHint = "Double tap to select"
            if item.id == selectedId {
                element.accessibilityValue = "selected"
            }
            // BUG: frame is at the very TOP of the screen (status-bar zone),
            // not at the visual tab bar at the bottom.
            // Explore by Touch at the real tab bar finds no element here,
            // so VoiceOver falls through to the scroll-content card behind it.
            element.accessibilityFrame = CGRect(
                x: CGFloat(index) * tabWidth,
                y: 5,
                width: tabWidth,
                height: 44
            )
            return element
        }
    }
}

private struct TabBarMisplacedA11yLayer: UIViewRepresentable {
    let tabItems: [TabBarItem]
    let selectedTab: Int

    func makeUIView(context: Context) -> TabBarMisplacedA11yView {
        let view = TabBarMisplacedA11yView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        view.configure(items: tabItems, selectedId: selectedTab)
        return view
    }

    func updateUIView(_ uiView: TabBarMisplacedA11yView, context: Context) {
        uiView.configure(items: tabItems, selectedId: selectedTab)
    }
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

/// Bad example: custom liquid-glass tab bar whose accessibility elements are
/// placed at the wrong screen position, breaking VoiceOver Explore by Touch.
///
/// THE BUG — misplaced accessibility frames:
///
///   `TabBarMisplacedA11yView` creates UIAccessibilityElement objects for
///   the four tab items with `accessibilityFrame` values at the TOP of the
///   screen (y ≈ 5 pt, status-bar zone) instead of at the visual tab bar at
///   the bottom (y ≈ screenHeight − 80 pt).
///
/// The visual tab bar buttons are `.accessibilityHidden(true)` so they do not
/// appear at any screen position in the accessibility tree. No bottom safe-area
/// inset is added to the scroll content, so card accessibility frames extend
/// into the tab bar zone at the bottom.
///
/// Result for a VoiceOver user:
/// - Swipe navigation: still reaches each tab item because UIKit swipe traversal
///   includes all elements in the tree regardless of frame position.
/// - Explore by Touch at the visual tab bar: no tab element has a frame there,
///   so VoiceOver finds the scroll-content card whose frame covers that area.
struct ExploreByTouchBrokenView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
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
                // BUG: no bottom inset — card frames extend into the tab bar zone.
                // When Explore by Touch lands on the tab bar area, it finds a card
                // instead of a tab item.
            }

            // BUG: tab accessibility frames are at the wrong position (top of screen).
            // Must fill the ZStack so its UIKit coordinate space matches the screen.
            TabBarMisplacedA11yLayer(tabItems: tabBarItems, selectedTab: selectedTab)
        }
        .overlay(alignment: .bottom) {
            HStack(spacing: 0) {
                ForEach(tabBarItems) { item in
                    Button {
                        selectedTab = item.id
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: selectedTab == item.id ? item.selectedIcon : item.icon)
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
            .shadow(color: .black.opacity(0.14), radius: 16, x: 0, y: 4)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
            // BUG: visual tab bar hidden from the accessibility tree entirely.
            // VoiceOver has no element at the visual tab bar position, so
            // Explore by Touch finds the scroll content behind it.
            .accessibilityHidden(true)
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
