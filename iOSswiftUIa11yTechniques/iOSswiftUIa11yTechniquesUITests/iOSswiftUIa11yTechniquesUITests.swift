/*
   Copyright 2023-2025 CVS Health and/or one of its affiliates

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

import XCTest
import SwiftUI

final class iOSswiftUIa11yTechniquesUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testHeadings() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        app.searchFields["Search"].tap()
        app.typeText("Headings")
        app.otherElements.buttons["Headings"].tap()
        // Check existence of good and bad examples with accessibility identifiers
        XCTAssertTrue(app.otherElements.staticTexts["goodHeading"].exists)
        XCTAssertTrue(app.otherElements.staticTexts["badHeading1"].exists)
        XCTAssertTrue(app.otherElements.staticTexts["badHeading2"].exists)
        // XCTAssertTrue(app.otherElements.staticTexts["goodHeading"].accessibilityTraits.contains(.header)) accessibilityTraits CANNOT BE TESTED
        try app.performAccessibilityAudit() // a11y audit passes with false negatives because headings can't be tested
        app.swipeUp() // swipe up and run audit on content below the fold
        try app.performAccessibilityAudit() // contrast fails false positive
    }
    func testInformative() throws {
        // Launch the app to begin testing.
        let app = XCUIApplication()
        app.launch()
        // Check if iPad then tap the Sidebar navigation bar button.
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            app.navigationBars.buttons["ToggleSidebar"].tap()
//        }
        // Tap the navigation buttons to load the specific page to test.
        app.searchFields["Search"].tap()
        app.typeText("Images")
        app.otherElements.buttons["Informative Images"].tap()
        // Check existence of good and bad examples with accessibility identifiers
        XCTAssertTrue(app.otherElements.images["goodImage"].exists)
        XCTAssertTrue(app.otherElements.images["badImage"].exists)
        XCTAssertTrue(app.otherElements["goodIcon"].exists) // goodIcon has its image a11y trait removed because it was combined into other text
        XCTAssertTrue(app.otherElements.images["badIcon"].exists)
        // Check that images do not have empty label
        XCTAssertFalse(app.otherElements.images["goodImage"].label.isEmpty)
        XCTAssertFalse(app.otherElements.images["badImage"].label.isEmpty) // badImage gets its label from the image filename
        XCTAssertTrue(app.otherElements.images["badIcon"].label.isEmpty) // badIcon exists but has empty label
        // Run a11y audit
        try app.performAccessibilityAudit() // EITHER fails a11y audit because badIcon element has no description OR incorrectly test the previous page and passes that but never test this intended page.
    }
    func testDecorative() throws {
        // Launch the app to begin testing.
        let app = XCUIApplication()
        app.launch()
        // Check if iPad then tap the Sidebar navigation bar button.
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            app.navigationBars.buttons["ToggleSidebar"].tap()
//        }
        // Tap the navigation buttons to load the specific page to test.
        app.searchFields["Search"].tap()
        app.typeText("Images")
        app.otherElements.buttons["Decorative Images"].tap()
        // Check existence of good and bad examples with accessibility identifiers
        XCTAssertFalse(app.otherElements.images["goodImage"].exists) // decorative images do not exist and their properties can't be tested
        XCTAssertTrue(app.otherElements.images["badImage"].exists)
        XCTAssertFalse(app.otherElements.images["goodIcon"].exists) // accessibilityHidden images do not exist and their properties can't be tested
        XCTAssertTrue(app.otherElements.images["badIcon"].exists)
        // Check that images do not have empty label
        XCTAssertFalse(app.otherElements.images["badImage"].label.isEmpty) // badImage gets its label from the image filename
        XCTAssertFalse(app.otherElements.images["badIcon"].label.isEmpty) // badIcon gets label from image name
        // Run a11y audit
        try app.performAccessibilityAudit() // passes a11y audit with false negatives because decorative images cannot be tested
    }
    func testFunctional() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        app.searchFields["Search"].tap()
        app.typeText("Images")
        app.otherElements.buttons["Functional Images"].tap()
        // Check existence of good and bad examples with accessibility identifiers
        XCTAssertTrue(app.otherElements.buttons["goodImage"].exists)
        XCTAssertTrue(app.otherElements.buttons["badImage1"].exists)
        XCTAssertTrue(app.otherElements.images["badImage2"].exists)
        // Check labels
        XCTAssertFalse(app.otherElements.buttons["goodImage"].label.isEmpty)
        XCTAssertFalse(app.otherElements.buttons["badImage1"].label.isEmpty) // badImage1 has label from filename
        XCTAssertFalse(app.otherElements.images["badImage2"].label.isEmpty) // badImage2 has label from filename
        // Run a11y audit
        try app.performAccessibilityAudit() // fails a11y audit with label not human-readable on badImage1
    }
    func testButtons() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        app.searchFields["Search"].tap()
        app.typeText("Buttons")
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery/*@START_MENU_TOKEN@*/.buttons["Buttons"]/*[[".cells.buttons[\"Buttons\"]",".buttons[\"Buttons\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // assert elements with accessibilityIdentifiers exist
        XCTAssertTrue(app.otherElements.buttons["edit1good"].exists)
        XCTAssertTrue(app.otherElements.buttons["edit2good"].exists)
        XCTAssertTrue(app.otherElements.buttons["loginGood"].exists)
        XCTAssertTrue(app.otherElements.buttons["edit1bad"].exists)
        XCTAssertTrue(app.otherElements.buttons["edit2bad"].exists)
        XCTAssertTrue(app.otherElements.buttons["loginBad"].exists)

        // test if good and bad login buttons have a disabled state
        XCTAssertFalse(app.otherElements.buttons["loginGood"].isEnabled)
        //XCTAssertFalse(app.otherElements.buttons["loginBad"].isEnabled) // assert fails because there is no disabled state on the bad login button

        // test if the good and bad edit buttons have the same generic label text
        XCTAssertNotEqual(app.otherElements.buttons["edit1good"].label, app.otherElements.buttons["edit2good"].label)
        //XCTAssertNotEqual(app.otherElements.buttons["edit1bad"].label, app.otherElements.buttons["edit2bad"].label) // assert fails because the two bad edit buttons have the same .label

        // test if good and bad buttons have the word "button" in their accessibilityLabel
        XCTAssertFalse(app.otherElements.buttons["edit1good"].label.lowercased().contains("button"))
        XCTAssertFalse(app.otherElements.buttons["edit2good"].label.lowercased().contains("button"))
        XCTAssertFalse(app.otherElements.buttons["edit1bad"].label.lowercased().contains("button"))
        //XCTAssertFalse(app.otherElements.buttons["edit2bad"].label.lowercased().contains("button")) // assert fails because bad edit button 2 has "button" in its accessibility label

        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit() { issue in // fails Label duplicates trait on bad edit button 2
                var shouldIgnore = false
                      
                if issue.auditType == .textClipped || issue.auditType == .contrast { // Ignore Text clipped failure false positives // Ignore contrast failure due to false positive on disabled button text
                       shouldIgnore = true
                }
                return shouldIgnore
            }
        } else {
            // Fallback on earlier versions
        }

    }
    func testLinks() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("Links")
        app.collectionViews.buttons["Links"].tap()
        //assert elements with a11y identifiers exist
        XCTAssertTrue(app.scrollViews.otherElements.links["goodLink1a"].exists)
        XCTAssertTrue(app.scrollViews.otherElements.links["goodLink1b"].exists)
        XCTAssertTrue(app.scrollViews.otherElements.links["goodLink2"].exists)
        XCTAssertTrue(app.scrollViews.otherElements.buttons["badLink1a"].exists) // default links are found as .buttons unless button trait is removed
        XCTAssertTrue(app.scrollViews.otherElements.buttons["badLink1b"].exists)
        XCTAssertTrue(app.scrollViews.otherElements.buttons["badLink2"].exists)
        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit() //bad example links fail contrast
        } else {
            // Fallback on earlier versions
        }
    }
    func testAccordions() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("Accordions")
        app.collectionViews.buttons["Accordions"].tap()
        //assert elements with a11y identifiers exist
        XCTAssertTrue(app.scrollViews.otherElements.buttons["accordionGood"].exists)// disclosureTriangles not working anymore
        XCTAssertTrue(app.scrollViews.otherElements.staticTexts["accordionGood1"].exists)
        XCTAssertTrue(app.scrollViews.otherElements.buttons["accordionGood2"].exists)
        
        // Check hierarchy
        print("Full element tree:")
        print(app.debugDescription)
        
        XCTAssertTrue(app.scrollViews.otherElements.buttons["accordionBad"].exists)
        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit() //bad example fails contrast
        } else {
            // Fallback on earlier versions
        }
    }
    func testTabs() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("Tabs")
        app.collectionViews.buttons["Tabs"].tap()
        //assert elements with a11y identifiers exist
        XCTAssertTrue(app.scrollViews.collectionViews["tabsGood2"].exists)
        XCTAssertTrue(app.scrollViews.collectionViews["tabsBad2"].exists)
        //assert that TabViews have accessibility labels
        XCTAssertFalse(app.scrollViews.collectionViews["tabsGood2"].label.isEmpty)
        //XCTAssertFalse(app.scrollViews.collectionViews["tabsBad2"].label.isEmpty) // fails because tabsBad2 has no accessibility label

        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit() // passes with false negative (tabsBad2 TabView example has no accessibility label)
        } else {
            // Fallback on earlier versions
        }
    }
    func testToggles() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("Toggles")
        app.collectionViews.buttons["Toggles"].tap()
        //assert elements with a11y identifiers exist
        XCTAssertTrue(app.switches["toggleGood1"].exists)
        XCTAssertTrue(app.switches["toggleGood2"].exists)
        XCTAssertTrue(app.switches["toggleGood3a"].exists)
        XCTAssertTrue(app.switches["toggleGood3b"].exists)
        XCTAssertTrue(app.switches["toggleBad1"].exists)
        XCTAssertTrue(app.switches["toggleBad2"].exists)
        XCTAssertTrue(app.switches["toggleBad3a"].exists)
        XCTAssertTrue(app.switches["toggleBad3b"].exists)
        //assert that elements have accessibility labels
        XCTAssertFalse(app.switches["toggleGood1"].label.isEmpty)
        XCTAssertFalse(app.switches["toggleGood2"].label.isEmpty)
        XCTAssertFalse(app.switches["toggleGood3a"].label.isEmpty)
        XCTAssertFalse(app.switches["toggleGood3b"].label.isEmpty)
        //XCTAssertFalse(app.switches["toggleBad1"].label.isEmpty) //fails
        //XCTAssertFalse(app.switches["toggleBad2"].label.isEmpty) //fails
        XCTAssertFalse(app.switches["toggleBad3a"].label.isEmpty) //passes as false positive
        XCTAssertFalse(app.switches["toggleBad3b"].label.isEmpty) //passes as false positive
        XCTAssertFalse(app.switches["toggleGood3a"].label == app.switches["toggleGood3b"].label)
        //XCTAssertFalse(app.switches["toggleBad3a"].label == app.switches["toggleBad3b"].label) //fails because labels are the same
        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()
            app.swipeUp()
            app.swipeUp()
            try app.performAccessibilityAudit() { issue in
                var shouldIgnore = false
                if issue.auditType == .contrast { // Ignore contrast failure due to false positive on text with passing contrast
                       shouldIgnore = true
                }
                return shouldIgnore
            }
        } else {
            // Fallback on earlier versions
        }
    }
    func testSliders() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("Sliders")
        app.collectionViews.buttons["Sliders"].tap()
        //assert elements with a11y identifiers exist
        XCTAssertTrue(app.sliders["sliderGood1"].exists)
        XCTAssertTrue(app.sliders["Speed"].exists) // .accessibilityIdentifier would not work to find the sliderGood2
        XCTAssertTrue(app.sliders["sliderBad1"].exists)
        XCTAssertTrue(app.sliders["sliderBad2"].exists)
        //assert that elements have accessibility labels
        XCTAssertFalse(app.sliders["sliderGood1"].label.isEmpty)
        XCTAssertFalse(app.sliders["Speed"].label.isEmpty)
        //XCTAssertFalse(app.sliders["sliderBad1"].exists) // fails because sliderBad1 has no accessibility label
        //XCTAssertFalse(app.sliders["sliderBad2"].exists) // fails because sliderBad2 has no accessibility label

        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()
            app.swipeUp()
            app.swipeUp()
            try app.performAccessibilityAudit() // passes with false negative (sliderBad1 example has no accessibility label)
        } else {
            // Fallback on earlier versions
        }
    }
    func testProgressIndicators() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("Progress")
        app.collectionViews.buttons["Progress Indicators"].tap()
        //assert elements with a11y identifiers exist
        app.buttons["saveGood"].tap()
        //XCTAssertTrue(app.progressIndicators["progressView1good"].exists)//seems to be a bug that XCT wont find this element when it's been made visible
        XCTAssertTrue(app.progressIndicators["progressView2good"].exists)
        app.buttons["saveBad"].tap()
        //XCTAssertTrue(app.progressIndicators["progressView1bad"].exists)//seems to be a bug that XCT wont find this element when it's been made visible
        XCTAssertTrue(app.progressIndicators["progressView2bad"].exists)
        //assert that elements have accessibility labels
        XCTAssertFalse(app.progressIndicators["progressView2good"].label.isEmpty)
        //XCTAssertFalse(app.progressIndicators["progressView2bad"].label.isEmpty) // fails because progressView2bad has no accessibility label

        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit() // fails on iPhone sometimes as a false positive saying Contrast failed
            app.swipeUp()
            app.swipeUp()
            try app.performAccessibilityAudit() // fails with false positive saying progressView2bad Hit area is too small
        } else {
            // Fallback on earlier versions
        }
    }
    func testDynamicType() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("Dynamic")
        app.collectionViews.buttons["Dynamic Type"].tap()
        //assert elements with a11y identifiers exist
        XCTAssertTrue(app.staticTexts.element(matching: .any, identifier: "goodLabel").exists)
        XCTAssertTrue(app.staticTexts["badLabel"].exists)
       // XCTAssertTrue(app.textFields.element(matching: .any, identifier: "goodTextField").exists) // element can't be selected
        XCTAssertTrue(app.textFields["badTextField"].exists)
        XCTAssertTrue(app.buttons["goodButton"].exists)
        XCTAssertTrue(app.buttons["badButton"].exists)

        //Note: It's not possible to test for truncated text or .lineLimit()

        //performA11yAudit
        if #available(iOS 17.0, *) {
            //try app.performAccessibilityAudit() // fails with false positive Text clipped failure on the page title
            app.swipeUp()
            app.swipeUp()
            try app.performAccessibilityAudit() // fails with false positive Contrast failed on black on white text
        } else {
            // Fallback on earlier versions
        }
    }
    func testTextFields() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("Text")
        app.collectionViews.buttons["Text Fields"].tap()
        //assert elements with a11y identifiers exist
        XCTAssertTrue(app.textFields["First Name"].exists)
        XCTAssertTrue(app.textFields["fNameGood"].exists)
        XCTAssertTrue(app.textFields["Last Name"].exists)
        XCTAssertTrue(app.textFields["Username"].exists)
        XCTAssertTrue(app.secureTextFields["passwordGood"].exists)
        XCTAssertTrue(app.textFields["Email"].exists)
        XCTAssertTrue(app.textFields["Street Address"].exists)
        XCTAssertTrue(app.textFields["Street Address Line 2"].exists)
        XCTAssertTrue(app.textFields["street2Good"].exists)
        XCTAssertTrue(app.textFields["City"].exists)
        XCTAssertTrue(app.textFields["State"].exists)
        XCTAssertTrue(app.textFields["phoneGood"].exists)
        XCTAssertTrue(app.textFields["phoneBad"].exists)
        XCTAssertTrue(app.textFields["Website"].exists)


        //assert that elements have accessibility labels
        XCTAssertFalse(app.textFields["fNameGood"].label.isEmpty)
        //XCTAssertFalse(app.textFields["First Name"].label.isEmpty) //wont work
        //XCTAssertFalse(app.textFields["Username"].label.isEmpty) //wont work to test if labels are not empty on textFields
        //XCTAssertFalse(app.textFields["fNameBad"].label.isEmpty) //fails because fNameBad has no label
        XCTAssertFalse(app.textFields["phoneGood"].label.isEmpty) //passes because phoneGood does have a label that is not empty
        //XCTAssertFalse(app.textFields["phoneBad"].label.isEmpty) //fails because phoneBad has an empty label
        XCTAssertFalse(app.secureTextFields["passwordGood"].label.isEmpty)

        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit() { issue in
                var shouldIgnore = false
                if issue.auditType == .contrast { // Ignore contrast failure due to false positive on text with passing contrast
                       shouldIgnore = true
                }
                return shouldIgnore
            }
            app.swipeUp()
            app.swipeUp()
            try app.performAccessibilityAudit()//false positive fail on contrast
            //buggy and often tests the previous screen rather than the intended screen when using the simulator
        } else {
            // Fallback on earlier versions
        }
    }
    func testPageTitles() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("Title")
        app.collectionViews.buttons["Page Titles"].tap()
        app.swipeUp()
        app.buttons["Page Titles Bad Example"].tap()
        

        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit() //passes because there is no test for missing page title
        } else {
            // Fallback on earlier versions
        }
    }
    func testSegmentedControls() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("Segmented")
        app.collectionViews.buttons["Segmented Controls"].tap()
        
        //assert elements with a11y identifiers exist
        //XCTAssertTrue(app.segmentedControls["pickerGood"].exists) // cannot select the segmented control directly, only its children
        XCTAssertTrue(app.segmentedControls.buttons["Red"].exists) // can test for existence of a button inside the segmented control but not the segmented control itself
        //assert that elements have accessibility labels
        //XCTAssertFalse(app.segmentedControls["pickerGood"].label.isEmpty) //can't select a Picker{}

        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()
        } else {
            // Fallback on earlier versions
        }
    }
    func testSteppers() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("Steppers")
        app.collectionViews.buttons["Steppers"].tap()
        
        //assert elements with a11y identifiers exist
        XCTAssertTrue(app.steppers["stepperGood1"].exists)
        XCTAssertTrue(app.steppers["stepperGood2"].exists)
        XCTAssertTrue(app.steppers["stepperBad1"].exists)
        XCTAssertTrue(app.steppers["stepperBad2"].exists)

        //assert that elements have accessibility labels
        XCTAssertFalse(app.steppers["stepperGood1"].label.isEmpty)
        XCTAssertFalse(app.steppers["stepperGood2"].label.isEmpty)
        //XCTAssertFalse(app.steppers["stepperBad1"].label.isEmpty) // fails because there is no label
        //XCTAssertFalse(app.steppers["stepperBad2"].label.isEmpty) // fails because there is no label


        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()
        } else {
            // Fallback on earlier versions
        }
    }
    func testDateTimePickers() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("Date")
        app.collectionViews.buttons["Date & Time Pickers"].tap()
        
        //assert elements with a11y identifiers exist
        XCTAssertTrue(app.datePickers["startDateGood"].exists)
        XCTAssertTrue(app.datePickers["endDateGood"].exists)
        XCTAssertTrue(app.datePickers["timeGood"].exists)
        XCTAssertTrue(app.datePickers["dateTimeGood"].exists)
        XCTAssertTrue(app.datePickers["graphicalGood"].exists)
        XCTAssertTrue(app.datePickers["wheelGood"].exists)
        XCTAssertTrue(app.datePickers["startDateBad"].exists)
        XCTAssertTrue(app.datePickers["endDateBad"].exists)
        XCTAssertTrue(app.datePickers["timeBad"].exists)
        XCTAssertTrue(app.datePickers["dateTimeBad"].exists)
        XCTAssertTrue(app.datePickers["graphicalBad"].exists)
        XCTAssertTrue(app.datePickers["wheelBad"].exists)

        //assert that elements have accessibility labels
        XCTAssertFalse(app.datePickers["startDateGood"].label.isEmpty)
        XCTAssertFalse(app.datePickers["endDateGood"].label.isEmpty)
        XCTAssertFalse(app.datePickers["timeGood"].label.isEmpty)
        XCTAssertFalse(app.datePickers["dateTimeGood"].label.isEmpty)
        XCTAssertFalse(app.datePickers["graphicalGood"].label.isEmpty)
        XCTAssertFalse(app.datePickers["wheelGood"].label.isEmpty)
        //XCTAssertFalse(app.datePickers["startDateBad"].label.isEmpty) // fails because there is no label
        //XCTAssertFalse(app.datePickers["endDateBad"].label.isEmpty) // fails because there is no label
        //XCTAssertFalse(app.datePickers["timeBad"].label.isEmpty) // fails because there is no label
        //XCTAssertFalse(app.datePickers["dateTimeBad"].label.isEmpty) // fails because there is no label
        //XCTAssertFalse(app.datePickers["graphicalBad"].label.isEmpty) // fails because there is no label
        //XCTAssertFalse(app.datePickers["wheelBad"].label.isEmpty) // fails because there is no label


        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit() // fails dynamic type on a calendar picker date cell
            app.swipeUp()
            try app.performAccessibilityAudit()
        } else {
            // Fallback on earlier versions
        }
    }
    func testErrorValidation() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("Error")
        app.collectionViews.buttons["Error Validation"].tap()
        //assert elements with a11y identifiers exist
        XCTAssertTrue(app.textFields["fNameGood"].exists)
        XCTAssertTrue(app.textFields["First Name *"].exists)
        XCTAssertTrue(app.textFields["Last Name *"].exists)
        XCTAssertTrue(app.textFields["phoneGood"].exists) //wont work and "Phone" wont work either
        XCTAssertTrue(app.textFields["Phone Number"].exists)
        XCTAssertTrue(app.textFields["Email *"].exists)
        XCTAssertTrue(app.textFields["First Name"].exists)
        XCTAssertTrue(app.textFields["Last Name"].exists)
        XCTAssertTrue(app.textFields["emailBad"].exists)


        //assert that elements have accessibility labels
        XCTAssertFalse(app.textFields["First Name *"].label.isEmpty)
        XCTAssertFalse(app.textFields["Last Name *"].label.isEmpty)
        XCTAssertFalse(app.textFields["fNameBad"].label.isEmpty)
        XCTAssertFalse(app.textFields["Last Name"].label.isEmpty) // these bad examples do have labels because it's only a bad error validation example

        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit() { issue in
                var shouldIgnore = false
                if issue.auditType == .contrast { // Ignore contrast failure due to false positive on text with passing contrast
                       shouldIgnore = true
                }
                return shouldIgnore
            }
            app.swipeUp()
            app.swipeUp()
            try app.performAccessibilityAudit()
            //buggy and often tests the previous screen rather than the intended screen when using the simulator
        } else {
            // Fallback on earlier versions
        }
    }
    func testAccessibilityNotifications() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("Notific")
        app.collectionViews.buttons["Accessibility Notifications"].tap()

        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()
            //buggy and often tests the previous screen rather than the intended screen when using the simulator 
        } else {
            // Fallback on earlier versions
        }
    }
    func testLists() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("Lists")
        app.collectionViews.buttons["Lists"].tap()

        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()//passes
        } else {
            // Fallback on earlier versions
        }
    }
    func testCards() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("cards")
        app.collectionViews.buttons["Cards"].tap()

        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()//contrast false positive fail
        } else {
            // Fallback on earlier versions
        }
    }
    func testGroupingControls() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("group")
        app.collectionViews.buttons["Grouping Controls"].tap()

        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()
        } else {
            // Fallback on earlier versions
        }
    }
    func testReadingOrder() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("read")
        app.collectionViews.buttons["Reading Order"].tap()

        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()
        } else {
            // Fallback on earlier versions
        }
    }
    func testAdjustableAction() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("action")
        app.collectionViews.buttons["Adjustable Action"].tap()

        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()
        } else {
            // Fallback on earlier versions
        }
    }
    func testSheets() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("sheet")
        app.collectionViews.buttons["Sheets"].tap()

        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()
        } else {
            // Fallback on earlier versions
        }
    }
    func testConfirmationDialogs() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("dialog")
        app.collectionViews.buttons["Confirmation Dialogs"].tap()

        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()
        } else {
            // Fallback on earlier versions
        }
    }
    func testAlerts() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("alerts")
        app.collectionViews.buttons["Alerts"].tap()

        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()
        } else {
            // Fallback on earlier versions
        }
    }
    func testDataTables() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("data")
        app.collectionViews.buttons["Data Tables"].tap()

        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()
        } else {
            // Fallback on earlier versions
        }
    }
    func testLanguage() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("lang")
        app.collectionViews.buttons["Language"].tap()

        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()//passes
        } else {
            // Fallback on earlier versions
        }
    }
    func testInputLabels() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("input")
        app.collectionViews.buttons["Accessibility Input Labels"].tap()

        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()
        } else {
            // Fallback on earlier versions
        }
    }
    func testFocusManagement() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("focus")
        app.collectionViews.buttons["Focus Management"].tap()

        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()
        } else {
            // Fallback on earlier versions
        }
    }
    func testCheckboxes() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("check")
        app.collectionViews.buttons["Checkboxes"].tap()
        //assert elements with a11y identifiers exist
        XCTAssertTrue(app.switches["checkboxGood"].exists)
        XCTAssertTrue(app.switches["Phone"].exists)
        XCTAssertTrue(app.switches["Email"].exists)
        XCTAssertTrue(app.switches["Text"].exists)
        XCTAssertTrue(app.buttons["checkboxBad"].exists)
        //assert that elements have accessibility labels
        XCTAssertFalse(app.switches["checkboxGood"].label.isEmpty)
        XCTAssertFalse(app.buttons["checkboxBad"].label.isEmpty)
        //performA11yAudit
        if #available(iOS 17.0, *) {
            app.swipeUp()
            app.swipeUp()
            try app.performAccessibilityAudit() // contrast fails false positive
        } else {
            // Fallback on earlier versions
        }
    }
    func testCombiningFocus() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("focus")
        app.collectionViews.buttons["Combining Focus"].tap()

        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()//fails label not human-readable on last bad person.fill icon image
        } else {
            // Fallback on earlier versions
        }
    }
    func testNavigation() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("navigation")
        app.collectionViews.buttons["Navigation"].tap()

        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()//passes
            app.swipeUp()
            try app.performAccessibilityAudit()//passes
        } else {
            // Fallback on earlier versions
        }
    }
    func testInputInstructions() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("input")
        app.collectionViews.buttons["Input Instructions"].tap()

        //performA11yAudit
        if #available(iOS 17.0, *) {
            app.swipeUp()
            try app.performAccessibilityAudit()
        } else {
            // Fallback on earlier versions
        }
    }
    func testPopovers() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("pop")
        app.collectionViews.buttons["Popovers"].tap()

        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()
        } else {
            // Fallback on earlier versions
        }
    }
    func testMenus() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("menus")
        app.collectionViews.buttons["Menus"].tap()

        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()
        } else {
            // Fallback on earlier versions
        }
    }
    func testTouchTargetSize() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("target")
        app.collectionViews.buttons["Touch Target Size"].tap()

        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit() //false positive fails hit area is too small on good example division symbol because it does not account for the spacing
        } else {
            // Fallback on earlier versions
        }
    }
    func testDarkMode() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("dark")
        app.collectionViews.buttons["Dark Mode"].tap()
        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()
        } else {
            // Fallback on earlier versions
        }
    }
    func testAccessibilityRepresentation() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("represent")
        app.collectionViews.buttons["Accessibility Representation"].tap()
        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()//fails contrast on the custom slider
        } else {
            // Fallback on earlier versions
        }
    }
    func testReduceMotion() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("reduce")
        app.collectionViews.buttons["Reduce Motion"].tap()
        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()
        } else {
            // Fallback on earlier versions
        }
    }
    func testMeaningfulAccessibleNames() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("name")
        app.collectionViews.buttons["Meaningful Accessible Names"].tap()
        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit() { issue in
                var shouldIgnore = false
                if issue.auditType == .textClipped { // Ignore text clipped due to false positive on page title text then it passes
                       shouldIgnore = true
                }
                return shouldIgnore
            }
        } else {
            // Fallback on earlier versions
        }
    }
    func testRadioButtons() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("radio")
        app.collectionViews.buttons["Radio Buttons"].tap()

        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()
        } else {
            // Fallback on earlier versions
        }
    }
    func testPickers() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("picker")
        app.collectionViews.buttons["Pickers"].tap()

        //performA11yAudit
        if #available(iOS 17.0, *) {
            app.swipeUp()
            try app.performAccessibilityAudit() //false positive contrast fail
        } else {
            // Fallback on earlier versions
        }
    }
    func testAccessibilityHidden() throws {
        let app = XCUIApplication()
        app.launch()
        app.searchFields["Search"].tap()
        app.typeText("hidden")
        app.collectionViews.buttons["Accessibility Hidden"].tap()
        //performA11yAudit
        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()
        } else {
            // Fallback on earlier versions
        }
    }



    
    
    
    
    



} //end of tests file
