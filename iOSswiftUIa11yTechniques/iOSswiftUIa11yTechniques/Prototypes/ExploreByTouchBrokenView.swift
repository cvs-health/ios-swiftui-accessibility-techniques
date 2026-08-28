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
        // Matches CVS ActivityCardView: merges title, image, and subtitle into
        // one focusable element instead of three. VoiceOver announces the whole
        // card as a single button.
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(subtitle)")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Main view

/// Bad example: replicates the CVS Pharmacy home screen Explore by Touch bug.
///
/// Three mechanisms must compound to produce the bug:
///
/// 1. **Scroll content extends behind the tab bar.**
///    `.ignoresSafeArea(edges: .bottom)` on the `ScrollView` makes its UIView
///    frame reach the bottom of the screen, physically overlapping the tab bar
///    region. Matches `segmentedContent.ignoresSafeArea(edges: .bottom)` in
///    `H100HomeScreenView`.
///
/// 2. **Tab bar loses the accessibility priority race.**
///    `.accessibilitySortPriority(-1)` on the tab bar. When multiple
///    accessibility elements sit under a touch point, SwiftUI's hit test
///    walks them in priority order (high → low). Scroll content defaults to
///    priority 0, so it is checked before the tab (-1) and wins. Matches
///    `UnifiedNavigationTabBarView`.
///
/// 3. **Each card is one giant accessibility frame.**
///    `.accessibilityElement(children: .combine)` on `ContentCard` merges
///    title + image + subtitle into a single element whose accessibility
///    frame covers the entire 360 pt card. Without `.combine`, the card's
///    inner text/image frames are small enough that they might not reach
///    the tab bar. With `.combine`, the whole card is one frame — whenever
///    it scrolls near the bottom of the screen it *guarantees* overlap into
///    the tab bar region. Combined with #2, the card wins the hit test.
///    Matches `ActivityCardView`.
///
/// Result: VoiceOver swipe navigation still reaches each tab (the tree order
/// is unchanged), but Explore by Touch — dragging a finger over the tab bar —
/// focuses whichever combined content card sits behind it.
struct ExploreByTouchBrokenView: View {
    @State private var selectedTab = 0
    @State private var isExplanationExpanded = false

    var body: some View {
        // BUG: ZStack lets scroll content extend under the floating tab bar.
        // The tab bar has 32 pt of empty padding above its pill buttons,
        // matching UnifiedNavigationTabBarView.body in the CVS codebase.
        // Explore by Touch in that zone hits the scroll content instead of a tab.
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {

                    bugExplanation

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
            // SwiftUI checks higher-priority accessibility elements first during
            // hit testing. Scroll content has the default priority (0), so its
            // elements are checked before the tab buttons (-1). When a combined
            // card's frame overlaps the touch point the card wins immediately —
            // the tab buttons are never reached. Confirmed empirically: removing
            // this line makes Explore by Touch reach the tabs again.
            .accessibilitySortPriority(-1)
        }
        .navigationTitle("Explore by Touch Broken")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }

    // Info panel explaining the three bug mechanisms shown on this screen.
    // Collapsed by default; users tap the disclosure header to expand.
    private var bugExplanation: some View {
        DisclosureGroup(isExpanded: $isExplanationExpanded) {
            VStack(alignment: .leading, spacing: 12) {
                Text("VoiceOver swipe navigation reaches every tab, but Explore by Touch — dragging a finger over the tab bar — focuses the content card behind it instead of a tab. Three coding choices compound:")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                bugPoint(
                    number: "1",
                    title: "Scroll content extends behind the tab bar.",
                    body: ".ignoresSafeArea(edges: .bottom) on the ScrollView lets its frame reach the bottom of the screen, physically overlapping the tab bar region."
                )
                bugPoint(
                    number: "2",
                    title: "Tab bar loses the accessibility priority race.",
                    body: ".accessibilitySortPriority(-1) on the tab bar. When elements overlap at a touch point, SwiftUI checks higher-priority elements first. Content defaults to 0, so it wins over the tab (-1). Confirmed empirically — removing this line makes tabs reachable again."
                )
                bugPoint(
                    number: "3",
                    title: "Each card is one giant accessibility frame.",
                    body: ".accessibilityElement(children: .combine) merges title + image + subtitle into a single 360 pt frame per card. That combined frame is large enough to overlap into the tab bar region as it scrolls, and combined with #2 it wins the hit test."
                )
            }
            .padding(.top, 12)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                    .accessibilityHidden(true)
                Text("Why the tab bar is unreachable by touch")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
            }
        }
        .tint(.orange)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.35), lineWidth: 1)
        )
    }

    private func bugPoint(number: String, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(number)
                .font(.footnote.bold())
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Color.orange)
                .clipShape(Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.footnote.bold())
                Text(body)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Cause \(number). \(title) \(body)")
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
