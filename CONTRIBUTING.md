# Contributing Guidelines

Thank you for wanting to explore and contribute to ios-swiftui-accessibility-techniques!

## Sign CLA

Before contributing to this CVS Health sponsored project, you will need to sign the associated [Contributor License Agreement](https://forms.office.com/r/tvFjdsisT2).

## Submitting a Pull Request

We work using forks and Pull Requests.

In order to submit a PR for ios-swiftui-accessibility-techniques, one must fork the repository and submit the PR from there.

Please make sure your fork is up-to-date with the ios-swiftui-accessibility-techniques's latest _main_ branch.

## Accessibility Snapshot Testing

We use AccessibilitySnapshot with SnapshotTesting to capture accessibility tree snapshots.

Local workflow:
1. Switch the test recording mode to re-record snapshots:
   - In `iOSswiftUIa11yTechniquesTests/AccessibilitySnapshotTests.swift`, change
     `withSnapshotTesting(record: .never)` to `withSnapshotTesting(record: .all)`.
2. Run the `iOSswiftUIa11yTechniquesTests` test target on an iOS Simulator.
3. Commit the generated snapshots under:
   - `iOSswiftUIa11yTechniques/iOSswiftUIa11yTechniquesTests/__Snapshots__/`
4. Switch back to `withSnapshotTesting(record: .never)` and re-run tests.

CI runs snapshot tests in verify mode only and will fail if snapshots do not match.
