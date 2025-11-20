/*
   Copyright 2023 CVS Health and/or one of its affiliates

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

struct ATdetectionView: View {
    @State private var showingAlert = false
    @State private var showingAlertBad = false
    @AccessibilityFocusState private var isTriggerFocused: Bool


    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    

    
    var body: some View {
        ScrollView {
            VStack {
                Text("Detecting accessibility features running on a user's device is not recommended because it may lead to creating unequal experiences between all users. However, sometimes it may be necessary to detect if an accessibility feature is running, for example, if you need to provide a specific message to VoiceOver users only. e.g., using `UIAccessibility.isVoiceOverRunning` to check if VoiceOver is running when the page loads and then show an alert reminding the VoiceOver user not to disable VoiceOver Hints. All of the iOS accessibility features can be detected, i.e., using `UIAccessibility.is{AccessibilityFeature}Running` and replacing `{AccessibilityFeature}` with the name of the accessibility feature you're detecting.")
                    .padding(.bottom)
                NavigationLink(destination: A11ySettingsDetail()) {
                    Text("Detectable Accessibility Features")
                        .frame(maxWidth: .infinity)
                        .padding(15)
                }
                    .padding(.bottom)
                Text("Good Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment: .leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                Text("If VoiceOver was running when you loaded this page then an alert would have displayed.").padding(.bottom)
                if (UIAccessibility.isVoiceOverRunning){
                    Text("VoiceOver was turned on when this page loaded.").font(.title)
                }
                if (!UIAccessibility.isVoiceOverRunning){
                    Text("VoiceOver was turned off when this page loaded.").font(.title)
                }
                DisclosureGroup("Details") {
                    Text("The good example uses `UIAccessibility.isVoiceOverRunning` check if VoiceOver is running when the page loads and then shows an alert reminding the VoiceOver user not to disable VoiceOver Hints.")
                }.padding(.bottom).accessibilityHint("Good Example")
            }.onAppear {
                if UIAccessibility.isVoiceOverRunning {
                    showingAlert = true
                } else {
                    showingAlert = false
                }
            }
            .alert("VoiceOver is turned on!", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {
                    isTriggerFocused = true
                }
            } message: {
                Text("This application uses VoiceOver Accessibility Hints to improve the accessibility of controls so if a control does not appear to be fully accessible to VoiceOver please make sure you have not disabled VoiceOver Hints.")
            }
            .navigationTitle("Accessibility Detection")
            .padding()

        }
 
    }

}

struct A11ySettingsDetail: View {
    
    @Environment(\.accessibilityDimFlashingLights) private var dimFlashingLightsEnabled
    @Environment(\.accessibilityLargeContentViewerEnabled) private var largeContentViewerEnabled
    @Environment(\.accessibilityPlayAnimatedImages) private var playAnimatedImages

    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                SettingRow(title: "VoiceOver", isEnabled: UIAccessibility.isVoiceOverRunning)
                SettingRow(title: "Zoom", isEnabled: UIAccessibility.isAssistiveTouchRunning)
                SettingRow(title: "Guided Access", isEnabled: UIAccessibility.isGuidedAccessEnabled)
                SettingRow(title: "Invert Colors", isEnabled: UIAccessibility.isInvertColorsEnabled)
                SettingRow(title: "Reduce Motion", isEnabled: UIAccessibility.isReduceMotionEnabled)
                SettingRow(title: "Increase Contrast", isEnabled: UIAccessibility.isDarkerSystemColorsEnabled)
                SettingRow(title: "Speak Screen", isEnabled: UIAccessibility.isSpeakScreenEnabled)
                SettingRow(title: "Closed Captions", isEnabled: UIAccessibility.isClosedCaptioningEnabled)
                SettingRow(title: "Bold Text", isEnabled: UIAccessibility.isBoldTextEnabled)
                SettingRow(title: "Switch Control", isEnabled: UIAccessibility.isSwitchControlRunning)
                SettingRow(title: "Reduce Transparency", isEnabled: UIAccessibility.isReduceTransparencyEnabled)
                SettingRow(title: "On/Off Switch Labels", isEnabled: UIAccessibility.isOnOffSwitchLabelsEnabled)
                SettingRow(title: "Assistive Touch", isEnabled: UIAccessibility.isAssistiveTouchRunning)
                SettingRow(title: "Video Autoplay", isEnabled: UIAccessibility.isVideoAutoplayEnabled)
                SettingRow(title: "Button Shapes", isEnabled: UIAccessibility.buttonShapesEnabled)
                SettingRow(title: "Prefers Cross Fade Transitions", isEnabled: UIAccessibility.prefersCrossFadeTransitions)
                SettingRow(title: "Differentiate Without Color", isEnabled: UIAccessibility.shouldDifferentiateWithoutColor)
                SettingRow(title: "Grayscale Enabled", isEnabled: UIAccessibility.isGrayscaleEnabled)
                SettingRow(title: "Dim Flashing Lights", isEnabled: dimFlashingLightsEnabled)
                SettingRow(title: "Large Content Viewer", isEnabled: largeContentViewerEnabled)
                SettingRow(title: "Play Animated Images", isEnabled: playAnimatedImages)
            }.padding()
        }
        .navigationTitle("Detectable Accessibility Features")
    }
}

struct SettingRow: View {
    let title: String
    let isEnabled: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isEnabled ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isEnabled ? .green : .gray)
                .accessibilityLabel(isEnabled ? "Enabled" : "Disabled")
                .accessibilityRemoveTraits(.isSelected)
            Text(title)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
        }.accessibilityElement(children: .combine)
    }
}

 
struct ATdetectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ATdetectionView()
        }
    }
}
