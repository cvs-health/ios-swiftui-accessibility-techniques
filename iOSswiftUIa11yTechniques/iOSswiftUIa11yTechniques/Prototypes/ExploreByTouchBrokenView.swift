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
/// Bug pattern copied from the CVS Pharmacy module:
///
/// BUG 1 — GlobalHeaderAndFooterModifier (GlobalHeaderFooterParams.swift):
///
///     VStack { content }
///         .accessibilityElement(children: .contain)   // groups content into full-screen container
///         .overlay(alignment: .bottom) { getFooterView() }  // tab bar OUTSIDE the container
///
/// `.accessibilityElement(children: .contain)` turns the VStack into an iOS accessibility
/// container whose frame spans the full screen. iOS hit-testing drills INTO this container
/// first when the touch position is inside its frame. The tab bar lives in an .overlay()
/// AFTER this modifier — so it is a sibling of the container, not a child. iOS accessibility
/// does not exit the container to check siblings while it still has children to offer.
///
/// BUG 2 — BottomTabBubbleView.swift:
///
///     tabItemButton
///         .accessibilityRemoveTraits(.isButton)   // strips the interactive trait
///         .accessibilityFocused($focusedTabId, equals: tabItem.id)
///
/// Each tab is a Button, but `.accessibilityRemoveTraits(.isButton)` turns it into a
/// static, non-interactive element in VoiceOver's eyes. Elements without an interactive
/// trait rank below interactive elements during Explore by Touch conflict resolution.
///
/// Combined effect — Explore by Touch over the tab bar area:
/// - iOS enters the full-screen accessibility container (from BUG 1)
/// - Looks for children whose frames include the touch point
/// - Finds a scroll-content card (no bottom safe-area inset was added, so card frames
///   extend into the tab bar zone)
/// - Returns the card without ever checking the non-interactive tab items outside the
///   container
struct ExploreByTouchBrokenView: View {
    @State private var selectedTab = 0
    @AccessibilityFocusState private var focusedTabId: Int?

    // Extracted to avoid type-checker complexity from long modifier chains inside ForEach.
    @ViewBuilder
    private func tabButton(for item: TabBarItem) -> some View {
        let hint = "Double tap to select \(item.label)"
        Button {
            selectedTab = item.id
            // BUG 2 (part): sets focusedTabId so VoiceOver is asked to
            // move focus here, but the tab item has no .isButton trait —
            // it cannot receive Explore by Touch focus normally.
            focusedTabId = item.id
        } label: {
            VStack(spacing: 4) {
                Image(systemName: selectedTab == item.id ? item.selectedIcon : item.icon)
                    .font(.system(size: 22))
                    // BUG 2 (part): icon hidden, matching BottomTabBubbleView —
                    // VoiceOver reads only the text label, not the image.
                    .accessibilityHidden(true)
                Text(item.label)
                    .font(.caption2)
                    .fontWeight(selectedTab == item.id ? .semibold : .regular)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
        .foregroundStyle(selectedTab == item.id ? Color.primary : Color.secondary)
        .accessibilityLabel(item.label)
        .accessibilityValue(selectedTab == item.id ? "selected" : "")
        // BUG 2: strips the interactive .isButton trait, exactly as
        // BottomTabBubbleView does. Non-interactive elements lose
        // priority to interactive elements during Explore by Touch
        // conflict resolution, so the card behind them wins.
        .accessibilityRemoveTraits(.isButton)
        .accessibilityHint(hint)
        .accessibilityFocused($focusedTabId, equals: item.id)
    }

    var body: some View {
        // ── Scrollable content ───────────────────────────────────────────────
        // BUG 1: .accessibilityElement(children: .contain) turns this VStack into
        //         a full-screen iOS accessibility container. iOS hit-testing enters
        //         the container first and never exits to check the tab bar overlay.
        // BUG 2: No bottom safe-area inset — card frames extend into the tab bar
        //         zone, so iOS always finds a card when probing that region.
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
        // BUG 1: Creates a full-screen accessibility container.
        // The tab bar overlay declared next is OUTSIDE this container;
        // iOS hit-testing never reaches it when a card frame fills that zone.
        .accessibilityElement(children: .contain)
        // ── Custom liquid glass tab bar ───────────────────────────────────────
        // Placed as .overlay(alignment: .bottom) AFTER .accessibilityElement(children: .contain)
        // — exactly matching GlobalHeaderAndFooterModifier — so the tab bar lives
        // OUTSIDE the accessibility container.
        .overlay(alignment: .bottom) {
            HStack(spacing: 0) {
                ForEach(tabBarItems) { item in
                    tabButton(for: item)
                }
            }
            .padding(.horizontal, 4)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().strokeBorder(.primary.opacity(0.08), lineWidth: 0.5))
            .shadow(color: .black.opacity(0.14), radius: 16, x: 0, y: 4)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
            // BUG 2 (part): clips to a Rectangle, matching UnifiedNavigationBottomBarView —
            // the frame boundary that confines the tab bar's accessibility region.
            .clipShape(Rectangle())
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
