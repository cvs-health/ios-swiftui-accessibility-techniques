/*
   Copyright 2023-2026 CVS Health and/or one of its affiliates

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
import WebKit

/// Publishes the documentation web view's navigation state so SwiftUI can drive
/// visible Back and Forward buttons, and forwards their actions to the web view.
final class DocsWebViewStore: ObservableObject {
    @Published var canGoBack = false
    @Published var canGoForward = false

    fileprivate weak var webView: WKWebView?

    func goBack() {
        webView?.goBack()
    }

    func goForward() {
        webView?.goForward()
    }
}

struct WebViewDocs: UIViewRepresentable {
    let url: URL
    let store: DocsWebViewStore

    func makeCoordinator() -> Coordinator {
        Coordinator(store: store)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        // Horizontal swipes navigate the back-forward list. This is a path-based
        // gesture, so the visible Back and Forward buttons are required as the
        // single-pointer alternative (WCAG 2.5.1). VoiceOver consumes one-finger
        // horizontal swipes for element navigation, so the gesture never reaches
        // WebKit for VoiceOver users and the buttons are their only route.
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = context.coordinator
        store.webView = webView
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Intentionally empty. Loading the URL here would reload the root page
        // and discard the back-forward list on every SwiftUI update.
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        private let store: DocsWebViewStore

        init(store: DocsWebViewStore) {
            self.store = store
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            syncNavigationState(webView)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            syncNavigationState(webView)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            syncNavigationState(webView)
        }

        private func syncNavigationState(_ webView: WKWebView) {
            store.canGoBack = webView.canGoBack
            store.canGoForward = webView.canGoForward
        }
    }
}


struct ContentView: View {
    @State private var searchKeyword = ""
    @State private var selection: UUID?
    @State private var showingWebPage = false
    @StateObject private var docsStore = DocsWebViewStore()
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let url = URL(string: "https://github.com/cvs-health/ios-swiftui-accessibility-techniques?tab=readme-ov-file#accessibility-techniques-documentation")!
    @AccessibilityFocusState private var isTriggerFocused: Bool


    var filteredAndSortedItems: [Techniques] {
        let filtered = techniques.filter { item in
            searchKeyword.isEmpty || item.name.lowercased().contains(searchKeyword.lowercased())
        }
        return filtered.sorted { $0.name < $1.name }
    }

    var groupedItems: [(String, [Techniques])] {
        let dict = Dictionary(grouping: filteredAndSortedItems) { technique in
            String(technique.name.prefix(1)).uppercased()
        }
        return dict.sorted { $0.key < $1.key }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedItems, id: \.0) { letter, items in
                    Section {
                        ForEach(items) { technique in
                            NavigationLink(value: technique.id) {
                                Text(technique.name)
                            }
                        }
                    } header: {
                        Text(letter)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("SwiftUI A11y Techniques")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingWebPage.toggle()
                    }) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .accessibilityLabel(Text("Documentation"))
                    }
                    .accessibilityFocused($isTriggerFocused)
                    .accessibilityShowsLargeContentViewer {
                        Label("Documentation", systemImage: "doc.text.magnifyingglass")
                    }

                }
            }
            .navigationViewStyle(.stack)
            //.searchable(text: $searchKeyword, prompt:"") //hides the search input prompt placeholder text
            .searchable(text: $searchKeyword,)
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
        //present sheet fullscreen
        .fullScreenCover(isPresented: $showingWebPage, onDismiss: didDismiss) {
            VStack(spacing: 0) {
                // Back and Forward are the non-gesture alternative to the web
                // view's swipe navigation. They disable when there is nowhere to
                // go, so VoiceOver announces them as dimmed rather than leaving a
                // control that silently does nothing.
                if dynamicTypeSize.isAccessibilitySize {
                    // Side by side, these labels wrap to one letter per line at
                    // accessibility text sizes. Stacking them keeps each word on
                    // one line and readable.
                    VStack(alignment: .leading, spacing: 4) {
                        docsBackButton
                        docsForwardButton
                        docsCloseButton
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                } else {
                    HStack(spacing: 16) {
                        docsBackButton
                        docsForwardButton
                        Spacer()
                        docsCloseButton
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                Divider()
                WebViewDocs(url: url, store: docsStore)
            }
        }

    }

    // minHeight sits on each label, not on the surrounding stack. Sizing the row
    // alone leaves each button's hit area only as tall as its text, under the
    // 44pt touch target.
    private var docsBackButton: some View {
        Button(action: {
            docsStore.goBack()
        }) {
            Label("Back", systemImage: "chevron.backward")
                .frame(minHeight: 44)
        }
        .disabled(!docsStore.canGoBack)
    }

    private var docsForwardButton: some View {
        Button(action: {
            docsStore.goForward()
        }) {
            Label("Forward", systemImage: "chevron.forward")
                .frame(minHeight: 44)
        }
        .disabled(!docsStore.canGoForward)
    }

    private var docsCloseButton: some View {
        Button(action: {
            showingWebPage = false
        }) {
            Label("Close", systemImage: "xmark")
                .frame(minHeight: 44)
        }
        .accessibilityLabel("Close Documentation")
    }

    @ViewBuilder
    private func getItemDetailView(for technique: Techniques) -> some View {
        switch technique.name.lowercased() {
        case "informative": InformativeView()
        case "decorative": DecorativeView()
        case "functional": FunctionalView()
        case "accessibility hidden": AccessibilityHidden()
        case "accessibility hint": AccessibilityHintView()
        case "accessibility label": AccessibilityLabelView()
        case "accessibility value": AccessibilityValueView()
        case "accessibility notifications": AccessibilityNotificationsView()
        case "accessibility sort priority": AccessibilitySortPriority()
        case "accessibility representation": AccessibilityRepresentationView()
        case "accessibility responds to user interaction": AccessibilityRespondsToUserInteraction()
        case "accessibility actions": ActionsView()
        case "accessibility traits": AccessibilityTraitsView()
        case "accessibility identifier": AccessibilityIdentifier()
        case "accessibility custom content": AccessibilityCustomContentView()
        case "accordions": AccordionsView()
        case "adjustable action": AdjustableActionView()
        case "alerts": AlertsView()
        case "accessibility detection": ATdetectionView()
        case "attributed strings": AttributedStringsView()
        case "assistive access": AssistiveAccessView()
        case "buttons": ButtonsView()
        case "cards": CardsView()
        case "charts": ChartsView()
        case "carousels": CarouselView()
        case "containers": ContainersView()
        case "contrast": ContrastView()
        case "checkboxes": CheckboxesView()
        case "combining focus": CombiningFocusView()
        case "confirmation dialogs": ConfirmationDialogsView()
        case "data tables": DataTablesView()
        case "date & time pickers": DateTimePickersView()
        case "decorative images": DecorativeView()
        case "device orientation": DeviceOrientationView()
        case "dim flashing lights": DimFlashingLightsView()
        case "drag & drop": DragDropView()
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
        case "motion actuation": MotionActuationView()
        case "multi-selection lists": MultiSelectionListView()
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
        case "swiftlint": SwiftLintView()
        case "tabs": TabsView()
        case "videos": VideosView()
        case "web view dynamic type": WebViewDynamicTypeView()
        case "text fields": TextFieldsView()
        case "toggles": TogglesView()
        case "tipkit": TipKitView()
        case "toolbars": ToolbarView()
        case "touch target size": TouchTargetSize()
        case "voiceover announcement delay": VoiceOverAnnouncementDelayView()
        case "voiceover pronunciation": VoiceOverPronunciationView()
        case "dark mode": DarkModeView()
        case "increase contrast": IncreaseContrastView()
        case "reduce motion": ReduceMotionView()
        case "reduce transparency": ReduceTransparencyView()
        case "smart invert": SmartInvertView()
        case "a11y-check": A11yCheckView()
        case "xctest accessibility": XCTestAccessibilityView()
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
    
    func didDismiss() {
        isTriggerFocused = true
    }

}

#Preview {
    ContentView()
}
