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
    TabBarItem(id: 0, label: "Home",     icon: "house",         selectedIcon: "house.fill"),
    TabBarItem(id: 1, label: "Explore",  icon: "safari",        selectedIcon: "safari.fill"),
    TabBarItem(id: 2, label: "Messages", icon: "message",       selectedIcon: "message.fill"),
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
                        .accessibilityHidden(true)
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
                .accessibilityHidden(true)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Main view

/// Bad example: replicates the CVS Pharmacy app's Explore by Touch bug.
///
/// The pattern comes directly from `GlobalHeaderAndFooterModifier` in the CVS
/// codebase. `.accessibilityElement(children: .contain)` is applied to the
/// content `VStack` BEFORE `.overlay(alignment: .bottom)` adds the tab bar.
/// This creates a UIKit accessibility container whose frame covers the full
/// screen — including the area where the tab bar floats. When VoiceOver
/// Explore by Touch fires over the tab bar, the container captures the event
/// and returns a scroll-content element instead of the tab button.
///
/// Each tab also uses `.accessibilityRemoveTraits(.isButton)` matching
/// `BottomTabBubbleView` in the CVS codebase, which further degrades the
/// tab bar's accessibility signal.
///
/// VoiceOver swipe navigation still reaches every tab because `.contain`
/// does not hide children — it groups them. The tab buttons remain in the
/// swipe order after the content elements.
struct ExploreByTouchBrokenView: View {
    @State private var selectedTab = 0

    var body: some View {
        // BUG: .accessibilityElement(children: .contain) on the content VStack
        // creates a full-screen UIKit container. The .overlay(alignment: .bottom)
        // for the tab bar is applied after, so the container's accessibility
        // frame covers the tab bar area. Explore by Touch on the tab bar finds
        // a content element inside the container instead of the tab button.
        VStack(spacing: 0) {
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
            .frame(maxHeight: .infinity)
        }
        // BUG: .contain applied here, before the tab bar overlay is added.
        // Mirrors GlobalHeaderAndFooterModifier in the CVS codebase.
        .accessibilityElement(children: .contain)
        .overlay(alignment: .bottom) {
            HStack(spacing: 0) {
                ForEach(tabBarItems) { item in
                    Button {
                        selectedTab = item.id
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: selectedTab == item.id
                                  ? item.selectedIcon : item.icon)
                                .font(.system(size: 22))
                                .accessibilityHidden(true)
                            Text(item.label)
                                .font(.caption2)
                                .fontWeight(selectedTab == item.id ? .semibold : .regular)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                    .foregroundStyle(selectedTab == item.id ? Color.primary : Color.secondary)
                    // BUG: mirrors BottomTabBubbleView in the CVS codebase.
                    .accessibilityLabel(item.label)
                    .accessibilityRemoveTraits(.isButton)
                    .accessibilityHint("Double tap to activate")
                }
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
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    NavigationStack {
        ExploreByTouchBrokenView()
    }
}
