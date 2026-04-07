# Homebrew formula for a11y-check
# Install: brew install --build-from-source a11y-check.rb
#
# To create a tap:
#   1. Create a repo: github.com/cvs-health/homebrew-a11y-check
#   2. Place this formula as Formula/a11y-check.rb
#   3. Users install with: brew tap cvs-health/a11y-check && brew install a11y-check

class A11yCheck < Formula
  desc "SwiftUI accessibility checker — static analysis for iOS accessibility issues mapped to WCAG 2.2"
  homepage "https://github.com/cvs-health/ios-swiftui-accessibility-techniques"
  url "https://github.com/cvs-health/ios-swiftui-accessibility-techniques.git",
      tag: "a11y-check-v0.2.0",
      revision: "HEAD"
  license "Apache-2.0"
  head "https://github.com/cvs-health/ios-swiftui-accessibility-techniques.git", branch: "main"

  depends_on xcode: ["15.0", :build]
  depends_on :macos

  def install
    cd "A11yAgent" do
      system "swift", "build", "-c", "release", "--disable-sandbox"
      bin.install ".build/release/a11y-check"
    end
  end

  test do
    # Create a simple SwiftUI file with an accessibility issue
    (testpath/"Test.swift").write <<~SWIFT
      import SwiftUI
      struct TestView: View {
          var body: some View {
              Image(systemName: "star")
          }
      }
    SWIFT
    output = shell_output("#{bin}/a11y-check #{testpath}/Test.swift --format json 2>&1", 1)
    assert_match "image-missing-label", output
  end
end
