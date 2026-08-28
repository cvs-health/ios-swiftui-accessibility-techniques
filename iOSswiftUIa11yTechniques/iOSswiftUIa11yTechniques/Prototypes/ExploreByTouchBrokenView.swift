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
    TabBarItem(id: 0, label: "Home",     icon: "house",           selectedIcon: "house.fill"),
    TabBarItem(id: 1, label: "Pharmacy", icon: "cross.case",      selectedIcon: "cross.case.fill"),
    TabBarItem(id: 2, label: "Health",   icon: "heart",           selectedIcon: "heart.fill"),
    TabBarItem(id: 3, label: "Shop",     icon: "bag",             selectedIcon: "bag.fill"),
    TabBarItem(id: 4, label: "Search",   icon: "magnifyingglass", selectedIcon: "magnifyingglass"),
]

// Approximates CVS brand red (action.active.color from PulseTokens)
private let cvsRed = Color(red: 0.80, green: 0.11, blue: 0.11)

// MARK: - Card component

private struct ContentCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)
                .padding(.top, 28)

            Spacer(minLength: 24)

            HStack {
                Spacer()
                Image(systemName: systemImage)
                    .font(.system(size: 80, weight: .light))
                    .foregroundStyle(accentColor)
                    .padding(.bottom, 18)
                    .accessibilityHidden(true)
                Spacer()
            }

            Divider()

            Text(subtitle)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
        }
        .frame(height: 360)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Main view

/// Bad example: replicates the CVS Pharmacy home screen Explore by Touch bug.
///
/// Layout mirrors `H100HomeScreenView` in the CVS codebase:
/// - `ZStack` with the scroll content in the background
/// - `.ignoresSafeArea(edges: .bottom)` on the scroll view so content
///   extends behind the floating tab bar
/// - The tab bar is inside the ZStack (not an overlay modifier), sitting on
///   top of the content in the same layer
///
/// The bug comes from `UnifiedNavigationTabBarView`'s `.padding(.top, 32)`:
/// the tab bar view has 32 pt of empty space above the actual pill buttons.
/// That zone shows the background gradient but has no accessibility elements.
/// When VoiceOver Explore by Touch fires anywhere in the tab bar region
/// (including that empty 32 pt zone) the hit test falls through the empty
/// padding and finds the scroll content element below instead of a tab button.
struct ExploreByTouchBrokenView: View {
    @State private var selectedTab = 0

    var body: some View {
        // BUG: ZStack lets scroll content extend under the floating tab bar.
        // The tab bar has 32 pt of empty padding above its pill buttons,
        // matching UnifiedNavigationTabBarView.body in the CVS codebase.
        // Explore by Touch in that zone hits the scroll content instead of a tab.
        ZStack(alignment: .top) {
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
                // Extra bottom padding so last card scrolls clear of the tab bar
                .padding(.bottom, 100)
            }
            // BUG: content extends behind the floating tab bar, matching
            // segmentedContent.ignoresSafeArea(edges: .bottom) in H100HomeScreenView.
            .ignoresSafeArea(edges: .bottom)

            // Tab bar: sits inside the ZStack on top of the scroll content.
            // Visual matches UnifiedNavigationTabBarView (standard, non-translucent mode):
            // white pill with drop shadows + systemFill highlight on the selected tab.
            VStack(spacing: 0) {
                Spacer()
                tabBarPill
                    // BUG: 32 pt empty zone above the pill, mirrors CVS's
                    // UnifiedNavigationTabBarView's .padding(.top, 32).
                    // No accessibility elements exist here — Explore by Touch falls through
                    // this zone and focuses the scroll content instead of a tab button.
                    .padding(.top, 32)
                    .padding(.bottom, 8)
            }
            // BUG: mirrors UnifiedNavigationTabBarView's .accessibilitySortPriority(-1).
            // SwiftUI builds the accessibility hit-test tree in priority order (higher first).
            // Scroll content has the default priority (0), so its elements are checked before
            // the tab buttons (-1). When a content card's frame overlaps the touch point the
            // content element wins immediately — the tab buttons are never reached.
            .accessibilitySortPriority(-1)
        }
        .navigationTitle("Explore by Touch Broken")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }

    // Floating pill tab bar — mirrors TabsBubbleView.backgroundBubble (standard mode):
    // white rounded-rect + double drop shadow, horizontal padding of 16 pt.
    private var tabBarPill: some View {
        HStack(spacing: 0) {
            ForEach(tabBarItems) { item in
                tabButton(item)
            }
        }
        .padding(2)
        .background {
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: geo.size.height / 2)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.20), radius: 4, x: 0, y: 4)
                    .shadow(color: .black.opacity(0.10), radius: 4, x: 0, y: 1)
            }
        }
        .padding(.horizontal, 16)
    }

    // Individual tab button — matches LeadingTabView (.highlighted) for the selected tab
    // and TabButtonView for the rest. The selected tab gets a systemFill rounded-rect
    // background (cornerRadius: 100) identical to the highlight in TabsBubbleView.tabs.
    @ViewBuilder
    private func tabButton(_ item: TabBarItem) -> some View {
        let isSelected = selectedTab == item.id
        Button {
            selectedTab = item.id
        } label: {
            VStack(spacing: 0) {
                Image(systemName: isSelected ? item.selectedIcon : item.icon)
                    .font(.system(size: 24))
                    .frame(width: 24, height: 24)
                    .padding(4)
                    .padding(.bottom, 2)
                    .accessibilityHidden(true)
                Text(item.label)
                    .font(.system(size: 11))
                    .fontWeight(isSelected ? .medium : .regular)
                    .lineLimit(1)
                    .minimumScaleFactor(1)
                    .padding(.bottom, 7)
            }
            .frame(maxWidth: .infinity, maxHeight: 49)
        }
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: 100)
                    .fill(Color(UIColor.systemFill))
            }
        }
        .foregroundStyle(cvsRed)
        .accessibilityLabel(item.label)
        .accessibilityRemoveTraits(.isButton)
        .accessibilityHint("Double tap to activate")
    }
}

#Preview {
    NavigationStack {
        ExploreByTouchBrokenView()
    }
}
