/*
   Copyright 2023-2025 CVS Health and/or one of its affiliates

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

struct ContentView: View {
    @State private var searchKeyword = ""
    @State private var selection: UUID?

    var filteredAndSortedItems: [Techniques] {
        let filtered = techniques.filter { item in
            searchKeyword.isEmpty || item.name.lowercased().contains(searchKeyword.lowercased())
        }
        return filtered.sorted { $0.name < $1.name }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredAndSortedItems) { technique in
                    NavigationLink(value: technique.id) {
                        Text(technique.name)
                    }
                }
            }
            .navigationTitle("SwiftUI A11y Techniques")
            .navigationViewStyle(.stack)
            .searchable(text: $searchKeyword, placement: .navigationBarDrawer(displayMode: .always))
            .onChange(of: searchKeyword) {
                postAccessibilityAnnouncement()
            }
            .navigationDestination(for: UUID.self) { id in
                if let technique = techniques.first(where: { $0.id == id }) {
                    getItemDetailView(for: technique)
                        .navigationTitle(technique.name)
                }
            }
        }
    }

    @ViewBuilder
    private func getItemDetailView(for technique: Techniques) -> some View {
        switch technique.name.lowercased() {
        case "informative": InformativeView()
        case "decorative": DecorativeView()
        case "functional": FunctionalView()
        case "accessibility hidden": AccessibilityHidden()
        case "accessibility notifications": AccessibilityNotificationsView()
        case "accessibility sort priority": AccessibilitySortPriority()
        case "accessibility representation": AccessibilityRepresentationView()
        case "accessibility actions": ActionsView()
        case "accessibility identifier": AccessibilityIdentifier()
        case "accordions": AccordionsView()
        case "adjustable action": AdjustableActionView()
        case "alerts": AlertsView()
        case "accessibility detection": ATdetectionView()
        case "attributed strings": AttributedStringsView()
        case "assistive access": AssistiveAccessView()
        case "buttons": ButtonsView()
        case "cards": CardsView()
        case "carousels": CarouselView()
        case "checkboxes": CheckboxesView()
        case "combining focus": CombiningFocusView()
        case "confirmation dialogs": ConfirmationDialogsView()
        case "data tables": DataTablesView()
        case "date & time pickers": DateTimePickersView()
        case "decorative images": DecorativeView()
        case "device orientation": DeviceOrientationView()
        case "dynamic type": DynamicTypeView()
        case "error validation": ErrorValidationView()
        case "escape action": EscapeView()
        case "focus management": FocusManagementView()
        case "functional images": FunctionalView()
        case "grouping controls": GroupingControlsView()
        case "headings": HeadingsView()
        case "horizontal scroll views": HorizontalScrollView()
        case "informative images": InformativeView()
        case "input instructions": InputInstructionsView()
        case "accessibility input labels": InputLabelsView()
        case "language": LanguageView()
        case "large content viewer": LargeContentViewerView()
        case "links": LinksView()
        case "lists": ListsView()
        case "magic tap": MagicTapView()
        case "maps": MapView()
        case "meaningful accessible names": MeaningfulAccessibleNamesView()
        case "menus": MenusView()
        case "navigation": NavigationLinkView()
        case "page titles": PageTitlesView()
        case "pickers": PickersView()
        case "popovers": PopoversView()
        case "progress indicators": ProgressIndicatorsView()
        case "prototypes": PrototypesView()
        case "radio buttons": RadioButtonsView()
        case "reading order": ReadingOrderView()
        case "redundant entry": RedundantEntryView()
        case "responsive layouts": ResponsiveLayoutsView()
        case "accessibility rotor": RotorView()
        case "scroll views": ScrollViews()
        case "search suggestions": SearchSuggestionsView()
        case "segmented controls": SegmentedControlsView()
        case "sheets": SheetsView()
        case "sliders": SlidersView()
        case "steppers": SteppersView()
        case "tabs": TabsView()
        case "text fields": TextFieldsView()
        case "toggles": TogglesView()
        case "touch target size": TouchTargetSize()
        case "voiceover announcement delay": VoiceOverAnnouncementDelayView()
        case "voiceover pronunciation": VoiceOverPronunciationView()
        case "dark mode": DarkModeView()
        case "increase contrast": IncreaseContrastView()
        case "reduce motion": ReduceMotionView()
        case "reduce transparency": ReduceTransparencyView()
        case "smart invert": SmartInvertView()
        default: InformativeView()
        }
    }

    func postAccessibilityAnnouncement() {
        let count = filteredAndSortedItems.count
        if count > 0 {
            let message = "\(count) suggestion\(count != 1 ? "s" : "") shown"
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
