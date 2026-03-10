# frozen_string_literal: true

class A11yCheck < Formula
  desc "SwiftUI Accessibility Checker — static analysis for iOS accessibility issues"
  homepage "https://github.com/cvs-health/ios-swiftui-accessibility-techniques"
  head "https://github.com/cvs-health/ios-swiftui-accessibility-techniques.git", branch: "main"
  license "Apache-2.0"

  depends_on :macos

  def install
    cd "A11yAgent" do
      system "swift", "build", "-c", "release", "--disable-sandbox"
      bin.install ".build/release/a11y-check"
    end
  end

  test do
    system "#{bin}/a11y-check", "--list-rules"
  end
end
