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
import WebKit

struct WebViewDynamicTypeView: View {
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    private let goodHTML = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0">
    <style>
      body { font: -apple-system-body; padding: 16px; margin: 0; }
      h1 { font: -apple-system-headline; margin-top: 0; margin-bottom: 8px; }
      code { font: -apple-system-caption1; background: rgba(128,128,128,0.2); padding: 2px 4px; border-radius: 3px; }
      @media (prefers-color-scheme: dark) { body { background: #1c1c1e; color: #f2f2f7; } }
    </style>
    </head>
    <body>
    <h1>Article Heading</h1>
    <p>This paragraph uses <code>font: -apple-system-body</code> and scales with the user's Dynamic Type text size settings.</p>
    </body>
    </html>
    """

    private let badHTML = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
      body { font-family: -apple-system; font-size: 16px; padding: 16px; margin: 0; }
      h1 { font-family: -apple-system; font-size: 24px; margin-top: 0; margin-bottom: 8px; }
      code { background: rgba(128,128,128,0.2); padding: 2px 4px; border-radius: 3px; }
      @media (prefers-color-scheme: dark) { body { background: #1c1c1e; color: #f2f2f7; } }
    </style>
    </head>
    <body>
    <h1>Article Heading</h1>
    <p>This paragraph uses a fixed <code>font-size: 16px</code> and does not scale with the user's Dynamic Type text size settings.</p>
    </body>
    </html>
    """

    @State private var goodWebViewHeight: CGFloat = 100
    @State private var badWebViewHeight: CGFloat = 100

    var body: some View {
        ScrollView {
            VStack {
                Text("Use the CSS `-apple-system-body` font shorthand (and other `-apple-system-*` shorthands like `-apple-system-headline`) in web view HTML so that text automatically scales when the user changes their Dynamic Type text size in iOS Settings. Use the SwiftUI `.id(dynamicTypeSize)` modifier on the web view to reload it when Dynamic Type changes so the updated font size takes effect. Avoid fixed pixel font sizes like `font-size: 16px` which ignore the user's text size preference.")
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
                Text("Good Example CSS `font: -apple-system-body`")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                WebViewHTMLRepresentable(htmlString: goodHTML, height: $goodWebViewHeight)
                    .id(dynamicTypeSize)
                    .frame(height: goodWebViewHeight)
                    .accessibilityIdentifier("goodWebView")
                DisclosureGroup("Details") {
                    Text("The good example uses the CSS font shorthand `font: -apple-system-body` in the web view HTML. This maps to the iOS system body text style and reads the user's current Dynamic Type size when the page loads. The SwiftUI `.id(dynamicTypeSize)` modifier forces the web view to reload whenever the user changes their Dynamic Type setting, ensuring the new font size is applied immediately. The web view height is measured via JavaScript after each load so the frame always fits the content.")
                }.padding(.bottom).accessibilityHint("Good Example CSS font: -apple-system-body")
                Text("Bad Examples")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                Text("Bad Example CSS `font-size: 16px` fixed pixel font")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                WebViewHTMLRepresentable(htmlString: badHTML, height: $badWebViewHeight)
                    .frame(height: badWebViewHeight)
                    .accessibilityIdentifier("badWebView")
                DisclosureGroup("Details") {
                    Text("The bad example uses a fixed pixel size `font-size: 16px` in the web view HTML. This hardcoded value does not respond to the user's Dynamic Type text size setting in iOS Settings, so the text remains the same size regardless of the user's preference.")
                }.padding(.bottom).accessibilityHint("Bad Example CSS font-size: 16px fixed pixel font")
            }
            .padding()
            .navigationTitle("Web View Dynamic Type")
        }
    }
}

#Preview {
    NavigationStack {
        WebViewDynamicTypeView()
    }
}

struct WebViewHTMLRepresentable: UIViewRepresentable {
    var htmlString: String
    @Binding var height: CGFloat

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlString, baseURL: nil)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewHTMLRepresentable

        init(_ parent: WebViewHTMLRepresentable) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.body.scrollHeight") { result, _ in
                if let height = result as? CGFloat {
                    DispatchQueue.main.async {
                        self.parent.height = height
                    }
                }
            }
        }
    }
}

struct WebViewRepresentable: UIViewRepresentable {
    var url: String

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: URL(string: url)!))
    }
}
