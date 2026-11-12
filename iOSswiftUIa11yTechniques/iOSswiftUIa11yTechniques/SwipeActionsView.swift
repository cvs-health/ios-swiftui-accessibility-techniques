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

/// One row of the demo inbox. `isUnread` and `isFlagged` are the state the swipe actions
/// and the Select mode action bar both change, so the two paths can be compared directly.
private struct InboxMessage: Identifiable {
    let id = UUID()
    let sender: String
    let subject: String
    var isUnread: Bool
    var isFlagged: Bool
}

private let inboxMessages: [InboxMessage] = [
    InboxMessage(sender: "Order Updates", subject: "Your package has shipped", isUnread: true, isFlagged: false),
    InboxMessage(sender: "Calendar", subject: "Your appointment is confirmed for Friday", isUnread: true, isFlagged: false),
    InboxMessage(sender: "Newsletter", subject: "This week's top stories", isUnread: false, isFlagged: false),
    InboxMessage(sender: "Billing", subject: "Action needed to update your payment method", isUnread: false, isFlagged: true)
]

struct SwipeActionsView: View {
    @State private var goodMessages = inboxMessages
    @State private var badMessages = inboxMessages
    @State private var goodSelection = Set<UUID>()
    @State private var goodEditMode: EditMode = .inactive

    /// The nested `List` has to be given a height inside a `ScrollView`. 300 laid out only
    /// three of the four rows and left the fourth behind an inner scroll, so this is sized
    /// to fit all four and scaled with the text size to keep fitting them.
    @ScaledMetric(relativeTo: .body) private var listHeight: CGFloat = 400

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    private var darkOrange = Color(red: 184 / 255, green: 89 / 255, blue: 0 / 255)
    private var darkBlue = Color(red: 0 / 255, green: 85 / 255, blue: 179 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Swipe actions are a path-based gesture. `.swipeActions` is exposed to VoiceOver automatically as custom actions, but a gesture is still the only way a sighted user can reach it, so the same functionality has to be available somewhere a single tap can get to it. Follow the iOS Mail pattern: a `Select` button that turns on `EditMode`, selects rows with single taps, and runs the same actions from a visible action bar.")
                    .padding(.bottom)
                Text("Good Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                HStack {
                    Text("Inbox")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityAddTraits(.isHeader)
                    Button(goodEditMode == .active ? "Done" : "Select") {
                        if goodEditMode == .active {
                            goodEditMode = .inactive
                            goodSelection.removeAll()
                        } else {
                            goodEditMode = .active
                        }
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel(goodEditMode == .active ? "Done Selecting Inbox Messages" : "Select Inbox Messages")
                }
                List(selection: $goodSelection) {
                    ForEach($goodMessages) { $message in
                        messageRow(message)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    goodMessages.removeAll { $0.id == message.id }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(darkRed)
                                Button {
                                    message.isFlagged.toggle()
                                } label: {
                                    Label(message.isFlagged ? "Unflag" : "Flag", systemImage: message.isFlagged ? "flag.slash" : "flag")
                                }
                                .tint(darkOrange)
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    message.isUnread.toggle()
                                } label: {
                                    Label(message.isUnread ? "Mark as Read" : "Mark as Unread", systemImage: message.isUnread ? "envelope.open" : "envelope.badge")
                                }
                                .tint(darkBlue)
                            }
                            .accessibilityHint("Actions available to mark as read, flag, or delete")
                    }
                }
                .environment(\.editMode, $goodEditMode)
                .listStyle(.insetGrouped)
                .frame(height: listHeight)
                if goodEditMode == .active {
                    HStack {
                        actionBarButton("Mark as Read", systemImage: "envelope.open", label: selectionLabel("Mark", suffix: " as Read")) {
                            applyToSelection { $0.isUnread = false }
                        }
                        Spacer()
                        actionBarButton("Flag", systemImage: "flag", label: selectionLabel("Flag")) {
                            applyToSelection { $0.isFlagged = true }
                        }
                        Spacer()
                        actionBarButton("Delete", systemImage: "trash", label: selectionLabel("Delete"), isDestructive: true) {
                            goodMessages.removeAll { goodSelection.contains($0.id) }
                            goodSelection.removeAll()
                        }
                    }
                    .padding(.horizontal)
                    .disabled(goodSelection.isEmpty)
                }
                DisclosureGroup("Details") {
                    Text("The good example gives every swipe action a second, gesture-free path. The `Select` button sets `EditMode` to `.active` through `.environment(\\.editMode, $goodEditMode)`, which turns the `List(selection:)` rows into single-tap selection targets, and the action bar below runs Mark as Read, Flag, and Delete on whatever is selected. No `.accessibilityAction` is needed: SwiftUI already publishes the `.swipeActions` buttons to VoiceOver, Switch Control, Full Keyboard Access, and Voice Control as custom actions. What those menus cannot help with is a sighted user who cannot complete a swipe, which is why the visible button path is the part that satisfies 2.5.1. The action bar buttons name their target, e.g. `Delete 2 Selected Messages`, so the count is spoken rather than only drawn.")
                }.padding(.bottom).accessibilityHint("Good Example")
                Text("Bad Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                Text("Inbox")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                List {
                    ForEach($badMessages) { $message in
                        messageRow(message)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    badMessages.removeAll { $0.id == message.id }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(darkRed)
                                Button {
                                    message.isFlagged.toggle()
                                } label: {
                                    Label(message.isFlagged ? "Unflag" : "Flag", systemImage: message.isFlagged ? "flag.slash" : "flag")
                                }
                                .tint(darkOrange)
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    message.isUnread.toggle()
                                } label: {
                                    Label(message.isUnread ? "Mark as Read" : "Mark as Unread", systemImage: message.isUnread ? "envelope.open" : "envelope.badge")
                                }
                                .tint(darkBlue)
                            }
                            .accessibilityHint("Actions available to mark as read, flag, or delete")
                    }
                }
                .listStyle(.insetGrouped)
                .frame(height: listHeight)
                DisclosureGroup("Details") {
                    Text("The bad example has the same three swipe actions and no `Select` button, so there is no `EditMode`, no selection, and no action bar. Delete, Flag, and Mark as Read exist only behind a horizontal drag across a row, which fails 2.5.1 Pointer Gestures and 2.5.7 Dragging Movements. The VoiceOver Actions menu is not the missing alternative. It is present here, because `.swipeActions` publishes it for free, and it does nothing for the users this criterion is written for: someone with a tremor, a hand splint, a head pointer, or a switch-adapted mouse who is not running an assistive technology at all. Add the `Select` button, or give each row a visible overflow menu, and the functionality stops depending on the gesture.")
                }.accessibilityHint("Bad Example")
                Button("Reset Messages") {
                    goodMessages = inboxMessages
                    badMessages = inboxMessages
                    goodSelection.removeAll()
                    goodEditMode = .inactive
                }
                .buttonStyle(.bordered)
                .padding(.top)
            }
            .navigationTitle("Swipe Actions")
            .padding()
        }
    }

    @ViewBuilder
    private func messageRow(_ message: InboxMessage) -> some View {
        HStack(alignment: .top) {
            Circle()
                .fill(message.isUnread ? (colorScheme == .dark ? Color(.systemBlue) : darkBlue) : .clear)
                .frame(width: 10, height: 10)
                .padding(.top, 6)
                .accessibilityHidden(true)
            VStack(alignment: .leading) {
                Text(message.sender)
                    .fontWeight(message.isUnread ? .bold : .regular)
                Text(message.subject)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if message.isFlagged {
                Image(systemName: "flag.fill").accessibilityHidden(true)
                    .foregroundColor(colorScheme == .dark ? Color(.systemOrange) : darkOrange)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue(statusValue(message))
    }

    @ViewBuilder
    private func actionBarButton(
        _ title: String,
        systemImage: String,
        label: String,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: systemImage).accessibilityHidden(true)
                Text(title)
                    .font(.caption)
            }
            .frame(minWidth: 44, minHeight: 44)
        }
        .accessibilityLabel(label)
        .foregroundColor(isDestructive ? (colorScheme == .dark ? Color(.systemRed) : darkRed) : nil)
    }

    /// Unread and flagged are drawn with a dot and a glyph, so they have to be spoken as
    /// the row's value for anyone who cannot see either one.
    private func statusValue(_ message: InboxMessage) -> String {
        var parts: [String] = []
        if message.isUnread {
            parts.append("Unread")
        }
        if message.isFlagged {
            parts.append("Flagged")
        }
        return parts.joined(separator: ", ")
    }

    /// Names what the action will act on, so the selection count reaches VoiceOver
    /// instead of only appearing as filled circles in the list.
    private func selectionLabel(_ verb: String, suffix: String = "") -> String {
        let count = goodSelection.count
        if count == 0 {
            return verb + suffix
        }
        let target = count == 1 ? "1 Selected Message" : "\(count) Selected Messages"
        return "\(verb) \(target)\(suffix)"
    }

    private func applyToSelection(_ change: (inout InboxMessage) -> Void) {
        for index in goodMessages.indices where goodSelection.contains(goodMessages[index].id) {
            change(&goodMessages[index])
        }
    }
}

#Preview {
    NavigationStack {
        SwipeActionsView()
    }
}
