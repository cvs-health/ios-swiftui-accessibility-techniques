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

// MARK: - Tab bar data

private struct TabBarItem: Identifiable {
    let id: Int
    let label: String
    let icon: String
    let selectedIcon: String
}

private let tabBarItems: [TabBarItem] = [
    TabBarItem(id: 0, label: "Home",     icon: "house",        selectedIcon: "house.fill"),
    TabBarItem(id: 1, label: "Explore",  icon: "safari",       selectedIcon: "safari.fill"),
    TabBarItem(id: 2, label: "Messages", icon: "message",      selectedIcon: "message.fill"),
    TabBarItem(id: 3, label: "Profile",  icon: "person.circle", selectedIcon: "person.circle.fill"),
]

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

/// Bad example: custom liquid-glass tab bar whose ZStack position breaks
/// VoiceOver Explore by Touch.
///
/// The bug: SwiftUI's accessibility traversal order follows ZStack structural
/// order, NOT visual .zIndex() order. The tab bar is declared FIRST in the
/// ZStack (lowest accessibility priority) and given .zIndex(1) to appear
/// visually on top. The scroll content is declared LAST (highest accessibility
/// priority). When VoiceOver Explore by Touch drags over the tab bar area it
/// hits the scroll content element — not the tab buttons — because the scroll
/// view is last in the accessibility tree and its cards have no bottom inset
/// to keep their frames out of the tab bar zone.
///
/// This mirrors the pattern found in the CVS Pharmacy component (PharmacyRootView)
/// where the header/footer VStack appears first in a ZStack and content appears
/// last, meaning the content wins for Explore by Touch even though the tab bar
/// is visually on top.
struct ExploreByTouchBrokenView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {

            // ── Custom liquid glass tab bar ───────────────────────────────────
            // BUG: Declared FIRST in ZStack so it is FIRST in the accessibility
            // tree — lowest priority for VoiceOver Explore by Touch.
            // .zIndex(1) makes it VISUALLY on top, but VoiceOver ignores zIndex
            // when determining Explore by Touch focus order; it uses structural
            // declaration order instead.
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
            .zIndex(1) // visually on top — but this does NOT affect accessibility order

            // ── Scrollable content ───────────────────────────────────────────
            // BUG: Declared LAST in ZStack so it is LAST in the accessibility
            // tree — highest priority for VoiceOver Explore by Touch.
            // Also has no bottom padding, so cards extend into the tab bar zone.
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
                // BUG: No .padding(.bottom, tabBarHeight) — last card's frame
                // extends into the tab bar zone, ensuring Explore by Touch
                // always finds a card element when dragging over the tab bar.
            }
            .zIndex(0) // visually behind — but LAST in ZStack = wins for Explore by Touch
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
