/*
   Copyright 2024 CVS Health and/or one of its affiliates

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
import SafariServices


struct WebView: View {
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        WebViewRepresentable(url: "https://pauljadam.com/demos/apple-system-css-font.html")
            .edgesIgnoringSafeArea(.all)
//        Button("Present SFSafariViewController") {
//                    // 1
//                    let vc = SFSafariViewController(url: URL(string: "https://pauljadam.com/demos/apple-system-css-font.html")!)
//
//                    // 2
//                    UIApplication.shared.firstKeyWindow?.rootViewController?.present(vc, animated: true)
//                }
    }
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WebView()
        }
    }
}

struct WebViewRepresentable: UIViewRepresentable {
    var url: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: URL(string: url)!))
    }
}


extension UIApplication {
    // 3
    var firstKeyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.keyWindow
    }
}
