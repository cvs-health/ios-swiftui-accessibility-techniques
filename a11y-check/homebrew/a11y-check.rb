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
  # Tags in this repository are bare semver — 0.3.0 through 0.7.0 — with no `a11y-check-v`
  # prefix. The previous `tag: "a11y-check-v0.2.0"` named a tag that has never existed, so
  # the stable spec could not resolve and every install fell through to `--HEAD`. Keep this
  # pinned to a tag that `git tag --list` actually shows, with its real commit; `revision:`
  # takes a full 40-character *commit* SHA, not "HEAD".
  #
  # Resolve it with `git rev-parse '0.7.0^{commit}'`, not `git rev-parse 0.7.0`. These are
  # annotated tags, so the bare form returns the tag object (582175c0…) rather than the
  # commit it points at, and Homebrew would reject it.
  url "https://github.com/cvs-health/ios-swiftui-accessibility-techniques.git",
      tag: "0.7.0",
      revision: "cccad9dbfc39f086cfb8ae3acd0af52883c9b5c7"
  license "Apache-2.0"
  head "https://github.com/cvs-health/ios-swiftui-accessibility-techniques.git", branch: "main"

  depends_on xcode: ["15.0", :build]
  depends_on :macos

  def install
    cd "a11y-check" do
      # Stamp the real commit into --version. Without this the installed binary reports the
      # committed placeholder ("unreleased"), and `Examples/XcodeAuditProject` prints
      # --version next to its results precisely so a reader can tell whether an audit ran on
      # a current build. Non-fatal: a tarball install has no .git, and an unstamped binary
      # is still a working one.
      system "./generate-build-info.sh" if File.exist?(".git") || File.exist?("../.git")
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
