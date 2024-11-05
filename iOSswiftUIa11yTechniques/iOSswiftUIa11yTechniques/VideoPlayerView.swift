import SwiftUI
import AVKit

struct VideoPlayerView: View {
    private let player = AVPlayer(url: URL(string: "https://pauljadam.com/demos/closed-descriptions-captions.mov")!)
    
    @State private var isMuted = false
    @State private var isPlaying = false
    @State private var volumeLevel: Float = 1.0
    
    var body: some View {
        VStack {
            Text("Video Player Captions & Audio Descriptions Test")
                .font(.largeTitle)
            
            VideoPlayer(player: player)
            
            Spacer()
            
            HStack {
                Button(action: {
                    if (isPlaying) {
                        player.pause()
                    } else {
                        player.play()
                    }
                    isPlaying.toggle()
                }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                }
                .accessibilityLabel(isPlaying ? "Pause" : "Play")
                Spacer()
                Button(action: {
                    isMuted.toggle()
                    player.isMuted = isMuted
                }) {
                    Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                }
                .accessibilityLabel(isMuted ? "Unmute" : "Mute")
                Slider(value: $volumeLevel, in: 0...1, step: 0.01)
                    .onChange(of: volumeLevel) { newValue in
                        player.volume = newValue
                    }
                    .accessibilityLabel("Volume")

            }.padding()
        }
    }
}

struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerView()
    }
}
