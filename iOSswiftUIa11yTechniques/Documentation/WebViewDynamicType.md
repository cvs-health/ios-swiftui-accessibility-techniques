# Web View Dynamic Type

Use the CSS `-apple-system-body` font shorthand (and other `-apple-system-*` shorthands) in web view HTML so that text automatically scales when the user changes their Dynamic Type text size in iOS Settings. Avoid fixed pixel font sizes like `font-size: 16px` which ignore the user's text size preference.

## How It Works

`WKWebView` does not automatically reflow web content when the user changes their Dynamic Type setting at runtime. Two things are required to make web view text respect Dynamic Type:

### 1. Use CSS `-apple-system-*` font shorthands

Apple's WebKit engine exposes the iOS Dynamic Type text styles as CSS font shorthands. These shorthands read the user's current preferred text size when the page loads:

| CSS Font Shorthand | iOS Text Style |
|---|---|
| `font: -apple-system-body` | Body |
| `font: -apple-system-headline` | Headline |
| `font: -apple-system-subheadline` | Subheadline |
| `font: -apple-system-caption1` | Caption 1 |
| `font: -apple-system-caption2` | Caption 2 |
| `font: -apple-system-footnote` | Footnote |
| `font: -apple-system-short-body` | Short Body |
| `font: -apple-system-tall-body` | Tall Body |

Using `font: -apple-system-body` applies both the system font family and a size that matches the user's chosen Dynamic Type level.

### 2. Reload the web view when Dynamic Type changes

Because `WKWebView` only reads the system font size at page load time, it must be reloaded when the user changes their text size setting. In SwiftUI, apply the `.id(dynamicTypeSize)` modifier to the `UIViewRepresentable` wrapper. When `dynamicTypeSize` changes, SwiftUI destroys and recreates the view, causing the web view to reload and pick up the new font size.

```swift
@Environment(\.dynamicTypeSize) var dynamicTypeSize

WebViewHTMLRepresentable(htmlString: htmlContent)
    .id(dynamicTypeSize)
    .frame(height: 200)
```

## Good Example

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0">
<style>
  body { font: -apple-system-body; padding: 16px; margin: 0; }
  h1 { font: -apple-system-headline; margin-top: 0; margin-bottom: 8px; }
  @media (prefers-color-scheme: dark) { body { background: #1c1c1e; color: #f2f2f7; } }
</style>
</head>
<body>
<h1>Article Heading</h1>
<p>This text scales with the user's Dynamic Type settings.</p>
</body>
</html>
```

```swift
struct WebViewHTMLRepresentable: UIViewRepresentable {
    var htmlString: String

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlString, baseURL: nil)
    }
}
```

## Bad Example

```html
<style>
  body { font-family: -apple-system; font-size: 16px; }
  h1 { font-size: 24px; }
</style>
```

Fixed pixel sizes (`font-size: 16px`) are hardcoded values that do not respond to the user's Dynamic Type text size setting. Even if the font family is `-apple-system`, the fixed `font-size` prevents scaling.

## Applicable WCAG Success Criteria
- [1.4.4: Resize Text](https://www.w3.org/WAI/WCAG21/Understanding/resize-text)

## Apple Developer Documentation
- [DynamicTypeSize](https://developer.apple.com/documentation/swiftui/dynamictypesize)
- [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview)

## Swift Technique Source Code
[WebViewDynamicTypeView.swift](../iOSswiftUIa11yTechniques/WebViewDynamicTypeView.swift)

----

Copyright 2026 CVS Health and/or one of its affiliates

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0]()

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and
limitations under the License.
