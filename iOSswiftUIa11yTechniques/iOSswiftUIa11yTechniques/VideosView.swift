/*
   Copyright 2023-20024 CVS Health and/or one of its affiliates

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
import AVKit

struct CustomVideoPlayer: UIViewControllerRepresentable {
    @Binding var isPlaying: Bool
    @Binding var isMuted: Bool
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let url = URL(string: "https://pauljadam.com/demos/closed-descriptions-captions.mov")!
        controller.player = AVPlayer(url: url)
        controller.player?.play()
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player?.rate = isPlaying ? 1 : 0
        uiViewController.player?.isMuted = isMuted
    }
}

struct VideosView: View {
    private var darkGreen = Color(red: 0 / 255, green: 102 / 255, blue: 0 / 255)
    private var darkRed = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isMuted = false
    @State private var isPlaying = false

    var body: some View {
        ScrollView {
            VStack {
                Text("Videos need Closed Captions for deaf users and Audio Descriptions for blind users. Provide a closed caption track on the video and an audio description track that users can select. Or provide a captioned video and a separate audio-described video. Apple's native video player controls are not accessible to VoiceOver, Full Keyboard Access, and other accessibility users because they are hidden by default and a user must tap the video to show the controls. Create a custom play button so that accessibility users can focus on the button and use it to play the video. Use `.accessibilityElement(children: .contain)` to create a group container for the video and for the custom play controls. Add `.accessibilityLabel(\"Name of Video\")` and VoiceOver users will hear the video name if using direct touch. Add `.accessibilityHint(\"Double-tap to play and show controls\")` so VoiceOver users hear how to play the video. Swipe exploration with VoiceOver will not work so the custom play button is required. Full Keyboard Access users have no method to show the native player controls, only the custom play button is keyboard accessible.")
                    .padding(.bottom)
                Text("Good Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemGreen) : darkGreen)
                    .padding(.bottom)
                
                CustomVideoPlayer(isPlaying: $isPlaying, isMuted: $isMuted)
                    .frame(width: .infinity, height: 320)
                    .accessibilityElement(children: .contain) // creates a group container
                    .accessibilityLabel("Biology 101 Video")
                    .accessibilityHint("Double-tap to play and show controls") // let the VoiceOver user know they can double tap on this element to display the video controls and also play the video. They will only here this with direct-touch exploration, during swipe navigation the element is skipped over and never announced.
                    .accessibilityRespondsToUserInteraction() // not sure this has any effect
                    .focusable() // will show a full keyboard access focus outline but nothing is operable on the video
                
                HStack {
                    Button(action: {
                        isPlaying.toggle()
                    }) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.title2)
                    }
                    .accessibilityLabel(isPlaying ? "Pause" : "Play")
                    
                    Spacer()
                    
                    Button(action: {
                        isMuted.toggle()
                    }) {
                        Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .font(.title2)
                    }
                    .accessibilityLabel(isMuted ? "Unmute" : "Mute")
                }
                .padding()
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Biology 101 Video Player Controls")
                
                DisclosureGroup("Details") {
                    Text("The good example has a custom play button so that accessibility users can focus on the button and use it to play the video. `.accessibilityElement(children: .contain)` creates a group container for the video and for the custom play controls. `.accessibilityLabel(\"Biology 101 Video\")` enables VoiceOver users to hear the video name if they focus on the video using direct touch. `.accessibilityHint(\"Double-tap to play and show controls\")` is added so VoiceOver users hear they can double-tap to play the video and show controls. Closed captions and audio descriptions are provided in selectable tracks on the video Audio and Subtitles settings.")
                }.padding(.bottom).accessibilityHint("Good Example")
                
                Text("Bad Example")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(colorScheme == .dark ? Color(.systemRed) : darkRed)
                Divider()
                    .frame(height: 2.0, alignment:.leading)
                    .background(colorScheme == .dark ? Color(.systemRed) : darkRed)
                    .padding(.bottom)
                
                VideoPlayer(player: AVPlayer(url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4")!))
                    .frame(width: .infinity, height: 320)
                
                DisclosureGroup("Details") {
                    Text("The bad example has no custom play button which blocks accessibility users from playing the video. The video has no group container or accessibility label so VoiceOver users can't focus on the video with direct touch. There is no hint so VoiceOver users wont hear they can double-tap to play the video and show controls. Closed captions and audio descriptions are not provided. The video cannot be played with Full Keyboard Access or other accessibility features.")
                }.accessibilityHint("Bad Example")
            }
        }
        .navigationTitle("Videos")
        .padding()
    }
}
#Preview {
    NavigationStack {
        VideosView()
    }
}
