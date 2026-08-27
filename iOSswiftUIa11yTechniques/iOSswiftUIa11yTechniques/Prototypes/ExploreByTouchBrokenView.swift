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

/// Bad example: custom liquid-glass tab bar that breaks VoiceOver Explore by Touch.
///
/// The bug pattern is taken directly from the CVS Pharmacy component
/// (GlobalHeaderAndFooterModifier in GlobalHeaderFooterParams.swift):
///
///     content
///         .accessibilityElement(children: .contain)   // ← BUG
///         .overlay(alignment: .bottom) { tabBar }
///
/// `.accessibilityElement(children: .contain)` groups all scroll content into
/// one accessibility container whose frame covers the full screen — including
/// the tab bar area. The tab bar is then placed as a `.overlay(alignment: .bottom)`
/// AFTER and OUTSIDE that container. No bottom inset is added to the scroll
/// content, so card elements' accessibility frames extend into the tab bar zone.
///
/// When VoiceOver Explore by Touch drags over the tab bar area:
/// - The tab bar buttons are OUTSIDE the accessibility container (overlay)
/// - The scroll content cards are INSIDE the container with frames extending
///   into the tab bar area
/// - VoiceOver resolves the overlap by finding the most specific element inside
///   the nearest container — the card — instead of the tab bar buttons
struct ExploreByTouchBrokenView: View {
    @State private var selectedTab = 0

    var body: some View {
        // ── Scrollable content ───────────────────────────────────────────────
        // BUG 1: .accessibilityElement(children: .contain) groups all content
        //         into a container with a full-screen frame. The tab bar added
        //         below as an overlay is OUTSIDE this container.
        // BUG 2: No bottom padding — card frames extend into the tab bar zone,
        //         so VoiceOver always finds a card when exploring that region.
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
        // BUG: groups all scroll content into an accessibility container.
        // The tab bar overlay added next is outside this container.
        .accessibilityElement(children: .contain)
        // ── Custom liquid glass tab bar ───────────────────────────────────────
        // BUG: Added as overlay AFTER .accessibilityElement(children: .contain),
        //      placing it OUTSIDE the accessibility container. VoiceOver
        //      Explore by Touch finds the card elements inside the container
        //      instead of these tab buttons when dragging over this area.
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
