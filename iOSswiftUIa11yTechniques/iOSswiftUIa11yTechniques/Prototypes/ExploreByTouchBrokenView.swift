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
            // BUG: .padding(.top, 32) mirrors UnifiedNavigationTabBarView's
            // 32 pt empty zone above the pill buttons. Explore by Touch in
            // that zone has no accessibility elements and falls through to
            // the scroll content beneath it.
            VStack {
                Spacer()
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
                // BUG: 32 pt empty zone above the pill, matching CVS's tab bar.
                // No accessibility elements exist here — Explore by Touch falls through.
                .padding(.top, 32)
            }
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
