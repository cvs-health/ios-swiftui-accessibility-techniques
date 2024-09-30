import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let videoURL = URL(string: "https://pauljadam.com/demos/closed-descriptions-captions.mov")!
    
    @State private var player: AVPlayer?
    @State private var volumeLevel: Float = 1.0
    
    var body: some View {
        VStack {
            Text("Video Player Captions & Audio Descriptions Test")
                .font(.largeTitle)
            
            VideoPlayer(player: createAVPlayer(url: videoURL))
                .edgesIgnoringSafeArea(.all)
            
        }
    }
    
    private func createAVPlayer(url: URL) -> AVPlayer {
        let player = AVPlayer(url: url)
        return player
    }
    
    private func playPauseVideo() {
        player?.play()
    }
    
    private func pauseVideo() {
        player?.pause()
    }
    
    private var playerIsPlaying: Bool = true
    
    private func setVolume(_ level: Float) {
        player?.volume = level
    }
}

struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerView()
    }
}
