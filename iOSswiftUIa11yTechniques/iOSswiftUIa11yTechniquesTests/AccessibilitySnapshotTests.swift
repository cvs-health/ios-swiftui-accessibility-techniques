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

import AccessibilitySnapshot
import SnapshotTesting
import SwiftUI
import XCTest
@testable import iOSswiftUIa11yTechniques

@MainActor
final class AccessibilitySnapshotTests: XCTestCase {
    private let snapshotSize = CGSize(width: 390, height: 844)

    override func invokeTest() {
        // Switch to .all when you want to re-record snapshots.
        withSnapshotTesting(record: .all) {
            super.invokeTest()
        }
    }

    func testInformativeViewAccessibilitySnapshot() {
        assertAccessibilitySnapshot(for: InformativeView())
    }
    
    func testErrorValidationViewAccessibilitySnapshot() {
        let view = ErrorValidationView(configA11ySnapshot: true)
        assertAccessibilitySnapshot(for: view)
    }


    func testButtonsViewAccessibilitySnapshot() {
        assertAccessibilitySnapshot(for: ButtonsView())
        
        // Don't show any indicators.
        // assertSnapshot(of: ButtonsView(), as: .accessibilityImage(showActivationPoints: .never))
    }

    private func assertAccessibilitySnapshot(for view: some View, file: StaticString = #file, testName: String = #function) {
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(origin: .zero, size: snapshotSize)
        hostingController.view.backgroundColor = .systemBackground
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()

        assertSnapshot(
            matching: hostingController,
            as: .accessibilityImage,
            file: file,
            testName: testName
        )
    }
}

