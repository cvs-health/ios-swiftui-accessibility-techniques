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
import UIKit

struct PageTitlesView: View {
    
    @State private var pageTitle: String = "Page Titles"

    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack {
                Text("Page titles must describe the purpose of the page and be unique for each page in the app. Use `.navigationTitle` to create a title for each page. VoiceOver will speak the page title as a Heading. The page title can be updated using a variable.")
                    .padding([.bottom])
                Text("Good Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                Text("Good Example `.navigationTitle`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                NavigationLink(destination: PageTitleGood()) {
                    Text("Page Titles Good Example")
                }.padding().frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The first good page title example uses `.navigationTitle` to create a page title that describes the purpose of the page.")
                }.padding(.bottom).accessibilityHint("Good Example `.navigationTitle`")
                Text("Good Example dynamic variable `.navigationTitle`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button(action: {
                        self.pageTitle = "New Page Title"
                    }) {
                        Text("Update Page Title")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading).padding()
                DisclosureGroup("Details") {
                    Text("The second good page title example uses a variable for the value of the `.navigationTitle` which is dynamically updated after tapping the Button.")
                }.padding(.bottom).accessibilityHint("Good Example dynamic variable `.navigationTitle`")
                Text("Good Example long `.navigationTitle` that shrinks to fit")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                NavigationLink(destination: PageTitleLongGood()) {
                    Text("Page Titles Long Title Good Example")
                }.padding().frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The third good page title example has a long `.navigationTitle` that would otherwise truncate with an ellipsis. It applies `.navigationTitleFitsWidth()`, which sets `adjustsFontSizeToFitWidth` and a `minimumScaleFactor` directly on the navigation bar's title label so the whole title stays readable. Setting those through `UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self])` worked up to iOS 26 but is ignored on iOS 27.")
                }.padding(.bottom).accessibilityHint("Good Example long `.navigationTitle` that shrinks to fit")
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
                NavigationLink(destination: PageTitleBad()) {
                    Text("Page Titles Bad Example")
                }.padding().frame(maxWidth: .infinity, alignment: .leading)
                DisclosureGroup("Details") {
                    Text("The bad page title example does not use a `.navigationTitle` to create a page title.")
                }.padding(.bottom).accessibilityHint("Bad Example")
            }
            .padding()
            //.navigationTitle("Page Titles")//static title
            //.navigationTitle($pageTitle)//editable title
            .navigationTitle(pageTitle)//dynamic title
        }
 
    }
}
 
#Preview {
    NavigationStack {
        PageTitlesView()
    }
}

struct PageTitleLongGood: View {

    var body: some View {
        ScrollView {
            VStack {
                Text("This page has a long title that does not fit the width of the navigation bar. Instead of truncating with an ellipsis, the title shrinks until the whole thing fits, so a sighted user can still read which page they are on.")
            }
            .padding()
            .navigationTitle("Additional Information About This Service or Data")
            .navigationTitleFitsWidth()
        }
    }
}

#Preview {
    NavigationStack {
        PageTitleLongGood()
    }
}

/// Shrinks the navigation bar title to fit instead of truncating it.
///
/// `UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self])` was enough through
/// iOS 26, but iOS 27 no longer applies `UIAppearance` values to the navigation bar's title label.
/// The label is still an ordinary `UILabel` under the bar, so setting the properties on it
/// directly still works. Re-applied on `layoutSubviews` so it survives pushes and rotation, and a
/// no-op when no navigation bar is found.
private struct NavigationTitleFitsWidth: UIViewRepresentable {
    let minimumScaleFactor: CGFloat

    func makeUIView(context: Context) -> UIView {
        TitleLabelConfigurer(minimumScaleFactor: minimumScaleFactor)
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        (uiView as? TitleLabelConfigurer)?.apply()
    }

    final class TitleLabelConfigurer: UIView {
        private let minimumScaleFactor: CGFloat

        init(minimumScaleFactor: CGFloat) {
            self.minimumScaleFactor = minimumScaleFactor
            super.init(frame: .zero)
            isUserInteractionEnabled = false
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            apply()
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            apply()
        }

        func apply() {
            var responder: UIResponder? = self
            while let current = responder, !(current is UIViewController) {
                responder = current.next
            }
            guard let navigationBar = (responder as? UIViewController)?.navigationController?.navigationBar else { return }
            configure(navigationBar)
        }

        /// Deliberately leaves `lineBreakMode` alone. Setting `.byClipping` removes the ellipsis,
        /// so a title that still overflows at the minimum scale is cut mid-word instead.
        private func configure(_ view: UIView) {
            if let label = view as? UILabel {
                label.adjustsFontSizeToFitWidth = true
                label.minimumScaleFactor = minimumScaleFactor
            }
            view.subviews.forEach(configure)
        }
    }
}

extension View {
    /// Shrinks a long `.navigationTitle` to fit rather than truncating it.
    ///
    /// - Parameter minimumScaleFactor: How far the title may shrink. `0.5` still truncates a
    ///   49-character title on a 6.3" screen; `0.3` fits it. Shrinking trades an ellipsis for
    ///   smaller text, so prefer a shorter title where the copy allows one.
    func navigationTitleFitsWidth(minimumScaleFactor: CGFloat = 0.3) -> some View {
        background(
            NavigationTitleFitsWidth(minimumScaleFactor: minimumScaleFactor)
                .frame(width: 0, height: 0)
                .accessibilityHidden(true)
        )
    }
}
